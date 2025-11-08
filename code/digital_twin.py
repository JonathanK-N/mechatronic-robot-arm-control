#!/usr/bin/env python3
"""
Modèle numérique léger pour le bras 4 DOF.
Il permet de planifier quelques cycles pick/place, de vérifier les limites
articulaires et d'exporter les trajectoires pour corrélation avec la pile C++.
"""

from __future__ import annotations

import argparse
import csv
import math
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence, Tuple


Pose = Tuple[float, float, float, float]


@dataclass(frozen=True)
class JointSpec:
    name: str
    length_mm: float
    limit_deg: float
    max_speed_dps: float


@dataclass
class TrajectoryPoint:
    cycle: int
    label: str
    timestamp_s: float
    pose_deg: Pose
    tip_mm: Tuple[float, float, float]
    range_margin_deg: float
    workspace_ok: bool


JOINTS: Tuple[JointSpec, ...] = (
    JointSpec("base", 120.0, 90.0, 90.0),
    JointSpec("shoulder", 200.0, 65.0, 75.0),
    JointSpec("elbow", 180.0, 70.0, 85.0),
    JointSpec("wrist", 75.0, 105.0, 120.0),
)

POSE_SEQUENCE = ("home", "pick", "inspect", "place")
POSES_DEG: dict[str, Pose] = {
    "home": (0.0, -25.0, 48.0, 5.0),
    "pick": (25.0, -38.0, 32.0, -12.0),
    "inspect": (-18.0, -5.0, 57.0, 10.0),
    "place": (40.0, -52.0, 20.0, -20.0),
}


class DigitalTwin:
    def __init__(self, joints: Sequence[JointSpec]):
        self.joints = joints

    @staticmethod
    def _deg_to_rad(angle: float) -> float:
        return angle * math.pi / 180.0

    def forward_kinematics(self, pose_deg: Pose) -> Tuple[float, float, float]:
        base, shoulder, elbow, wrist = map(self._deg_to_rad, pose_deg)
        l1, l2, l3, l4 = (joint.length_mm for joint in self.joints)

        # Modèle simplifié : base tourne autour de Z, les autres axes sont coplanaires.
        planar_arm = l2 * math.cos(shoulder) + l3 * math.cos(shoulder + elbow)
        planar_arm += l4 * math.cos(shoulder + elbow + wrist)

        x = math.cos(base) * (l1 + planar_arm)
        y = math.sin(base) * (l1 + planar_arm)
        z = (
            l2 * math.sin(shoulder)
            + l3 * math.sin(shoulder + elbow)
            + l4 * math.sin(shoulder + elbow + wrist)
        )
        return (round(x, 2), round(y, 2), round(z, 2))

    def transition_time(self, pose_a: Pose, pose_b: Pose) -> float:
        durations = []
        for delta, joint in zip((abs(a - b) for a, b in zip(pose_a, pose_b)), self.joints):
            durations.append(delta / max(joint.max_speed_dps, 1e-3))
        return max(durations) * 1.2  # marge de sécurité

    def plan_cycles(self, cycles: int) -> List[TrajectoryPoint]:
        if cycles < 1:
            raise ValueError("cycles doit être >= 1")

        timeline: List[TrajectoryPoint] = []
        clock = 0.0
        current_pose = POSES_DEG["home"]

        for cycle in range(cycles):
            for label in POSE_SEQUENCE:
                pose = POSES_DEG[label]
                clock += self.transition_time(current_pose, pose)
                tip = self.forward_kinematics(pose)
                margin = min(
                    joint.limit_deg - abs(angle)
                    for joint, angle in zip(self.joints, pose)
                )
                workspace_ok = self._workspace_check(tip)
                timeline.append(
                    TrajectoryPoint(
                        cycle=cycle + 1,
                        label=label,
                        timestamp_s=round(clock, 3),
                        pose_deg=pose,
                        tip_mm=tip,
                        range_margin_deg=round(margin, 2),
                        workspace_ok=workspace_ok,
                    )
                )
                current_pose = pose
        return timeline

    @staticmethod
    def _workspace_check(tip: Tuple[float, float, float]) -> bool:
        x, y, z = tip
        radius = math.hypot(x, y)
        return 120.0 <= radius <= 520.0 and 0.0 <= z <= 450.0


def export_csv(points: Iterable[TrajectoryPoint], export_path: Path) -> None:
    export_path.parent.mkdir(parents=True, exist_ok=True)
    with export_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(
            [
                "cycle",
                "label",
                "timestamp_s",
                "base_deg",
                "shoulder_deg",
                "elbow_deg",
                "wrist_deg",
                "tip_x_mm",
                "tip_y_mm",
                "tip_z_mm",
                "range_margin_deg",
                "workspace_ok",
            ]
        )
        for point in points:
            writer.writerow(
                [
                    point.cycle,
                    point.label,
                    point.timestamp_s,
                    *point.pose_deg,
                    *point.tip_mm,
                    point.range_margin_deg,
                    int(point.workspace_ok),
                ]
            )


def summarize(points: Sequence[TrajectoryPoint]) -> None:
    total_time = points[-1].timestamp_s if points else 0.0
    worst_margin = min((p.range_margin_deg for p in points), default=0.0)
    workspace_faults = [p for p in points if not p.workspace_ok]

    print("=== Rapport digital twin ===")
    print(f"Points calculés : {len(points)}")
    print(f"Durée totale    : {total_time:.2f} s")
    print(f"Marge min joints: {worst_margin:.2f} °")
    if workspace_faults:
        labels = ", ".join({f"{p.cycle}:{p.label}" for p in workspace_faults})
        print(f"ATTENTION: hors volume utile sur {labels}")
    else:
        print("Volume utile respecté pour tous les points.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Planificateur simplifié pour Atlas 4 DOF.")
    parser.add_argument("--cycles", type=int, default=2, help="Nombre de cycles pick/place à simuler.")
    parser.add_argument(
        "--export",
        type=Path,
        help="Chemin CSV optionnel (ex: tests/trajectory_report.csv).",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    twin = DigitalTwin(JOINTS)
    points = twin.plan_cycles(args.cycles)
    summarize(points)

    if args.export:
        export_csv(points, args.export)
        print(f"Rapport exporté vers {args.export}")


if __name__ == "__main__":
    main()

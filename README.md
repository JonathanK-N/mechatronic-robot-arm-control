# Mechatronic Robot Arm Control

![Hero](docs/images/atlas_hero.png)

> Projet réalisé et industrialisé pendant mon stage chez **Mechatronic Solution** pour doter l’atelier d’un bras 4 DOF prêt à être déployé sur ligne automobile.

## Vue exécutive

| KPI | Valeur actuelle | Objectif Q2 |
|-----|-----------------|-------------|
| Précision répétitive | 0,4 mm | ≤ 0,3 mm |
| Temps de cycle pick/place | 1,8 s | ≤ 1,5 s |
| Charge utile nominale | 2,5 kg | 3 kg |
| Disponibilité ligne (OEE) | 86 % | ≥ 92 % |

## Montage & intégration

<p align="center">
  <img src="docs/images/atlas_mount_front.jpg" width="32%" alt="Montage face avant">
  <img src="docs/images/atlas_mount_back.png" width="32%" alt="Montage face arrière">
  <img src="docs/images/atlas_wiring.jpeg" width="32%" alt="Distribution câblage">
</p>

Des macro-photos supplémentaires (cycloïdes, poignée, ODrive, stack encodeurs) se trouvent dans `docs/images/` et sont liées à un dossier d’inspiration interne (`docs/atlas_reference.md`).

## Architecture système

- **Chaîne mécatronique** : réducteurs cycloïdaux imprimés, entraînements BLDC (axes 1-2) + steppers (axes 3-4), retour encodeurs absolus + FSR sur la pince.
- **Électronique** : STM32F4 + bus CAN interne, hub d’E/S 24V, télémètre HC-SR04 pour sécuriser la zone opérateur.
- **Contrôle temps réel (C++)** : boucle PID 50 Hz, profiler de charges, publication MQTT vers l’edge broker usine.
- **Jumeau numérique (Python)** : validation cinématique, respect du volume utile, export CSV exploitable par MES.
- **Couche data (COBOL/Prolog)** : consolidation KPI journaliers, planification maintenance, règles expertes pour diagnostics.

## Pile logicielle

| Langage | Fichiers clés | Finalité |
|---------|---------------|----------|
| C++17 | `code/main.cpp`, `code/pid_controller.h`, `code/mqtt_config.h` | Simulation temps réel, publication MQTT, profils charge dynamique. |
| Python 3.11 | `code/digital_twin.py` | Calculs cinématiques, validation volumique, génération de rapports. |
| COBOL (GnuCOBOL) | `code/factory_kpi.cbl`, `code/maintenance_scheduler.cbl` | KPI usine (disponibilité, performance, qualité) et planification maintenance préventive. |
| Prolog (SWI) | `code/diagnostics.pl`, `code/process_planner.pl` | Détection intelligente des dérives + suggestions d’actions correctives et ordonnancement des opérations. |

## Cycle opérationnel
1. **Initialisation** – calibration zéro-couple, alignement encodeurs, démarrage MQTT.
2. **Exécution** – le simulateur C++ pousse les positions réelles, Python vérifie la cinématique et fournit les setpoints.
3. **Supervision** – COBOL ingère les journaux (CSV/JSON) pour générer les KPI SHIFT et recommander les maintenances.
4. **Diagnostic** – les règles Prolog surveillent températures, couples, bruits encodeurs et déclenchent des alertes contextualisées.
5. **Boucle d’amélioration** – les rapports `tests/trajectory_report.csv` et `tests/mqtt_logs.json` servent de base aux revues quotidiennes.

## Démos rapides

```bash
# Build & lancer la boucle C++ (nécessite g++)
g++ -std=c++17 code/main.cpp -o build/arm_control && build/arm_control

# Vérifier le jumeau numérique et exporter un reporting
python code/digital_twin.py --cycles 3 --export tests/trajectory_report.csv

# Consolider les KPI par shift
cobc -x -free code/factory_kpi.cbl -o build/factory_kpi && build/factory_kpi

# Générer un planning maintenance 7 jours
cobc -x -free code/maintenance_scheduler.cbl -o build/maintenance_scheduler && build/maintenance_scheduler

# Exécuter les règles expertes
swipl -q -f code/diagnostics.pl -g run_diagnostics -t halt
swipl -q -f code/process_planner.pl -g run_process_planner -t halt
```

## Organisation

- `cad/` : plans mécaniques livrés à Mechatronic Solution.
- `code/` : sources multi-langages (C++/Python/COBOL/Prolog) + configurations.
- `docs/images/` : galerie montage + détails composants.
- `docs/reference/` : dossier d’inspiration hors-ligne et notes d’atelier.
- `tests/` : captures MQTT, rapports CSV issus du jumeau numérique, scripts QA.

## Feuille de route
- Intégrer les courbes issues du STM32F4 dans la boucle C++ (remplacer les profils statiques).
- Ajouter l’interface ROS 2 / MoveIt! côté Python pour générer des tickets trajectoire.
- Coupler COBOL aux journaux réels MES (format OPC-UA/CSV) et déployer les règles Prolog dans un microservice SWI.
- Capitaliser la galerie photo dans Confluence Mechatronic Solution avec les check-lists d’assemblage.

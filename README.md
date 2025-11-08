# mechatronic-robot-arm-control

![Atlas inspiration](docs/images/atlas_hero.png)

Système de contrôle mécatronique pour un bras 4 DOF orienté assemblage automobile. La pile actuelle combine un STM32F4, des capteurs IoT (encodeurs absolus, FSR, télémètre HC-SR04) et des servos Dynamixel. La précision ciblée est de 0,4 mm avec un temps de cycle moyen de 1,8 s.

## Inspirations & médias importés
- Sources iconographiques : [Atlas – 6DOF 3D printed universal robot](https://hackaday.io/project/168259-atlas-6dof-3d-printed-universal-robot).
- Captures intégrées dans `docs/images/` :  
  `atlas_arm_overview.jpg`, `atlas_cycloidal.png`, `atlas_odrive.png`, `atlas_wrist.png`, `atlas_end_effector.png`. Elles documentent la cinématique cycloïdale et la chaîne d’alimentation (Odrive + steppers).
- La page HTML brute est archivée dans `docs/reference/hackaday_atlas6dof.html` pour consultation hors ligne.

## Architecture logicielle
| Langage | Fichier | Rôle |
|---------|---------|------|
| C++ | `code/main.cpp`, `code/pid_controller.h`, `code/mqtt_config.h` | Boucle de contrôle temps réel simulée + publication MQTT. |
| Python | `code/digital_twin.py` | Modèle cinématique simplifié, planification de trajectoire et génération de rapports CSV. |
| COBOL | `code/factory_kpi.cbl` | Calcul de KPI industriels (rendement, disponibilité, taux de défaut) pour les lots assemblés par le bras. |
| Prolog | `code/diagnostics.pl` | Règles d’inférence pour qualifier des défauts capteurs/actionneurs et proposer des actions correctives. |

## Organisation du dépôt
- `cad/` : plans mécaniques complémentaires (non modifiés ici).
- `code/` : implémentations multi-langages + configurations MQTT/PID.
- `docs/images/` : visuels importés d’Hackaday (voir légendes dans `docs/atlas_reference.md`).
- `docs/reference/` : captures HTML de projets tiers et notes de veille.
- `tests/` : gabarits pour rejouer les scénarios MQTT et valider les temps de cycle.

## Exécution rapide
> Utilisez `python`, `g++`, `cobc` (GnuCOBOL) et `swipl` disponibles en ligne de commande.

### C++ (commande native)
```bash
g++ -std=c++17 code/main.cpp -o build/arm_control && build/arm_control
```

### Python (digital twin)
```bash
python code/digital_twin.py --cycles 3 --export tests/trajectory_report.csv
```

### COBOL (KPI industriels)
```bash
cobc -x -free code/factory_kpi.cbl -o build/factory_kpi && build/factory_kpi
```

### Prolog (diagnostics experts)
```bash
swipl -q -f code/diagnostics.pl -g run_diagnostics -t halt
```

## Prochaines étapes suggérées
- Connecter `code/main.cpp` à la vraie passerelle MQTT (mosquitto, Azure IoT, etc.).
- Remplacer les profils statiques par des mesures captées sur le STM32F4.
- Étendre `digital_twin.py` pour exporter des trajectoires MoveIt! et ROS 2.

---
*Révision import médias : novembre 2025. Toute image reste propriété de l’auteur du projet Hackaday référencé.*

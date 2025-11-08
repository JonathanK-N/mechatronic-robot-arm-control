# 🎯 Fichiers STL pour Impression 3D - Atlas 6-DOF

## 📋 Liste des Pièces à Imprimer

### 🏗️ Structure Principale
- **base_housing.STL** - Boîtier base (aluminium usiné - référence uniquement)
- **shoulder_bracket.STL** - Support épaule renforcé
- **elbow_joint.STL** - Articulation coude avec roulements intégrés

### ⚙️ Réducteurs Cycloïdaux
- **cycloidal_disk_1.STL** - Disque cycloïdal axe 1 (PETG)
- **cycloidal_disk_2.STL** - Disque cycloïdal axe 2 (PETG)
- **output_ring.STL** - Couronne de sortie
- **eccentric_bearing.STL** - Palier excentrique

### 🤏 Effecteur Final
- **gripper_base.STL** - Base pince avec capteurs FSR
- **gripper_finger_left.STL** - Doigt gauche adaptatif
- **gripper_finger_right.STL** - Doigt droit adaptatif

### 🔌 Supports Électroniques
- **pcb_mount.STL** - Support carte principale
- **sensor_bracket.STL** - Support capteurs
- **cable_guide.STL** - Guide-câbles

## 🖨️ Paramètres d'Impression Recommandés

### PETG (Pièces Mécaniques)
```
Température extrudeur: 235°C
Température plateau: 80°C
Vitesse: 50mm/s
Hauteur couche: 0.2mm
Remplissage: 40% (gyroïde)
Supports: Oui (angle >45°)
```

### PLA+ (Prototypes)
```
Température extrudeur: 215°C
Température plateau: 60°C
Vitesse: 60mm/s
Hauteur couche: 0.15mm
Remplissage: 30% (cubique)
Supports: Minimal
```

## 🔧 Post-Traitement

1. **Nettoyage**: Retrait supports, ponçage léger
2. **Perçage**: Alésage précision Ø6H7, Ø8H7
3. **Assemblage**: Insertion roulements, joints
4. **Test**: Vérification jeux fonctionnels

## 📊 Temps d'Impression Estimés

| Pièce | Temps | Matériau | Poids |
|-------|-------|----------|-------|
| Base housing | 8h30 | PETG | 245g |
| Cycloidal disk | 4h15 | PETG | 125g |
| Gripper base | 3h45 | PETG | 95g |
| **Total** | **~35h** | - | **~1.2kg** |
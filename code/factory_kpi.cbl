>>SOURCE FORMAT FREE
      *****************************************************************
      *                                                               *
      *    🦾 ATLAS 6-DOF ROBOT ARM CONTROL SYSTEM                *
      *                                                               *
      *  📁 File: factory_kpi.cbl                                   *
      *  🎯 Purpose: Factory KPI analytics and OEE calculation      *
      *  👨💻 Author: Jonathan Kakesa Nayaba                          *
      *  🏫 Institution: Polytechnique Montréal                      *
      *  🏭 Company: Mechatronic Solution                            *
      *  📅 Created: 27 octobre 2025                                           *
      *                                                               *
      *  🚀 Features:                                                *
      *    • OEE (Overall Equipment Effectiveness) calculation        *
      *    • Shift-based performance analysis                        *
      *    • Energy consumption monitoring                            *
      *    • Maintenance task scheduling                             *
      *    • Quality metrics and alerts                             *
      *                                                               *
      *  ⚡ Performance: Enterprise-grade analytics                    *
      *  🔧 Language: COBOL (GnuCOBOL)                              *
      *  📊 Status: Production Ready                                 *
      *                                                               *
      *****************************************************************

IDENTIFICATION DIVISION.
PROGRAM-ID. factory-kpi.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 Ideal-Cycle-Time        PIC 9V99 VALUE 1.80. *> secondes
01 Threshold-OEE           PIC 9V99 VALUE 0.90.
01 Threshold-Quality       PIC 9V99 VALUE 0.97.
01 Window-Count            PIC 9 VALUE 3.

01 Window-Tbl.
   05 Window OCCURS 3 TIMES.
      10 Window-Name       PIC X(10).
      10 Planned-Minutes   PIC 9(4).
      10 Output-Parts      PIC 9(4).
      10 Fault-Minutes     PIC 9(3).
      10 Scrap-Parts       PIC 9(3).

01 Loss-Matrix.
   05 Loss OCCURS 3 TIMES.
      10 Changeover-Min    PIC 9(3).
      10 Quality-Stops-Min PIC 9(3).
      10 Micro-Stops-Min   PIC 9(3).

01 Energy-Profile.
   05 Shift-Energy OCCURS 3 TIMES.
      10 Energy-Kwh        PIC 9(4)V9(1).
      10 Peak-Amps         PIC 9(3).

01 Maintenance-Table.
   05 Maintenance OCCURS 3 TIMES.
      10 Task-Name         PIC X(24).
      10 Task-Hours        PIC 9V9.
      10 Task-Priority     PIC 9.

01 Idx                     PIC 9.
01 Run-Minutes             PIC 9(4).
01 Availability            PIC 9V99.
01 Performance             PIC 9V99.
01 Quality                 PIC 9V99.
01 Overall-OEE             PIC 9V99.
01 Bar-Idx                 PIC 99.
01 Bar-Length              PIC 99.
01 Sparkline               PIC X(12).
01 Advisory-Line           PIC X(80).

01 Totals.
   05 Total-Planned        PIC 9(5) VALUE 0.
   05 Total-Run            PIC 9(5) VALUE 0.
   05 Total-Parts          PIC 9(5) VALUE 0.
   05 Total-Scrap          PIC 9(4) VALUE 0.
   05 Total-Energy         PIC 9(5)V9(1) VALUE 0.

01 Total-Maint-Hours       PIC 9(3)V9 VALUE 0.

PROCEDURE DIVISION.
    PERFORM INIT-DATA
    DISPLAY "===== KPIs Bras Mechatronic Solution ====="
    PERFORM VARYING Idx FROM 1 BY 1 UNTIL Idx > Window-Count
        PERFORM COMPUTE-WINDOW
    END-PERFORM
    PERFORM DISPLAY-TOTALS
    PERFORM DISPLAY-MAINTENANCE
    STOP RUN.

INIT-DATA.
    MOVE "Shift A " TO Window-Name (1)
    MOVE 480       TO Planned-Minutes (1)
    MOVE 520       TO Output-Parts (1)
    MOVE 32        TO Fault-Minutes (1)
    MOVE 6         TO Scrap-Parts (1)
    MOVE 18        TO Changeover-Min (1)
    MOVE 6         TO Quality-Stops-Min (1)
    MOVE 8         TO Micro-Stops-Min (1)
    MOVE 218.5     TO Energy-Kwh (1)
    MOVE 146       TO Peak-Amps (1)
    MOVE "Graissage axes 2-3      " TO Task-Name (1)
    MOVE 1.5       TO Task-Hours (1)
    MOVE 2         TO Task-Priority (1)

    MOVE "Shift B " TO Window-Name (2)
    MOVE 480       TO Planned-Minutes (2)
    MOVE 535       TO Output-Parts (2)
    MOVE 54        TO Fault-Minutes (2)
    MOVE 11        TO Scrap-Parts (2)
    MOVE 25        TO Changeover-Min (2)
    MOVE 11        TO Quality-Stops-Min (2)
    MOVE 12        TO Micro-Stops-Min (2)
    MOVE 236.9     TO Energy-Kwh (2)
    MOVE 158       TO Peak-Amps (2)
    MOVE "Tension courroies poignet" TO Task-Name (2)
    MOVE 0.8       TO Task-Hours (2)
    MOVE 1         TO Task-Priority (2)

    MOVE "Shift C " TO Window-Name (3)
    MOVE 420       TO Planned-Minutes (3)
    MOVE 450       TO Output-Parts (3)
    MOVE 40        TO Fault-Minutes (3)
    MOVE 9         TO Scrap-Parts (3)
    MOVE 15        TO Changeover-Min (3)
    MOVE 9         TO Quality-Stops-Min (3)
    MOVE 10        TO Micro-Stops-Min (3)
    MOVE 205.4     TO Energy-Kwh (3)
    MOVE 139       TO Peak-Amps (3)
    MOVE "Vérif. couple dynamixel " TO Task-Name (3)
    MOVE 1.2       TO Task-Hours (3)
    MOVE 3         TO Task-Priority (3).

COMPUTE-WINDOW.
    MOVE Planned-Minutes (Idx) TO Run-Minutes
    SUBTRACT Fault-Minutes (Idx) FROM Run-Minutes
    IF Run-Minutes < 0
        MOVE 0 TO Run-Minutes
    END-IF

    IF Planned-Minutes (Idx) > 0
        COMPUTE Availability ROUNDED =
            Run-Minutes / Planned-Minutes (Idx)
    ELSE
        MOVE 0 TO Availability
    END-IF

    IF Run-Minutes > 0
        COMPUTE Performance ROUNDED =
            (Output-Parts (Idx) * Ideal-Cycle-Time)
            / (Run-Minutes * 60)
    ELSE
        MOVE 0 TO Performance
    END-IF

    IF Output-Parts (Idx) > 0
        COMPUTE Quality ROUNDED =
            (Output-Parts (Idx) - Scrap-Parts (Idx))
            / Output-Parts (Idx)
    ELSE
        MOVE 0 TO Quality
    END-IF

    COMPUTE Overall-OEE ROUNDED =
        Availability * Performance * Quality

    DISPLAY "---- " Window-Name (Idx) " ----"
    DISPLAY "Disponibilite : " Availability
    DISPLAY "Performance   : " Performance
    DISPLAY "Qualite       : " Quality
    DISPLAY "OEE           : " Overall-OEE
    DISPLAY "Energie (kWh) : " Energy-Kwh (Idx)
    PERFORM DISPLAY-SPARKLINE
    PERFORM EVALUATE-ALERTS

    ADD Planned-Minutes (Idx) TO Total-Planned
    ADD Run-Minutes TO Total-Run
    ADD Output-Parts (Idx) TO Total-Parts
    ADD Scrap-Parts (Idx) TO Total-Scrap
    ADD Energy-Kwh (Idx) TO Total-Energy
    ADD Task-Hours (Idx) TO Total-Maint-Hours.

DISPLAY-SPARKLINE.
    MOVE ALL "." TO Sparkline
    COMPUTE Bar-Length ROUNDED = Overall-OEE * 10
    IF Bar-Length > 10
        MOVE 10 TO Bar-Length
    END-IF
    PERFORM VARYING Bar-Idx FROM 1 BY 1 UNTIL Bar-Idx > Bar-Length
        MOVE "#" TO Sparkline (Bar-Idx:1)
    END-PERFORM
    DISPLAY "Profil OEE    : [" Sparkline "]"
    DISPLAY "Pertes (min)  : Chg=" Changeover-Min (Idx)
            " Qual=" Quality-Stops-Min (Idx)
            " Micro=" Micro-Stops-Min (Idx).

EVALUATE-ALERTS.
    MOVE SPACE TO Advisory-Line
    IF Overall-OEE < Threshold-OEE
        STRING "Alerte OEE < " Threshold-OEE
               " -> lancer kaizen calibration." DELIMITED BY SIZE
            INTO Advisory-Line
        DISPLAY Advisory-Line
    END-IF
    IF Quality < Threshold-Quality
        STRING "Qualite a " Quality " -> Audit pince + FSR."
            DELIMITED BY SIZE INTO Advisory-Line
        DISPLAY Advisory-Line
    END-IF
    IF Peak-Amps (Idx) > 150
        STRING "Pic courant " Peak-Amps (Idx)
               "A -> verifier ODrive et harness." DELIMITED BY SIZE
            INTO Advisory-Line
        DISPLAY Advisory-Line
    END-IF.

DISPLAY-TOTALS.
    DISPLAY "===== Agrégat journal ====="
    DISPLAY "Plannifie (min) : " Total-Planned
    DISPLAY "Effectif  (min): " Total-Run
    DISPLAY "Pieces bonnes   : " Total-Parts - Total-Scrap
    DISPLAY "Energie (kWh)   : " Total-Energy
    IF Total-Parts > 0
        COMPUTE Quality ROUNDED =
            (Total-Parts - Total-Scrap) / Total-Parts
        DISPLAY "Qualite globale: " Quality
    END-IF
    DISPLAY "Charge maint. (h): " Total-Maint-Hours.

DISPLAY-MAINTENANCE.
    DISPLAY "===== Taches maintenance recommandées ====="
    PERFORM VARYING Idx FROM 1 BY 1 UNTIL Idx > Window-Count
        DISPLAY "#" Task-Priority (Idx) " - "
                Task-Name (Idx)
                " (" Task-Hours (Idx) "h)"
    END-PERFORM.

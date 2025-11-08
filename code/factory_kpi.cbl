>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. factory-kpi.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 Ideal-Cycle-Time        PIC 9V99 VALUE 1.80. *> secondes
01 Window-Count            PIC 9 VALUE 3.
01 Window-Tbl.
   05 Window OCCURS 3 TIMES.
      10 Window-Name       PIC X(10).
      10 Planned-Minutes   PIC 9(4).
      10 Output-Parts      PIC 9(4).
      10 Fault-Minutes     PIC 9(3).
      10 Scrap-Parts       PIC 9(3).

01 Idx                     PIC 9.
01 Run-Minutes             PIC 9(4).
01 Availability            PIC 9V99.
01 Performance             PIC 9V99.
01 Quality                 PIC 9V99.
01 Overall-OEE             PIC 9V99.

01 Totals.
   05 Total-Planned        PIC 9(5) VALUE 0.
   05 Total-Run            PIC 9(5) VALUE 0.
   05 Total-Parts          PIC 9(5) VALUE 0.
   05 Total-Scrap          PIC 9(4) VALUE 0.

PROCEDURE DIVISION.
    PERFORM INIT-DATA
    DISPLAY "===== KPIs bras mécatronique ====="
    PERFORM VARYING Idx FROM 1 BY 1 UNTIL Idx > Window-Count
        PERFORM COMPUTE-WINDOW
    END-PERFORM
    PERFORM DISPLAY-TOTALS
    STOP RUN.

INIT-DATA.
    MOVE "Shift A " TO Window-Name (1)
    MOVE 480       TO Planned-Minutes (1)
    MOVE 520       TO Output-Parts (1)
    MOVE 32        TO Fault-Minutes (1)
    MOVE 6         TO Scrap-Parts (1)

    MOVE "Shift B " TO Window-Name (2)
    MOVE 480       TO Planned-Minutes (2)
    MOVE 535       TO Output-Parts (2)
    MOVE 54        TO Fault-Minutes (2)
    MOVE 11        TO Scrap-Parts (2)

    MOVE "Shift C " TO Window-Name (3)
    MOVE 420       TO Planned-Minutes (3)
    MOVE 450       TO Output-Parts (3)
    MOVE 40        TO Fault-Minutes (3)
    MOVE 9         TO Scrap-Parts (3).

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
    DISPLAY "Disponibilité : " Availability
    DISPLAY "Performance   : " Performance
    DISPLAY "Qualité       : " Quality
    DISPLAY "OEE           : " Overall-OEE

    ADD Planned-Minutes (Idx) TO Total-Planned
    ADD Run-Minutes TO Total-Run
    ADD Output-Parts (Idx) TO Total-Parts
    ADD Scrap-Parts (Idx) TO Total-Scrap.

DISPLAY-TOTALS.
    DISPLAY "===== Agrégat journal ====="
    DISPLAY "Plannifié (min) : " Total-Planned
    DISPLAY "Effectif  (min): " Total-Run
    DISPLAY "Pièces bonnes   : " Total-Parts - Total-Scrap
    IF Total-Parts > 0
        COMPUTE Quality ROUNDED =
            (Total-Parts - Total-Scrap) / Total-Parts
        DISPLAY "Qualité globale: " Quality
    END-IF.

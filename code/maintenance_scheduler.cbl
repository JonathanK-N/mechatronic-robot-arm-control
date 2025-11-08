>>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. maintenance-scheduler.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 Horizon-Days          PIC 9 VALUE 7.
01 Day-Idx               PIC 9.
01 Task-Idx              PIC 9.
01 Slot-Idx              PIC 9.
01 Day-Label.
   05 Day-Name           PIC X(12).
01 Schedule-Line         PIC X(120).
01 Total-Week-Hours      PIC 9(3)V9 VALUE 0.
01 Slot-Hours            PIC 9V9.

01 Day-Names.
   05 Day-Entry OCCURS 7 TIMES.
      10 Label          PIC X(12).

01 Task-Table.
   05 Task OCCURS 5 TIMES.
      10 Task-Name      PIC X(26).
      10 Frequency-Day  PIC 9.
      10 Estimated-Hours PIC 9V9.
      10 Skill          PIC X(10).
      10 Criticality    PIC 9.

01 Slot-Table.
   05 Slot OCCURS 3 TIMES.
      10 Slot-Name      PIC X(8).
      10 Slot-Capacity  PIC 9V9.

PROCEDURE DIVISION.
    PERFORM INIT-DATA
    DISPLAY "===== Planning maintenance bras 4 DOF (7 jours) ====="
    PERFORM VARYING Day-Idx FROM 1 BY 1 UNTIL Day-Idx > Horizon-Days
        PERFORM BUILD-DAY-SCHEDULE
    END-PERFORM
    DISPLAY "Total heures semaine : " Total-Week-Hours
    STOP RUN.

INIT-DATA.
    MOVE "Lundi"     TO Label (1)
    MOVE "Mardi"     TO Label (2)
    MOVE "Mercredi"  TO Label (3)
    MOVE "Jeudi"     TO Label (4)
    MOVE "Vendredi"  TO Label (5)
    MOVE "Samedi"    TO Label (6)
    MOVE "Dimanche"  TO Label (7)

    MOVE "Nettoyage FSR pince      " TO Task-Name (1)
    MOVE 2                         TO Frequency-Day (1)
    MOVE 0.7                       TO Estimated-Hours (1)
    MOVE "Qualité"                 TO Skill (1)
    MOVE 2                         TO Criticality (1)

    MOVE "Graissage cycloïde A1    " TO Task-Name (2)
    MOVE 3                         TO Frequency-Day (2)
    MOVE 1.2                       TO Estimated-Hours (2)
    MOVE "Méca"                    TO Skill (2)
    MOVE 3                         TO Criticality (2)

    MOVE "Contrôle couple BLDC     " TO Task-Name (3)
    MOVE 4                         TO Frequency-Day (3)
    MOVE 1.5                       TO Estimated-Hours (3)
    MOVE "Élec"                    TO Skill (3)
    MOVE 1                         TO Criticality (3)

    MOVE "Audit câblage capteurs   " TO Task-Name (4)
    MOVE 7                         TO Frequency-Day (4)
    MOVE 2.2                       TO Estimated-Hours (4)
    MOVE "Test"                    TO Skill (4)
    MOVE 3                         TO Criticality (4)

    MOVE "Back-up firmwares STM32  " TO Task-Name (5)
    MOVE 7                         TO Frequency-Day (5)
    MOVE 0.8                       TO Estimated-Hours (5)
    MOVE "Soft"                    TO Skill (5)
    MOVE 2                         TO Criticality (5)

    MOVE "Matin"   TO Slot-Name (1)
    MOVE 2.5       TO Slot-Capacity (1)
    MOVE "Après"   TO Slot-Name (2)
    MOVE 2.0       TO Slot-Capacity (2)
    MOVE "Nuit"    TO Slot-Name (3)
    MOVE 1.0       TO Slot-Capacity (3).

BUILD-DAY-SCHEDULE.
    MOVE Label (Day-Idx) TO Day-Name
    DISPLAY "---- " Day-Name " ----"
    MOVE 0 TO Slot-Hours

    PERFORM VARYING Slot-Idx FROM 1 BY 1 UNTIL Slot-Idx > 3
        PERFORM BUILD-SLOT
    END-PERFORM.

BUILD-SLOT.
    MOVE SPACE TO Schedule-Line
    STRING " [" Slot-Name (Slot-Idx) "] " DELIMITED BY SIZE
           INTO Schedule-Line
    MOVE 0 TO Slot-Hours

    PERFORM VARYING Task-Idx FROM 1 BY 1 UNTIL Task-Idx > 5
        IF Day-Idx = Frequency-Day (Task-Idx)
            OR FUNCTION MOD (Day-Idx, Frequency-Day (Task-Idx)) = 0
            IF Slot-Hours + Estimated-Hours (Task-Idx)
                <= Slot-Capacity (Slot-Idx)
                PERFORM ASSIGN-TASK
            END-IF
        END-IF
    END-PERFORM

    IF Slot-Hours = 0
        STRING Schedule-Line "Disponible"
            DELIMITED BY SIZE INTO Schedule-Line
    END-IF

    DISPLAY Schedule-Line.

ASSIGN-TASK.
    STRING Schedule-Line
           Task-Name (Task-Idx) " (" Estimated-Hours (Task-Idx) "h/" Skill (Task-Idx)
           ",C" Criticality (Task-Idx) ") "
           DELIMITED BY SIZE INTO Schedule-Line
    ADD Estimated-Hours (Task-Idx) TO Slot-Hours
    ADD Estimated-Hours (Task-Idx) TO Total-Week-Hours.

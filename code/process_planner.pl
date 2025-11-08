% Orchestrateur de processus pour le bras 4 DOF.
% Usage : swipl -q -f code/process_planner.pl -g run_process_planner -t halt

:- module(process_planner, [
    run_process_planner/0,
    plan_order/2
]).

:- use_module(diagnostics, [fault/1, severity/2]).

operation(home,      source,    base_ready,     0.40, low).
operation(approach,  base_ready,near_part,      0.55, low).
operation(pick,      near_part, gripped_part,   0.80, medium).
operation(inspect,   gripped_part,validated,    0.65, medium).
operation(place,     validated,  part_placed,   0.70, medium).
operation(retreat,   part_placed,home_safe,     0.50, low).

station(calibration_cell, [home]).
station(feed_zone, [approach, pick]).
station(qa_table, [inspect]).
station(assembly_jig, [place]).
station(safe_clear, [retreat]).

tool(gripper, [pick, place]).
tool(vision, [inspect]).
tool(fsrs,   [pick, inspect]).

constraint(pick, payload(Kg)) :- Kg > 3.
constraint(place, humidity(H)) :- H > 65.

target_order(order(housing_panel, variant_a, payload(2.5), humidity(72))).

plan_order(Order, Plan) :-
    Order = order(_, _, payload(Payload), humidity(H)),
    findall(step(Op, Station, Duration, Risk),
        (   operation(Op, _, _, Duration, Risk),
            assign_station(Op, Station),
            not_blocked(Op, Payload, H)
        ),
        Plan).

assign_station(Operation, Station) :-
    station(Station, Ops),
    member(Operation, Ops).

not_blocked(Operation, Payload, Humidity) :-
    (constraint(Operation, payload(Payload)) ->
        format('[!] Limite charge: ~w kg pour ~w~n', [Payload, Operation]),
        fail
    ; true),
    (constraint(Operation, humidity(Humidity)) ->
        format('[!] Humidité trop élevée: ~w%% pour ~w~n', [Humidity, Operation]),
        fail
    ; true),
    \+ (fault(condensation_risk), Operation = inspect).

plan_duration([], 0).
plan_duration([step(_, _, D, _)|Tail], Total) :-
    plan_duration(Tail, Partial),
    Total is Partial + D.

detected_risks(Risks) :-
    findall(Level-F, (fault(F), severity(F, Level)), Risks).

run_process_planner :-
    target_order(Order),
    (   plan_order(Order, Steps),
        Steps \= [] ->
        plan_duration(Steps, TotalTime),
        format('Ordre : ~w~n', [Order]),
        format('Durée estimée : ~2f s~n', [TotalTime]),
        writeln('Séquence :'),
        forall(member(step(Op, Station, Dur, Risk), Steps),
            format(' - ~w @ ~w (~2f s, risque ~w)~n', [Op, Station, Dur, Risk])),
        detected_risks(Risks),
        (Risks = [] ->
            writeln('Aucun risque actif depuis la couche diagnostics.')
        ;   writeln('Rappels risques actifs :'),
            forall(member(Level-F, Risks),
                format('   * (~w) ~w~n', [Level, F]))
        )
    ;   writeln('Impossible de générer un plan: contraintes bloquantes.')
    ).

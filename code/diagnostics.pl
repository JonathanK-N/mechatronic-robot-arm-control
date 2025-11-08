% Règles expertes pour qualifier rapidement l'état du bras 4 DOF.
% Usage : swipl -q -f code/diagnostics.pl -g run_diagnostics -t halt

:- module(diagnostics, [
    fault/1,
    advise/2,
    run_diagnostics/0
]).

joint(base).
joint(shoulder).
joint(elbow).
joint(wrist).

sensor_range(temp, base, range(25, 65)).
sensor_range(temp, shoulder, range(25, 60)).
sensor_range(temp, elbow, range(25, 55)).
sensor_range(temp, wrist, range(25, 50)).

sensor_range(torque_bias, base,   range(-0.8, 0.8)).
sensor_range(torque_bias, shoulder, range(-1.2, 1.2)).
sensor_range(torque_bias, elbow, range(-0.6, 0.6)).
sensor_range(torque_bias, wrist, range(-0.4, 0.4)).

sensor_range(force_ratio, shoulder, range(0.10, 0.35)).
sensor_range(force_ratio, wrist, range(0.05, 0.25)).

sensor_range(encoder_noise, base, range(0.0, 0.02)).
sensor_range(encoder_noise, elbow, range(0.0, 0.03)).

% Observations instantanées (à remplacer par des faits générés depuis MQTT ou ROS).
reading(temp, base, 72).
reading(temp, shoulder, 61).
reading(temp, elbow, 48).
reading(temp, wrist, 44).

reading(torque_bias, base, 0.1).
reading(torque_bias, shoulder, 1.5).
reading(torque_bias, elbow, 0.3).
reading(torque_bias, wrist, 0.35).

reading(force_ratio, shoulder, 0.07).
reading(force_ratio, wrist, 0.22).

reading(encoder_noise, base, 0.018).
reading(encoder_noise, elbow, 0.05).

% --- Règles de décision ------------------------------------------------------

out_of_range(Sensor, Joint, Value, range(Min, Max)) :-
    reading(Sensor, Joint, Value),
    sensor_range(Sensor, Joint, range(Min, Max)),
    (Value < Min ; Value > Max).

fault(overtemp(Joint)) :-
    out_of_range(temp, Joint, Value, range(_, Max)),
    Value > Max.

fault(force_drop(Joint)) :-
    out_of_range(force_ratio, Joint, Value, range(Min, _)),
    Value < Min.

fault(torque_offset(Joint)) :-
    out_of_range(torque_bias, Joint, _, _).

fault(encoder_drift(Joint)) :-
    out_of_range(encoder_noise, Joint, Value, range(_, Max)),
    Value > Max.

advise(overtemp(Joint),
       ['Réduire le duty-cycle 20% et vérifiez la ventilation sur ', Joint]).

advise(force_drop(Joint),
       ['Inspecter les FSR du ', Joint, ' et recalibrer la pince.']).

advise(torque_offset(Joint),
       ['Relancer la calibration zéro couple pour ', Joint, '.']).

advise(encoder_drift(Joint),
       ['Vérifier le câblage différentiel et réaligner le codeur de ', Joint, '.']).

advise(_, ['Consulter la documentation maintenance.']).

run_diagnostics :-
    findall(F, fault(F), Faults),
    ( Faults == [] ->
        writeln('Aucun défaut détecté, tous les capteurs sont dans la plage.')
    ;   writeln('Défauts détectés :'),
        forall(member(F, Faults),
            (   format(' - ~w~n', [F]),
                advise(F, Advice),
                atomic_list_concat(Advice, '', Message),
                format('    ⇒ ~w~n', [Message])
            )
        )
    ).

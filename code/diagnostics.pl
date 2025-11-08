%
% ╔══════════════════════════════════════════════════════════════════════════════╗
% ║                    🦾 ATLAS 6-DOF ROBOT ARM CONTROL SYSTEM                  ║
% ║                                                                              ║
% ║  📁 File: diagnostics.pl                                                   ║
% ║  🎯 Purpose: Expert system for intelligent fault detection and diagnosis  ║
% ║  👨💻 Author: Jonathan Kakesa Nayaba                                          ║
% ║  🏫 Institution: Polytechnique Montréal                                      ║
% ║  🏭 Company: Mechatronic Solution                                            ║
% ║  📅 Created: 27 octobre 2025                                                            ║
% ║                                                                              ║
% ║  🚀 Features:                                                                ║
% ║    • Real-time sensor monitoring                                          ║
% ║    • Intelligent fault detection rules                                    ║
% ║    • Contextual advisory system                                           ║
% ║    • Severity-based prioritization                                        ║
% ║    • Multi-sensor correlation analysis                                    ║
% ║                                                                              ║
% ║  ⚡ Performance: Real-time expert system                                    ║
% ║  🔧 Language: Prolog (SWI-Prolog)                                         ║
% ║  📊 Status: Production Ready                                                 ║
% ╚══════════════════════════════════════════════════════════════════════════════╝
%
% Règles expertes pour qualifier rapidement l'état du bras 6 DOF.
% Usage : swipl -q -f code/diagnostics.pl -g run_diagnostics -t halt

:- module(diagnostics, [
    fault/1,
    advise/2,
    severity/2,
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
sensor_range(vibration, shoulder, range(0.0, 1.5)).   % gRMS
sensor_range(vibration, elbow, range(0.0, 1.2)).
sensor_range(bus_voltage, powertrain, range(47.5, 51.5)).
sensor_range(humidity, enclosure, range(20, 65)).
sensor_range(cycle_time, cell, range(0, 2.0)).        % secondes

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
reading(vibration, shoulder, 1.7).
reading(vibration, elbow, 1.3).
reading(bus_voltage, powertrain, 46.2).
reading(humidity, enclosure, 72).
reading(cycle_time, cell, 2.3).

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

fault(vibration_spike(Joint)) :-
    out_of_range(vibration, Joint, Value, range(_, Max)),
    Value > Max.

fault(bus_voltage_drop) :-
    out_of_range(bus_voltage, powertrain, Value, range(Min, _)),
    Value < Min.

fault(condensation_risk) :-
    out_of_range(humidity, enclosure, Value, range(_, Max)),
    Value > Max.

fault(cycle_time_regression(Delta)) :-
    reading(cycle_time, cell, Value),
    sensor_range(cycle_time, cell, range(_, Max)),
    Value > Max,
    Delta is Value - Max.

fault(thermal_chain(shoulder_elbow)) :-
    fault(overtemp(shoulder)),
    fault(overtemp(elbow)).

fault(powertrain_combo) :-
    fault(bus_voltage_drop),
    fault(vibration_spike(shoulder)).

advise(overtemp(Joint),
       ['Réduire le duty-cycle 20% et vérifiez la ventilation sur ', Joint]).

advise(force_drop(Joint),
       ['Inspecter les FSR du ', Joint, ' et recalibrer la pince.']).

advise(torque_offset(Joint),
       ['Relancer la calibration zéro couple pour ', Joint, '.']).

advise(encoder_drift(Joint),
       ['Vérifier le câblage différentiel et réaligner le codeur de ', Joint, '.']).

advise(vibration_spike(Joint),
       ['Inspecter la visserie et équilibrer la charge sur ', Joint, '.']).

advise(bus_voltage_drop,
       ['Contrôler l\'alimentation 48V et recalibrer l\'ODrive.']).

advise(condensation_risk,
       ['Fermer la baie, activer le déshumidificateur de l\'enclosure.']).

advise(cycle_time_regression(Delta),
       ['Temps de cycle dépassé de ', Delta, ' s -> revoir trajectoire ou charge utile.']).

advise(thermal_chain(shoulder_elbow),
       ['Enchaînement thermique sur axes 2/3 -> lancer refroidissement forcé.']).

advise(powertrain_combo,
       ['Baisse tension + vibrations -> audit complet ODrive/BLDC.']).

advise(_, ['Consulter la documentation maintenance.']).

severity(overtemp(_), critical).
severity(force_drop(_), major).
severity(torque_offset(_), major).
severity(encoder_drift(_), major).
severity(vibration_spike(_), major).
severity(bus_voltage_drop, critical).
severity(condensation_risk, warning).
severity(cycle_time_regression(_), warning).
severity(thermal_chain(_), critical).
severity(powertrain_combo, critical).
severity(_, info).

severity_value(critical, 1).
severity_value(major, 2).
severity_value(warning, 3).
severity_value(info, 4).

run_diagnostics :-
    findall(Priority-Fault,
        (fault(Fault),
         severity(Fault, Level),
         severity_value(Level, Priority)),
        Raw),
    ( Raw == [] ->
        writeln('Aucun défaut détecté, tous les capteurs sont dans la plage.')
    ;   sort(Raw, SortedAscending),
        writeln('Défauts détectés (ordre critique) :'),
        forall(member(_-F, SortedAscending),
            (   severity(F, Level),
                format(' - (~w) ~w~n', [Level, F]),
                advise(F, Advice),
                atomic_list_concat(Advice, '', Message),
                format('    ⇒ ~w~n', [Message])
            )
        )
    ).

/**
 * Minimal PID controller with anti-windup clamping.
 */
#pragma once

#include <algorithm>
#include <cmath>

template <typename T>
class PidController {
public:
    struct Gains {
        T kp {0};
        T ki {0};
        T kd {0};
    };

    struct Limits {
        T min_output {-1};
        T max_output {1};
        T min_integral {-0.5};
        T max_integral {0.5};
    };

    PidController() = default;
    PidController(Gains gains, Limits limits)
        : gains_(gains), limits_(limits) {}

    void reset() {
        integral_ = static_cast<T>(0);
        prev_error_ = static_cast<T>(0);
        first_run_ = true;
    }

    [[nodiscard]] const Gains& gains() const { return gains_; }
    [[nodiscard]] const Limits& limits() const { return limits_; }

    void gains(Gains g) { gains_ = g; }
    void limits(Limits l) { limits_ = l; }

    /**
     * Computes the control effort for a measured value.
     * @param setpoint Desired reference.
     * @param measured Feedback measurement.
     * @param dt_s Elapsed time in seconds.
     */
    T update(T setpoint, T measured, double dt_s) {
        const T error = setpoint - measured;
        const T proportional = gains_.kp * error;

        integral_ = std::clamp(integral_ + gains_.ki * error * static_cast<T>(dt_s),
                               limits_.min_integral, limits_.max_integral);

        T derivative = static_cast<T>(0);
        if (!first_run_ && dt_s > 0) {
            derivative = gains_.kd * (error - prev_error_) / static_cast<T>(dt_s);
        }

        prev_error_ = error;
        first_run_ = false;

        const T output = proportional + integral_ + derivative;
        return std::clamp(output, limits_.min_output, limits_.max_output);
    }

private:
    Gains gains_;
    Limits limits_;
    T integral_ {0};
    T prev_error_ {0};
    bool first_run_ {true};
};

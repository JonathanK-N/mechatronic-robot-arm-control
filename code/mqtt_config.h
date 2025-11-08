/**
 * MQTT + topic helpers for the robot arm simulator.
 */
#pragma once

#include <string>
#include <string_view>
#include <vector>

namespace mq {

struct TopicDescriptor {
    std::string path;        ///< Suffix appended to base topic.
    std::string description; ///< Human readable usage.
};

struct MqttConfig {
    std::string broker_host {"127.0.0.1"};
    int broker_port {1883};
    std::string client_id {"atlas-arm-sim"};
    std::string username {"lab"};
    std::string password {"lab"};
    std::string base_topic {"factory/atlas4dof"};
    std::vector<TopicDescriptor> telemetry {
        {"telemetry/state", "Positions, vitesses et couples estimés"},
        {"telemetry/health", "Résumé état capteurs / contrôleurs"}
    };
    std::vector<TopicDescriptor> commands {
        {"commands/setpoints", "Cible jointe en radian"},
        {"commands/modes", "Changement de mode (auto, manuel, arrêt)"}
    };

    [[nodiscard]] std::string broker_url() const {
        return "mqtt://" + broker_host + ":" + std::to_string(broker_port);
    }

    [[nodiscard]] std::string topic_for(std::string_view suffix) const {
        if (suffix.empty()) {
            return base_topic;
        }
        return base_topic + "/" + std::string(suffix);
    }

    [[nodiscard]] std::string telemetry_topic(std::string_view suffix) const {
        return topic_for(std::string("telemetry/") + std::string(suffix));
    }
};

}  // namespace mq

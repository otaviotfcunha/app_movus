import 'package:app_movus/models/mqtt_model.dart';

class MqttController {
  final MqttService _mqttService = MqttService();

  Future<void> connectToMqtt() async {
    await _mqttService.connect();
  }

  void sendMessage(String topic, String message) {
    _mqttService.publish(topic, message);
  }

  void subscribeToTopic(String topic) {
    _mqttService.subscribe(topic);
  }

  void disconnect() {
    _mqttService.disconnect();
  }
}

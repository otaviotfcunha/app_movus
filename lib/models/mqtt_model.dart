import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MqttService {
  late MqttServerClient _client;

  Future<void> connect() async {
    final host = dotenv.env['MQTT_HOST'] ?? '';
    final port = int.tryParse(dotenv.env['MQTT_PORT'] ?? '8883') ?? 8883;
    final clientId = dotenv.env['MQTT_CLIENT_ID'] ?? '';
    final username = dotenv.env['MQTT_USERNAME'];
    final password = dotenv.env['MQTT_PASSWORD'];

    _client = MqttServerClient(host, clientId)
      ..port = port
      ..logging(on: true)
      ..keepAlivePeriod = 20
      ..secure = true;

    // Configuração SSL/TLS
    _client.onBadCertificate = (_) => true;

    // Credenciais de autenticação
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
      print('Conectado ao MQTT');
    } on Exception catch (e) {
      print('Erro ao conectar ao MQTT: $e');
      _client.disconnect();
    }
  }

  void disconnect() {
    _client.disconnect();
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void subscribe(String topic) {
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }
}

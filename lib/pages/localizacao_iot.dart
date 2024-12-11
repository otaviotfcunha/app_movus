import 'package:flutter/material.dart';

class LocalizacaoIot extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocalizacaoIot({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Localização IoT"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Coordenadas do Equipamento IoT:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Latitude: $latitude', style: const TextStyle(fontSize: 16)),
            Text('Longitude: $longitude', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

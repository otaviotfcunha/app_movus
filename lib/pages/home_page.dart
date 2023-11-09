import 'dart:async';

import 'package:app_movus/shared/widgets/menu_lateral.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  late final MapController _mapController;

  static const _fatec = LatLng(-22.43116, -46.83463);
  static const _etec = LatLng(-22.44649, -46.83868);
  var voce = const LatLng(-22.4376, -46.8257);
  double _latAtual = -22.4376;
  double _logAtual = -46.8257;
  bool carregando = false;
  static var marcadores = [
    const Marker(
      width: 80,
      height: 80,
      point: _fatec,
      child: Icon(Icons.school),
    ),
    const Marker(
      width: 80,
      height: 80,
      point: _etec,
      child: Icon(Icons.school),
    ),
  ];

  @override
  void initState() {
    _getPosicaoInicial();
    super.initState();
    _mapController = MapController();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getPosicalAtual() async {
    var posicaoAtual;
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });

    posicaoAtual =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    if (posicaoAtual != voce) {
      marcadores.removeLast();
      voce = posicaoAtual;
      _latAtual = _currentPosition!.latitude;
      _logAtual = _currentPosition!.longitude;

      marcadores.add(
        Marker(
          width: 80,
          height: 80,
          point: voce,
          child: const Icon(Icons.person),
        ),
      );
      _mapController.move(voce, 17);
      print("Gps atualizado: $_latAtual e $_logAtual");
    }
  }

  Future<void> _getPosicaoInicial() async {
    setState(() {
      carregando = true;
    });
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });

    voce = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    _latAtual = _currentPosition!.latitude;
    _logAtual = _currentPosition!.longitude;

    marcadores.add(
      Marker(
        width: 80,
        height: 80,
        point: voce,
        child: const Icon(Icons.person),
      ),
    );
    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!carregando) {
      Timer(const Duration(seconds: 2), () {
        setState(() {
          _getPosicalAtual();
        });
      });
    }
    return SafeArea(
      child: Scaffold(
        drawer: const MenuLateral(),
        appBar: AppBar(
          title: const Text("Movus"),
        ),
        body: carregando
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () => _mapController.move(_fatec, 17),
                            child: const Text('Fatec'),
                          ),
                          MaterialButton(
                            onPressed: () => _mapController.move(_etec, 17),
                            child: const Text('Etec'),
                          ),
                          MaterialButton(
                            onPressed: () => _mapController.move(voce, 17),
                            child: const Text('Você'),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(_latAtual, _logAtual),
                          initialZoom: 17,
                          maxZoom: 20,
                          minZoom: 3,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'dev.fleaflet.flutter_map.example',
                          ),
                          MarkerLayer(markers: marcadores),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

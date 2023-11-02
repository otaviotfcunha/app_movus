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
  /*
  BOSTA
  */
  Position? _currentPosition;

  /*
  MERDA
  */

  late final MapController _mapController;

  static const _fatec = LatLng(-22.43116, -46.83463);
  static const _etec = LatLng(-22.44649, -46.83868);
  static LatLng _voce = const LatLng(-22.4376, -46.8257);
  double _latAtual = -22.4376;
  double _logAtual = -46.8257;

  static final _markers = [
    const Marker(
      width: 20,
      height: 20,
      point: _fatec,
      child: FlutterLogo(key: ValueKey('blue')),
    ),
    const Marker(
      width: 20,
      height: 20,
      point: _etec,
      child: FlutterLogo(key: ValueKey('green')),
    ),
    Marker(
      width: 20,
      height: 20,
      point: _voce,
      child: const FlutterLogo(key: ValueKey('yellow')),
    ),
  ];

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
    _mapController = MapController();
  }

  /*
  BOSTA
  */

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

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });

    _voce = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    _latAtual = _currentPosition!.latitude;
    _logAtual = _currentPosition!.longitude;
    setState(() {});
  }

  /*
  MERDA
  */

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const MenuLateral(),
        appBar: AppBar(
          title: const Text("Movus"),
        ),
        body: Padding(
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
                      onPressed: () => _mapController.move(_voce, 17),
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
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    MarkerLayer(markers: _markers),
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

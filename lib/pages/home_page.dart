import 'dart:async';
import 'dart:math';

import 'package:app_movus/models/onibus_model.dart';
import 'package:app_movus/models/utils.dart';
import 'package:app_movus/pages/localizacao_iot.dart';
import 'package:app_movus/repositories/onibus_repository.dart';
import 'package:app_movus/services/shared_preferences.dart';
import 'package:app_movus/shared/widgets/icones_mapa_onibus.dart';
import 'package:app_movus/shared/widgets/menu_lateral.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  late MapController _mapController;
  late Timer _timer;
  late OnibusRepository _busao;
  var _bus = OnibusModel([]);
  var centralizaMapa = "user";
  List<LatLng> rotaOnibus = [];
  List<LatLng> rotaNoMapa = Utils.rotaOnibusMapa();
  AppStorageService storage = AppStorageService();
  String nomeUsuario = "";
  Random rd = Random();
  int numRand = 0;

  static const _fatec = LatLng(-22.43116, -46.83463);
  static const _etec = LatLng(-22.44649, -46.83868);
  var voce = const LatLng(-22.4376, -46.8257);
  var onbus = const LatLng(-22.4376, -46.8257);
  double _latAtual = -22.4376;
  double _logAtual = -46.8257;
  bool carregando = false;
  static var marcadores = [
    const Marker(
        width: 80,
        height: 80,
        point: _fatec,
        child: Column(
          children: [
            FaIcon(FontAwesomeIcons.school, color: Colors.green, size: 40),
            Text(
              "Fatec Itapira",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        )),
    const Marker(
        width: 80,
        height: 80,
        point: _etec,
        child: Column(
          children: [
            FaIcon(FontAwesomeIcons.school, color: Colors.green, size: 40),
            Text(
              "Etec Itapira",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        )),
  ];
  static var marcadoresOnibus = [
    const Marker(
        width: 80,
        height: 80,
        point: _fatec,
        child: IconeMapaOnibus(
          nomeBusao: "BUS-1234",
          latitude: -22.43116,
          longitude: -46.83463,
          endereco: "Rua Inicial",
          qtdPassageiros: 0,
          valorPassagem: "5,00",
        )),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _busao = OnibusRepository();
    _getPosicaoInicial();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getPosicalAtual();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Os serviços de localização estão desabilitados. Habilite os serviços para acessar o aplicativo!')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Os serviços de localização foram recusados para o aplicativo.')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Os serviços de localização não estão permitidos para utilizar neste aplicativo.')));
      return false;
    }
    return true;
  }

  Future<void> _getPosicalAtual() async {
    //Pega a posição atual do onibus
    _bus = await _busao.ultimaPosicao();

    var posicaoAtual;
    var posicaoAtualOnibus;
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
    posicaoAtualOnibus = LatLng(double.parse(_bus.results[0].latitude),
        double.parse(_bus.results[0].longitude));
    var end = await Utils.obterEndereco(double.parse(_bus.results[0].latitude),
        double.parse(_bus.results[0].longitude));
    numRand = rd.nextInt(25);
    if (posicaoAtualOnibus != onbus) {
      marcadoresOnibus.removeLast();
      onbus = posicaoAtualOnibus;
      marcadoresOnibus.add(
        Marker(
            width: 80,
            height: 80,
            point: onbus,
            child: IconeMapaOnibus(
              nomeBusao: "BUS-1234",
              latitude: double.parse(_bus.results[0].latitude),
              longitude: double.parse(_bus.results[0].longitude),
              endereco: end,
              qtdPassageiros: numRand,
              valorPassagem: "5,00",
            )),
      );
      if (rotaOnibus.length > 10) {
        rotaOnibus.removeAt(0);
      }
      rotaOnibus.add(onbus);
      if (centralizaMapa == "bus") {
        _mapController.move(onbus, 17);
      }
    }

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
            //child: const FaIcon(FontAwesomeIcons.userNinja, color: Colors.purple, size: 40),
            child: Column(
              children: [
                const FaIcon(FontAwesomeIcons.userNinja,
                    color: Colors.purple, size: 40),
                Text(
                  nomeUsuario,
                  style: const TextStyle(
                      color: Colors.purple, fontWeight: FontWeight.bold),
                ),
              ],
            )),
      );
      if (centralizaMapa == "user") {
        _mapController.move(voce, 17);
      }
    }
  }

  Future<void> _getPosicaoInicial() async {
    setState(() {
      carregando = true;
    });
    nomeUsuario = await storage.getConfiguracoesNomeUsuario();
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
          child: Column(
            children: [
              const FaIcon(FontAwesomeIcons.userNinja,
                  color: Colors.purple, size: 40),
              Text(
                nomeUsuario,
                style: const TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ],
          )),
    );
    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const MenuLateral(),
        appBar: AppBar(
          title: const Text("Movus"),
        ),
        body: carregando
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    Container(
                      color: Colors.deepOrangeAccent,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            MaterialButton(
                                onPressed: () {
                                  _mapController.move(voce, 17);
                                  setState(() {
                                    centralizaMapa = "user";
                                  });
                                },
                                child: const Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.userNinja,
                                        color: Colors.white, size: 15),
                                    SizedBox(width: 10),
                                    Text(
                                      'Você',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                            MaterialButton(
                                onPressed: () {
                                  _mapController.move(onbus, 17);
                                  setState(() {
                                    centralizaMapa = "bus";
                                  });
                                },
                                child: const Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.bus,
                                        color: Colors.white, size: 15),
                                    SizedBox(width: 10),
                                    Text(
                                      'Ônibus mais próximo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                            MaterialButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocalizacaoIot(
                                      latitude: _latAtual,
                                      longitude: _logAtual,
                                    ),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.satellite,
                                      color: Colors.white, size: 15),
                                  SizedBox(width: 10),
                                  Text('Equipamento IoT',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: rotaNoMapa,
                                color: const Color.fromRGBO(255, 255, 0, 0.5),
                                strokeWidth: 8.0,
                              ),
                              Polyline(
                                points: rotaOnibus,
                                color: const Color.fromRGBO(0, 0, 200, 0.5),
                                strokeWidth: 6.0,
                              ),
                            ],
                          ),
                          MarkerLayer(markers: marcadores),
                          MarkerLayer(markers: marcadoresOnibus),
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

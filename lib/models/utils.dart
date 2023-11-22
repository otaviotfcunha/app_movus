import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class Utils{
  static Future<XFile> cropImage(XFile imageFile) async {
    late XFile arquivoSaida;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        
      ],
    );
    if(croppedFile != null){
      arquivoSaida = XFile(croppedFile.path);
    }
    return arquivoSaida;
  }

  static Future<String> obterEndereco(double latitude, double longitude) async {
    String enderecoFinal = "";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark lugar = placemarks[0];
        String endereco = "${lugar.street}, ${lugar.subLocality}, ${lugar.locality}";
        enderecoFinal = endereco;
      } else {
        print("Não foi possível obter o endereço.");
      }
    } catch (e) {
      print("Erro ao obter o endereço: $e");
    }

    return enderecoFinal;
  }

  static List<LatLng> rotaOnibusMapa(){
    List<LatLng> rota = [
      const LatLng(-22.43792, -46.82422),
      const LatLng(-22.43667, -46.82547),
      const LatLng(-22.43582, -46.82522),
      const LatLng(-22.43489, -46.82503),
      const LatLng(-22.43490, -46.82840),
      const LatLng(-22.43462, -46.83151),
      const LatLng(-22.43450, -46.83208),
      const LatLng(-22.43297, -46.83196),
      const LatLng(-22.43229, -46.83198),
      const LatLng(-22.43195, -46.83199),
      const LatLng(-22.43164, -46.83210),
      const LatLng(-22.43143, -46.83224),
      const LatLng(-22.43111, -46.83267),
      const LatLng(-22.43102, -46.83340),
      const LatLng(-22.43131, -46.83461),
      const LatLng(-22.43136, -46.83478),
      const LatLng(-22.43280, -46.83420),
      const LatLng(-22.43333, -46.83474),
      const LatLng(-22.43450, -46.83207),
      const LatLng(-22.43480, -46.83041),
      const LatLng(-22.43496, -46.82714),
      const LatLng(-22.43659, -46.82548),
      const LatLng(-22.43718, -46.82547),
      const LatLng(-22.43782, -46.82583),
      const LatLng(-22.43809, -46.82526),
      const LatLng(-22.43704, -46.82407),
      const LatLng(-22.43743, -46.82364),
      const LatLng(-22.43792, -46.82425),
    ];
    return rota;
  }

  
}
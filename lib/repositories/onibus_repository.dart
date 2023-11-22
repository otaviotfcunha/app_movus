import 'package:app_movus/models/onibus_model.dart';
import 'package:app_movus/repositories/custom_dio.dart';

class OnibusRepository{
  final _customDio = CustomDio();

  OnibusRepository();

  Future<OnibusModel> ultimaPosicao() async {
    var url = "/Onibus/?order=-createdAt&limit=1";
    var result = await _customDio.dio.get(url);
    return OnibusModel.fromJson(result.data);
  }

}

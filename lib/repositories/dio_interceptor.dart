import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioInterceptor extends Interceptor{
   @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers["X-Parse-Application-Id"] = dotenv.get("APPLICATION_ID_ONIBUS");
    options.headers["X-Parse-REST-API-Key"] = dotenv.get("APPRESTAPI_KEY_ONIBUS");
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    super.onError(err, handler);
  }

}
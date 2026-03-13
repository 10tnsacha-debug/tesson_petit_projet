import 'dart:convert';
import 'package:dio/dio.dart';

class RappelConsoApi {
  final Dio _dio = Dio();

  Future<List<dynamic>> fetchRappels() async {
    final response = await _dio.get(
      'https://codelabs.formation-flutter.fr/assets/rappels.json',
      options: Options(responseType: ResponseType.plain),
    );

    return jsonDecode(response.data);
  }
}

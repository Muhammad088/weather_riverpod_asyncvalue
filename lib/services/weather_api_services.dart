import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_riverpod_asyncvalue/constants/constants.dart';
import 'package:weather_riverpod_asyncvalue/exceptions/weather_exception.dart';
import 'package:weather_riverpod_asyncvalue/models/current_weather/current_weather.dart';
import 'package:weather_riverpod_asyncvalue/models/direct_geocoding/direct_geocoding.dart';
import 'package:weather_riverpod_asyncvalue/services/dio_error_handler.dart';

/// In WeatherApiServices, we'll be fetching data from a remote API

class WeatherApiServices {
  final Dio dio;

  WeatherApiServices({required this.dio});

  /// reads geocoding information
  Future<DirectGeocoding> getDirectGeocoding(String city) async {
    try {
      Response response = await dio.get(
        "/geo/1.0/direct",
        queryParameters: {
          "q": city,
          "limit": kLimit,
          "appid": dotenv.env["APPID"],
        },
      );
      if (response.statusCode != 200) {
        throw dioErrorHandler(response);
      }
      if (response.data.isEmpty) {
        throw WeatherException(message: "Cannot get the location of $city");
      }
      return DirectGeocoding.fromJson(response.data[0]);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getReverseGeocoding(double lat, double lon) async {
    try {
      print('LLLLocationnnnn : $lat, $lon');

      final Response response = await dio.get(
        '/geo/1.0/reverse',
        queryParameters: {
          "lat": "$lat",
          "lon": "$lon",
          "units": kUnit,
          "appid": dotenv.env["APPID"],
        },
      );
      print('LLLLocationnnnn : $response');

      if (response.statusCode != 200) {
        throw dioErrorHandler(response);
      }

      final List result = response.data;

      if (result.isEmpty) {
        throw WeatherException(
            message: 'Cannot get the name of the location($lat, $lon)');
      }

      final city = result[0]['name'];

      return city;
    } catch (e) {
      rethrow;
    }
  }

  Future<CurrentWeather> getWeather(DirectGeocoding directGeocoding) async {
    try {
      Response response = await dio.get(
        "/data/2.5/weather",
        queryParameters: {
          "lat": "${directGeocoding.lat}",
          "lon": "${directGeocoding.lon}",
          "units": kUnit,
          "appid": dotenv.env["APPID"],
        },
      );
      if (response.statusCode != 200) {
        throw dioErrorHandler(response);
      }
      return CurrentWeather.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

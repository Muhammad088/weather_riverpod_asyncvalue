import 'package:weather_riverpod_asyncvalue/exceptions/weather_exception.dart';
import 'package:weather_riverpod_asyncvalue/models/current_weather/current_weather.dart';
import 'package:weather_riverpod_asyncvalue/models/custom_error/custom_error.dart';
import 'package:weather_riverpod_asyncvalue/models/direct_geocoding/direct_geocoding.dart';
import 'package:weather_riverpod_asyncvalue/services/weather_api_services.dart';

class WeatherRepository {
  final WeatherApiServices weatherApiServices;
  WeatherRepository({
    required this.weatherApiServices,
  });

  Future<CurrentWeather> fetchWeather(String city) async {
    try {
      final DirectGeocoding directGeocoding =
          await weatherApiServices.getDirectGeocoding(city);
      print("directGeocoding: $directGeocoding");

      final CurrentWeather tempWeather =
          await weatherApiServices.getWeather(directGeocoding);

      // When we first describe data, the city information of the data
      // returned by the getWeather function is sometimes more accurate
      // than the city information we passed as an argument.
      // However, since it is difficult for us to check whether the place name
      // exists in the corresponding city, we do not use the returned city,
      // but use the city stored in the directGeocoding object.
      // In the case of Country, we will just use the country stored in the
      // directGeocoding object for convenience.

      final CurrentWeather currentWeather = tempWeather.copyWith(
        name: directGeocoding.name,
        sys: tempWeather.sys.copyWith(country: directGeocoding.country),
      );
      print('current weather: $currentWeather');
      return currentWeather;
    } on WeatherException catch (ex) {
      throw CustomError(errMsg: ex.message);
    } catch (e) {
      throw CustomError(errMsg: e.toString());
    }
  }
}

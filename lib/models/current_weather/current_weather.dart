import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'current_weather.freezed.dart';
part 'current_weather.g.dart';

/// a CurrentWeather model to store current weather information
@freezed
class CurrentWeather with _$CurrentWeather {
  @JsonSerializable(explicitToJson: true)
  // so that the generated toJson method explicitly calls toJson for nested objects as well

  const factory CurrentWeather({
    required List<Weather> weather,
    required Main main,
    required Sys sys,
    required String name,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

// models related to the current weather
/// a Weather model, to store the individual element information for the weather list
@freezed
class Weather with _$Weather {
  const factory Weather({
    @Default("") String main,
    @Default("") String description,
    @Default("") String icon,
  }) = _Weather;

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);
}

/// a Main model to store main information
@freezed
class Main with _$Main {
  const factory Main({
    @Default(0.0) double temp,
    @JsonKey(name: "temp_min") @Default(0.0) double tempMin,
    @JsonKey(name: "temp_max") @Default(0.0) double tempMax,
  }) = _Main;

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);
}

/// a sys model to store sys information.
@freezed
class Sys with _$Sys {
  const factory Sys({
    @Default("") String country,
  }) = _Sys;

  factory Sys.fromJson(Map<String, dynamic> json) => _$SysFromJson(json);
}

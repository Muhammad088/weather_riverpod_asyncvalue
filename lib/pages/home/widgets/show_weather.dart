// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_riverpod_asyncvalue/models/current_weather/app_weather.dart';

import 'package:weather_riverpod_asyncvalue/models/current_weather/current_weather.dart';
import 'package:weather_riverpod_asyncvalue/models/custom_error/custom_error.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/widgets/format_text.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/widgets/select_city.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/widgets/show_icon.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/widgets/show_temperature.dart';

class ShowWeather extends ConsumerWidget {
  const ShowWeather({
    super.key,
    required this.weatherState,
  });
  final AsyncValue<CurrentWeather?> weatherState;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return weatherState.when(
      // If the value of skipError is true, it will call the data callback
      // instead of the error callback if there is a previous value
      skipError: true,
      data: (CurrentWeather? weather) {
        print("***** in data callback");
        if (weather == null) {
          // the city search hasn't happened once yet
          return const SelectCity();
        }
        final appWeather = AppWeather.fromCurrentWeather(weather);
        return ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
            ),
            Text(
              appWeather.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  TimeOfDay.fromDateTime(DateTime.now()).format(context),
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(width: 10.0),
                Text(
                  "(${appWeather.country})",
                  style: const TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            const SizedBox(height: 60.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShowTemperature(
                  temperature: appWeather.temp,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(width: 20.0),
                Column(
                  children: [
                    ShowTemperature(temperature: appWeather.tempMax),
                    const SizedBox(height: 10),
                    ShowTemperature(temperature: appWeather.tempMin),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Spacer(),
                ShowIcon(icon: appWeather.icon),
                Expanded(
                  flex: 3,
                  child: FormatText(description: appWeather.description),
                ),
                const Spacer(),
              ],
            ),
          ],
        );
      },
      error: (err, st) {
        print("***** in error callback");

        if (weatherState.value == null) {
          // we never succeeded in fetching the weather data
          return const SelectCity();
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                (err as CustomError).errMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

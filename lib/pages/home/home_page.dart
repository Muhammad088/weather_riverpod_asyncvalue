import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_riverpod_asyncvalue/constants/constants.dart';
import 'package:weather_riverpod_asyncvalue/extensions/async_value_xx.dart';
import 'package:weather_riverpod_asyncvalue/models/current_weather/app_weather.dart';
import 'package:weather_riverpod_asyncvalue/models/current_weather/current_weather.dart';
import 'package:weather_riverpod_asyncvalue/models/custom_error/custom_error.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/providers/theme_provider.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/providers/theme_state.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/providers/weather_provider.dart';
import 'package:weather_riverpod_asyncvalue/pages/home/widgets/show_weather.dart';
import 'package:weather_riverpod_asyncvalue/pages/search/search_page.dart';
import 'package:weather_riverpod_asyncvalue/pages/temp_settings/temp_settings_page.dart';
import 'package:weather_riverpod_asyncvalue/services/providers/weather_api_services_provider.dart';
import 'package:weather_riverpod_asyncvalue/widgets/error_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? city;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getInitialLocation();
  }

  void getInitialLocation() async {
    final bool permitted = await getLocationPermission();
    if (permitted) {
      try {
        setState(() {
          loading = true;
        });
        final pos = await Geolocator.getCurrentPosition();
        city = await ref
            .read(weatherApiServicesProvider)
            .getReverseGeocoding(pos.latitude, pos.longitude);
      } catch (e) {
        city = kDefaultLocation;
      } finally {
        setState(() => loading = false);
      }
    } else {
      city = kDefaultLocation;
    }
    ref.read(weatherProvider.notifier).fetchWeather(city!);
  }

  void showGeolocationError(String errorMessage) {
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$errorMessage using $kDefaultLocation'),
      ));
    });
  }

  Future<bool> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      showGeolocationError('Location services are disabled');
      return false;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // permissions are denied. next time you could try
        // requesting permission again (this is also where
        // Android's shoudShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your app should show an explanatory UI now.
        showGeolocationError('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // permissions are denied forever, handle appropriately.
      showGeolocationError(
          'Location permissions are permanently denied, we cannot request permissions');
      return false;
    }
    // when we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CurrentWeather?>>(weatherProvider, (previous, next) {
      next.whenOrNull(
        data: (CurrentWeather? currentWeather) {
          if (currentWeather == null) {
            return;
          }
          final weather = AppWeather.fromCurrentWeather(currentWeather);

          if (weather.temp < kWarmOrNot) {
            ref.read(themeProvider.notifier).changeTheme(const DarkTheme());
          } else {
            ref.read(themeProvider.notifier).changeTheme(const LightTheme());
          }
        },
        error: (error, st) {
          errorDialog(context, (error as CustomError).errMsg);
          // showDialog(
          //   context: context,
          //   builder: (x) => AlertDialog(
          //     content: Text((error as CustomError).errMsg),
          //   ),
          // );
        },
      );
    });

    final weatherState = ref.watch(weatherProvider);
    print(weatherState.toStr);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
              onPressed: () async {
                city = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SearchPage()));
                if (city != null) {
                  ref.read(weatherProvider.notifier).fetchWeather(city!);
                }
              },
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TempSettingsPage()));
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ShowWeather(
              weatherState: weatherState,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: city == null
            ? null // it doesn't make sense to call it if the city value is null
            : () {
                // Here, using ref.invalidate to refresh the weatherProvider makes no sense
                // because it will call the build function again and return null.
                ref.read(weatherProvider.notifier).fetchWeather(city!);
              },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

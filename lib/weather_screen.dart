import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';

import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  final TextEditingController tec = TextEditingController();
  String city = 'Kolkata';
  final border = const OutlineInputBorder(
    borderSide: BorderSide(
      width: 2,
      style: BorderStyle.solid,
    ),
    borderRadius: BorderRadius.all(Radius.circular(85)),
  );
  Future<Map<String, dynamic>> getCurrentWeather(String c) async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$c&APPID=$openWeatherAPIKEY'),
      );

      final data = jsonDecode(res.body);
      
      if (data['cod'] != '200') {

        return getCurrentWeather('Kolkata');
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(city);
  }

  void _handleSubmit(String val) {
    setState(() {
      city =
          tec.text.isNotEmpty ? val[0].toUpperCase() + val.substring(1) : city;
      weather = getCurrentWeather(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              tec.clear();
              city = 'Kolkata';
              weather = getCurrentWeather(city);
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
            future: weather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              final data = snapshot.data!;

              final currentWeatherData = data['list'][0];

              final currentTemp = (currentWeatherData['main']['temp'] - 273.15)
                  .toStringAsFixed(2);
              final currentSky = currentWeatherData['weather'][0]['main'];
              final humidity = currentWeatherData['main']['humidity'];
              final pressure = currentWeatherData['main']['pressure'];
              final windSpeed = currentWeatherData['wind']['speed'];

              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //search field
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 35,
                            width: 250,
                            child: TextField(
                              onSubmitted: _handleSubmit,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              controller: tec,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.location_on,
                                    color: Color.fromARGB(255, 250, 80, 68)),
                                hintText: 'Enter the location',
                                hintStyle: const TextStyle(
                                  color: Colors.black,
                                ),
                                filled: true,
                                fillColor: Color.fromARGB(255, 229, 223, 223),
                                focusedBorder: border,
                                enabledBorder: border,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    //main card
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5,
                              sigmaY: 5,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$currentTemp °C',
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Icon(
                                    currentSky == 'Clouds' ||
                                            currentSky == 'Rain'
                                        ? Icons.cloud
                                        : Icons.sunny,
                                    size: 75,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text('$currentSky',
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: 5,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final hourlyTime =
                              DateTime.parse(data['list'][index + 1]['dt_txt']);

                          final hourlySky =
                              data['list'][index + 1]['weather'][0]['main'];
                          final hourlyTemp =
                              (data['list'][index + 1]['main']['temp'] - 273.15)
                                  .toStringAsFixed(2);

                          return HourlyForecaseItem(
                            time: DateFormat.Hm().format(hourlyTime),
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                            temp: hourlyTemp,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    //additional information
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                            icon: Icons.water_drop,
                            label: "Humidity",
                            value: "$humidity"),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: '$windSpeed',
                        ),
                        AdditionalInfoItem(
                            icon: Icons.beach_access,
                            label: 'Pressure',
                            value: '$pressure'),
                      ],
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}

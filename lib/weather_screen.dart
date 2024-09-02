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
    borderSide:  BorderSide(
      width: 1,
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
        throw 'An unexpected error occurred';
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
              city='Kolkata';
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //search field
                    Container(

                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 35,
                            width: 200,
                            child: TextField(
                               textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                              controller: tec,              
                              decoration:  InputDecoration(              
                                hintText: 'Enter the location',
                                filled: true,
                                fillColor: Colors.white,
                                focusedBorder: border,
                                enabledBorder: border,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          SizedBox(
                            height:35 ,
                            child: ElevatedButton(
                              
                              onPressed: () {
                                setState(() {
                                  city =tec.text.isNotEmpty? tec.text[0].toUpperCase() +
                                      tec.text.substring(1):city;
                                  weather = getCurrentWeather(city);
                                });
                              },
                              child: const Text('Change'),
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
                                    currentSky == 'Clouds' || currentSky == 'Rain'
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

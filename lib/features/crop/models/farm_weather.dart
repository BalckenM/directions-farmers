// Weather data models for the crop farming module.
// FarmWeather — current conditions at the farm.
// WeatherForecastDay — one day in a 10-day forecast.
// SprayWindow — whether conditions are suitable for spraying.

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  lightRain,
  rain,
  heavyRain,
  thunderstorm,
  fog,
  windy,
  frosty,
}

extension WeatherConditionX on WeatherCondition {
  String get label => switch (this) {
        WeatherCondition.sunny => 'Sunny',
        WeatherCondition.partlyCloudy => 'Partly Cloudy',
        WeatherCondition.cloudy => 'Cloudy',
        WeatherCondition.lightRain => 'Light Rain',
        WeatherCondition.rain => 'Rain',
        WeatherCondition.heavyRain => 'Heavy Rain',
        WeatherCondition.thunderstorm => 'Thunderstorm',
        WeatherCondition.fog => 'Foggy',
        WeatherCondition.windy => 'Windy',
        WeatherCondition.frosty => 'Frost',
      };

  String get icon => switch (this) {
        WeatherCondition.sunny => '☀️',
        WeatherCondition.partlyCloudy => '⛅',
        WeatherCondition.cloudy => '☁️',
        WeatherCondition.lightRain => '🌦️',
        WeatherCondition.rain => '🌧️',
        WeatherCondition.heavyRain => '⛈️',
        WeatherCondition.thunderstorm => '🌩️',
        WeatherCondition.fog => '🌫️',
        WeatherCondition.windy => '💨',
        WeatherCondition.frosty => '🌨️',
      };
}

class FarmWeather {
  const FarmWeather({
    required this.farmId,
    required this.condition,
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windKmh,
    required this.windDirection,
    required this.rainfallMm24h,
    required this.rainfallMm7d,
    required this.uvIndex,
    required this.frostRisk,
    required this.sprayWindow,
    required this.fetchedAt,
    required this.locationName,
  });

  final String farmId;
  final WeatherCondition condition;
  final double tempC;
  final double feelsLikeC;
  final double humidity;         // percentage 0–100
  final double windKmh;
  final String windDirection;    // N, NE, E, SE, S, SW, W, NW
  final double rainfallMm24h;
  final double rainfallMm7d;
  final int uvIndex;             // 0–11+
  final bool frostRisk;
  final SprayWindow sprayWindow;
  final DateTime fetchedAt;
  final String locationName;

  bool get isSpraySuitable => sprayWindow == SprayWindow.suitable;
}

enum SprayWindow {
  suitable,
  unsuitable,
  marginal,
}

extension SprayWindowX on SprayWindow {
  String get label => switch (this) {
        SprayWindow.suitable => 'Spray Conditions OK',
        SprayWindow.unsuitable => 'Do Not Spray',
        SprayWindow.marginal => 'Marginal — Monitor Wind',
      };
}

class WeatherForecastDay {
  const WeatherForecastDay({
    required this.date,
    required this.condition,
    required this.maxTempC,
    required this.minTempC,
    required this.rainfallMm,
    required this.humidity,
    required this.windKmh,
    required this.frostRisk,
    required this.sprayWindow,
  });

  final DateTime date;
  final WeatherCondition condition;
  final double maxTempC;
  final double minTempC;
  final double rainfallMm;
  final double humidity;
  final double windKmh;
  final bool frostRisk;
  final SprayWindow sprayWindow;

  bool get isRainyDay => rainfallMm > 5.0;
  bool get isHarvestRisk => rainfallMm > 20.0;
}

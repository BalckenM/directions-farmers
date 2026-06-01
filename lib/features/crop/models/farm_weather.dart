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

  factory FarmWeather.fromJson(Map<String, dynamic> json) {
    return FarmWeather(
      farmId: json['farmId'] as String? ?? '',
      condition: WeatherCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => WeatherCondition.sunny,
      ),
      tempC: (json['tempC'] as num?)?.toDouble() ?? 0,
      feelsLikeC: (json['feelsLikeC'] as num?)?.toDouble() ?? 0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0,
      windKmh: (json['windKmh'] as num?)?.toDouble() ?? 0,
      windDirection: json['windDirection'] as String? ?? 'N',
      rainfallMm24h: (json['rainfallMm24h'] as num?)?.toDouble() ?? 0,
      rainfallMm7d: (json['rainfallMm7d'] as num?)?.toDouble() ?? 0,
      uvIndex: json['uvIndex'] as int? ?? 0,
      frostRisk: json['frostRisk'] as bool? ?? false,
      sprayWindow: SprayWindow.values.firstWhere(
        (e) => e.name == json['sprayWindow'],
        orElse: () => SprayWindow.unsuitable,
      ),
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : DateTime.now(),
      locationName: json['locationName'] as String? ?? '',
    );
  }

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

  factory WeatherForecastDay.fromJson(Map<String, dynamic> json) {
    return WeatherForecastDay(
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      condition: WeatherCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => WeatherCondition.sunny,
      ),
      maxTempC: (json['maxTempC'] as num?)?.toDouble() ?? 0,
      minTempC: (json['minTempC'] as num?)?.toDouble() ?? 0,
      rainfallMm: (json['rainfallMm'] as num?)?.toDouble() ?? 0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0,
      windKmh: (json['windKmh'] as num?)?.toDouble() ?? 0,
      frostRisk: json['frostRisk'] as bool? ?? false,
      sprayWindow: SprayWindow.values.firstWhere(
        (e) => e.name == json['sprayWindow'],
        orElse: () => SprayWindow.unsuitable,
      ),
    );
  }

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

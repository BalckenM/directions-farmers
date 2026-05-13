class AdvisoryContent {
  const AdvisoryContent({
    required this.id,
    required this.category,
    this.cropId,
    this.province,
    required this.title,
    required this.summary,
    required this.body,
    required this.tags,
    required this.language,
    required this.publishedAt,
  });

  final String id;
  final String category;
  final String? cropId;
  final String? province;
  final String title;
  final String summary;
  final String body;
  final List<String> tags;
  final String language;
  final DateTime publishedAt;

  factory AdvisoryContent.fromJson(Map<String, dynamic> json) =>
      AdvisoryContent(
        id: json['id'] as String,
        category: json['category'] as String,
        cropId: json['crop_id'] as String?,
        province: json['province'] as String?,
        title: json['title'] as String,
        summary: json['summary'] as String,
        body: json['body'] as String,
        tags: (json['tags'] as List<dynamic>).cast<String>(),
        language: json['language'] as String,
        publishedAt: DateTime.parse(json['published_at'] as String),
      );

  String get categoryLabel => switch (category) {
        'pest_guide' => 'Pest Guide',
        'crop_tip' => 'Crop Tip',
        'climate_advice' => 'Climate',
        'market_insight' => 'Market',
        _ => category,
      };
}

import '../models/advisor_models.dart';
import 'advisor_data_source.dart';

// Rule-based advisor engine — no external LLM.
// Generates advice from farm context, weather, and crop data.
class AdvisorMockDataSource implements AdvisorDataSource {
  static const _kDelay = Duration(milliseconds: 600);

  // ── Interface implementation ──────────────────────────────────────────────

  @override
  Future<AdvisorResponse> getAdvice(AdvisorQuery query) async {
    await Future.delayed(_kDelay);
    return _buildResponse(query);
  }

  @override
  Future<List<AdvisorResponse>> getDailyBriefing(String farmId) async {
    await Future.delayed(_kDelay);
    final now = DateTime.now();
    final ctx = AdvisorContext(
      farmId: farmId,
      rainfallMm7d: 8.2,
      currentTempC: 23.4,
      frostRisk: false,
      sprayWindowLabel: 'suitable',
      province: 'Limpopo',
    );
    // Build 3 top priority topics for the daily briefing.
    final topics = [
      AdvisorTopic.weatherPlanning,
      AdvisorTopic.pestManagement,
      AdvisorTopic.irrigation,
    ];
    return topics
        .map(
          (t) => _buildResponse(
            AdvisorQuery(
              id: 'BRF-${t.name}',
              topic: t,
              context: ctx,
              askedAt: now,
            ),
          ),
        )
        .toList();
  }

  // ── Rule engine ───────────────────────────────────────────────────────────

  AdvisorResponse _buildResponse(AdvisorQuery query) {
    final ctx = query.context;
    return switch (query.topic) {
      AdvisorTopic.weatherPlanning => _weatherAdvice(query, ctx),
      AdvisorTopic.irrigation => _irrigationAdvice(query, ctx),
      AdvisorTopic.pestManagement => _pestAdvice(query, ctx),
      AdvisorTopic.fertilization => _fertilizationAdvice(query, ctx),
      AdvisorTopic.planting => _plantingAdvice(query, ctx),
      AdvisorTopic.harvestReadiness => _harvestAdvice(query, ctx),
      AdvisorTopic.soilHealth => _soilHealthAdvice(query, ctx),
      AdvisorTopic.marketTiming => _marketAdvice(query, ctx),
      AdvisorTopic.generalFarming => _generalAdvice(query, ctx),
    };
  }

  // ── Topic advisors ────────────────────────────────────────────────────────

  AdvisorResponse _weatherAdvice(AdvisorQuery query, AdvisorContext ctx) {
    final hasFrost = ctx.frostRisk ?? false;
    final rainfallHigh = (ctx.rainfallMm7d ?? 0) > 20;
    final sprayOk = ctx.sprayWindowLabel == 'suitable';

    final recs = <AdvisorRecommendation>[];

    if (hasFrost) {
      recs.add(const AdvisorRecommendation(
        title: 'Protect Frost-Sensitive Crops',
        action:
            'Cover tomatoes, peppers, and seedlings with frost cloth or plastic '
            'sheeting before sunset on nights when frost is forecast.',
        rationale:
            'Frost damages cell walls, causing wilting and plant death. '
            'Protection must be in place before temperatures drop below 4°C.',
        priority: AdvisorPriority.immediate,
        timing: 'Before sunset on forecast frost nights',
      ));
      recs.add(const AdvisorRecommendation(
        title: 'Do Not Irrigate Before Frost',
        action:
            'Suspend irrigation the evening before an expected frost. '
            'Wet soil loses heat faster, increasing frost risk at ground level.',
        rationale:
            'Dry soil acts as insulation and retains daytime heat better '
            'than wet soil, protecting roots and crown of plants.',
        priority: AdvisorPriority.immediate,
        timing: '24 hours before frost event',
      ));
      recs.add(const AdvisorRecommendation(
        title: 'Harvest Mature Crops Before Frost',
        action:
            'Prioritise harvesting any crops that are near maturity before '
            'the frost event. Frost-damaged produce cannot be sold.',
        rationale:
            'Frost damage is irreversible. A timely harvest protects income '
            'even if it means harvesting slightly early.',
        priority: AdvisorPriority.soon,
        timing: 'This week before frost arrives',
      ));
    } else if (rainfallHigh) {
      recs.add(const AdvisorRecommendation(
        title: 'Complete Spraying Before Rain',
        action:
            'Finish any pending pesticide or fungicide applications in the '
            'next 24–48 hours before the rain event arrives.',
        rationale:
            'Rain washes off recently applied products, reducing efficacy. '
            'Re-application wastes inputs and increases costs.',
        priority: AdvisorPriority.immediate,
        timing: 'Next 24–48 hours',
      ));
      recs.add(const AdvisorRecommendation(
        title: 'Postpone Fertilizer Application',
        action:
            'Do not apply granular or liquid fertilizer until after the rain '
            'event and soil has drained adequately.',
        rationale:
            'Heavy rain leaches nitrogen, especially from sandy soils. '
            'Post-rain application captures moisture for dissolution and uptake.',
        priority: AdvisorPriority.soon,
        timing: 'After the rain event passes',
      ));
      recs.add(const AdvisorRecommendation(
        title: 'Inspect Drainage Channels',
        action:
            'Check and clear field drainage channels before the rain to '
            'prevent waterlogging and root damage.',
        rationale:
            'Flooded roots deprive plants of oxygen within hours, '
            'causing root rot and permanent yield damage.',
        priority: AdvisorPriority.immediate,
        timing: 'Today',
      ));
    } else if (sprayOk) {
      recs.add(const AdvisorRecommendation(
        title: 'Ideal Spray Window — Act Now',
        action:
            'Wind speed is below 15 km/h and no rain is forecast for 48 hours. '
            'Complete all pending pesticide, herbicide, and fungicide applications.',
        rationale:
            'Optimal spray conditions: low wind prevents drift, '
            'no rain means products stay on leaves. Opportunities like this '
            'are valuable in high-rainfall seasons.',
        priority: AdvisorPriority.immediate,
        timing: 'Today and tomorrow',
      ));
      recs.add(const AdvisorRecommendation(
        title: 'Scout Before Spraying',
        action:
            'Walk your fields and identify actual pest/disease pressure '
            'before applying — only spray what is needed.',
        rationale:
            'Targeted application reduces input costs and preserves '
            'beneficial insects (natural pest enemies).',
        priority: AdvisorPriority.soon,
        timing: 'Before spray application',
      ));
    } else {
      recs.add(const AdvisorRecommendation(
        title: 'Monitor 7-Day Forecast Daily',
        action:
            'Check weather forecasts every morning and plan activities '
            'around forecast spray windows.',
        rationale:
            'In autumn, weather patterns change rapidly in Limpopo. '
            'Daily monitoring allows you to seize opportunities.',
        priority: AdvisorPriority.planned,
        timing: 'Ongoing',
      ));
    }

    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-WTH-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.weatherPlanning,
      headline: hasFrost
          ? 'Frost Alert — Protect Your Crops Tonight'
          : rainfallHigh
              ? 'Rain Coming — Complete Spraying in the Next 48 Hours'
              : sprayOk
                  ? 'Good Spray Window Open — Conditions Are Ideal'
                  : 'Weather Stable — Monitor for Changes',
      explanation: hasFrost
          ? 'Frost is forecast within the next 10 days. Frost-sensitive crops '
              'like tomatoes, peppers, and seedlings need protection now. '
              'Mature crops should be harvested before the frost event.'
          : rainfallHigh
              ? 'Significant rainfall (${(ctx.rainfallMm7d ?? 0).round()}mm '
                  'in the past 7 days) is making field operations difficult. '
                  'Plan activities around the forecast to maximise efficiency.'
              : sprayOk
                  ? 'Current conditions are ideal for spraying. Wind is light '
                      '(${ctx.currentTempC?.round() ?? 23}°C, suitable spray window). '
                      'Use this window to complete pending applications.'
                  : 'Weather conditions are stable for now. Keep monitoring '
                      'the 7-day forecast to plan your activities effectively.',
      recommendations: recs,
      confidence: hasFrost || rainfallHigh ? AdvisorConfidence.high : AdvisorConfidence.medium,
      generatedAt: DateTime.now(),
    );
  }

  AdvisorResponse _irrigationAdvice(AdvisorQuery query, AdvisorContext ctx) {
    final rainfallMm = ctx.rainfallMm7d ?? 0;
    final hasFrost = ctx.frostRisk ?? false;
    final cropType = ctx.cropType?.toLowerCase();

    final recs = <AdvisorRecommendation>[];

    if (rainfallMm > 25) {
      recs.add(const AdvisorRecommendation(
        title: 'Suspend Irrigation',
        action:
            'Stop scheduled irrigation — recent rainfall has exceeded crop '
            'water requirements. Irrigating now risks waterlogging and root rot.',
        rationale:
            'Excess soil moisture reduces oxygen in the root zone. '
            'Over-irrigation also leaches nutrients below root depth.',
        priority: AdvisorPriority.immediate,
        timing: 'Until soil moisture drops back to field capacity',
      ));
    } else if (rainfallMm < 5) {
      recs.add(AdvisorRecommendation(
        title: 'Increase Irrigation Frequency',
        action:
            'Rainfall has been very low (${rainfallMm.round()}mm in 7 days). '
            'Increase irrigation to maintain soil moisture in the top 30 cm '
            'at 60–80% of field capacity.',
        rationale:
            'Water stress during critical growth stages (flowering, grain fill) '
            'causes irreversible yield loss. Early moisture stress also '
            'increases susceptibility to pests and disease.',
        priority: AdvisorPriority.immediate,
        timing: 'Starting today',
      ));
    }

    if (hasFrost) {
      recs.add(const AdvisorRecommendation(
        title: 'Avoid Evening Irrigation Before Frost',
        action:
            'Do not irrigate in the evening on days when frost is forecast. '
            'Schedule irrigations for early morning only.',
        rationale:
            'Wet soils and wet leaves lose heat faster at night, '
            'increasing the frost damage risk to sensitive crops.',
        priority: AdvisorPriority.immediate,
        timing: 'On all frost-risk nights',
      ));
    }

    if (cropType == 'maize') {
      recs.add(const AdvisorRecommendation(
        title: 'Critical Irrigation Timing for Maize',
        action:
            'Ensure adequate soil moisture during tasselling and silking '
            '(VT–R2 stages). Even one day of wilting during silk emergence '
            'can reduce yield by 10–25%.',
        rationale:
            'Tasselling and silking are the most water-sensitive stages in '
            'maize. Pollen viability drops dramatically under heat and drought stress.',
        priority: AdvisorPriority.planned,
        timing: 'Monitor closely at tasselling',
      ));
    } else if (cropType == 'tomato') {
      recs.add(const AdvisorRecommendation(
        title: 'Consistent Moisture Prevents Blossom End Rot',
        action:
            'Maintain consistent soil moisture for tomatoes — avoid cycles '
            'of drought then flood. Mulch soil surface to reduce evaporation.',
        rationale:
            'Irregular watering causes calcium uptake failure, '
            'resulting in blossom end rot (BER) — a common SA problem '
            'in summer tomatoes.',
        priority: AdvisorPriority.planned,
        timing: 'Throughout the growing season',
      ));
    }

    recs.add(const AdvisorRecommendation(
      title: 'Inspect Irrigation System Weekly',
      action:
          'Walk the irrigation lines weekly and check for blocked emitters, '
          'leaks, and pressure irregularities. Repair faults immediately.',
      rationale:
          'A single blocked emitter creates a dry spot that leads to yield '
          'loss from an otherwise well-irrigated field.',
      priority: AdvisorPriority.planned,
      timing: 'Weekly inspection routine',
    ));

    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-IRR-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.irrigation,
      headline: rainfallMm > 25
          ? 'Recent Rain Sufficient — Suspend Irrigation'
          : rainfallMm < 5
              ? 'Dry Conditions — Increase Irrigation Frequency'
              : 'Irrigation Management Looks Adequate',
      explanation:
          'Based on ${rainfallMm.round()}mm of rainfall in the past 7 days '
          'and current weather conditions${cropType != null ? " for your $cropType crop" : ""}, '
          'here are tailored irrigation recommendations for your farm.',
      recommendations: recs,
      confidence: AdvisorConfidence.high,
      generatedAt: DateTime.now(),
    );
  }

  AdvisorResponse _pestAdvice(AdvisorQuery query, AdvisorContext ctx) {
    final pests = ctx.activePestNames ?? [];
    final cropType = ctx.cropType?.toLowerCase();
    final rainfallHigh = (ctx.rainfallMm7d ?? 0) > 15;
    final sprayOk = ctx.sprayWindowLabel == 'suitable';

    final recs = <AdvisorRecommendation>[];

    if (pests.isNotEmpty) {
      recs.add(AdvisorRecommendation(
        title: 'Active Pest Observations Require Attention',
        action:
            'You have ${pests.length} active pest observation(s): '
            '${pests.take(3).join(", ")}. '
            'Assess severity and apply targeted treatments if thresholds are exceeded.',
        rationale:
            'Early intervention when pest populations are small prevents '
            'exponential population growth and reduces treatment costs.',
        priority: AdvisorPriority.immediate,
        timing: 'Within 24–48 hours',
      ));
    }

    if (rainfallHigh) {
      recs.add(const AdvisorRecommendation(
        title: 'Monitor for Fungal Disease After Rain',
        action:
            'Scout fields 3–5 days after rain events for early symptoms of '
            'grey leaf spot (maize), rust (soybean), or late blight (tomato/potato).',
        rationale:
            'Warm, moist conditions following rain create ideal germination '
            'conditions for fungal spores. Early detection enables timely '
            'low-cost intervention.',
        priority: AdvisorPriority.soon,
        timing: '3–5 days after rain',
      ));
    }

    if (cropType == 'maize') {
      recs.add(const AdvisorRecommendation(
        title: 'Check Whorls for Fall Armyworm',
        action:
            'Inspect the whorls of 20 maize plants per field per week. '
            'Look for fresh sawdust-like frass and ragged leaf damage. '
            'Treat when > 20% of plants show whorl damage.',
        rationale:
            'Fall armyworm can devastate a maize field within 2 weeks if '
            'unchecked. The economic threshold guideline is set at 20% '
            'infestation to justify the cost of treatment.',
        priority: AdvisorPriority.soon,
        timing: 'Weekly scouting from V4 stage',
      ));
    } else if (cropType == 'soybean') {
      recs.add(const AdvisorRecommendation(
        title: 'Scout for Soybean Rust From R1 Stage',
        action:
            'At first flowering (R1), inspect the underside of lower canopy '
            'leaves with a hand lens. Look for small tan lesions with spore '
            'masses. Act immediately at first detection.',
        rationale:
            'Soybean rust is the most economically destructive soybean '
            'disease in SA. Delay in treatment can cause 50–80% yield loss.',
        priority: AdvisorPriority.immediate,
        timing: 'From R1 stage onwards',
      ));
    }

    if (sprayOk) {
      recs.add(const AdvisorRecommendation(
        title: 'Current Conditions Suitable for Spraying',
        action:
            'Wind is below 15 km/h. Apply pending pesticide treatments now '
            'while conditions are favourable for good coverage and uptake.',
        rationale:
            'Low wind ensures product stays on target. '
            'No rain in the next 24 hours allows the product to be absorbed.',
        priority: AdvisorPriority.soon,
        timing: 'Next 24–48 hours',
      ));
    }

    recs.add(const AdvisorRecommendation(
      title: 'Weekly Scouting Programme',
      action:
          'Walk each field in a W or Z pattern every 7 days. '
          'Record pest counts and disease symptoms in your field diary. '
          'Compare to economic thresholds before deciding to spray.',
      rationale:
          'Consistent monitoring is the foundation of integrated pest '
          'management. Reactive spraying without monitoring wastes money.',
      priority: AdvisorPriority.planned,
      timing: 'Every 7 days throughout the season',
    ));

    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-PEST-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.pestManagement,
      headline: pests.isNotEmpty
          ? 'Active Pest Observations Require Monitoring'
          : 'No Active Pests — Maintain Scouting Routine',
      explanation:
          'Integrated pest management (IPM) combines monitoring, biological '
          'control, and targeted chemical treatments. Scout before you spray '
          'to confirm thresholds are exceeded and protect beneficial insects.',
      recommendations: recs,
      confidence: pests.isNotEmpty ? AdvisorConfidence.high : AdvisorConfidence.medium,
      generatedAt: DateTime.now(),
    );
  }

  AdvisorResponse _fertilizationAdvice(AdvisorQuery query, AdvisorContext ctx) {
    final rainfallMm = ctx.rainfallMm7d ?? 0;
    final cropType = ctx.cropType?.toLowerCase();

    final recs = <AdvisorRecommendation>[];

    if (rainfallMm > 25) {
      recs.add(const AdvisorRecommendation(
        title: 'Delay Fertilizer After Heavy Rain',
        action:
            'Wait at least 3 days after heavy rain before applying granular '
            'or liquid nitrogen. Let soils drain to field capacity.',
        rationale:
            'Applying nitrogen to waterlogged or rain-saturated soils '
            'causes leaching and denitrification losses. '
            'Wait for soil to drain to reduce waste.',
        priority: AdvisorPriority.soon,
        timing: '3–5 days after rain',
      ));
    }

    recs.add(const AdvisorRecommendation(
      title: 'Base Fertilizer on Soil Analysis',
      action:
          'If you do not have a recent soil analysis (< 3 years old), '
          'take soil samples now and send to a certified SA lab. '
          'Fertilizer recommendations without soil data risk over- or under-application.',
      rationale:
          'SA soils vary widely in pH, P, K, and micronutrient status. '
          'Blanket fertilizer rates without soil data waste money and '
          'may harm crops or the environment.',
      priority: AdvisorPriority.planned,
      timing: 'Before next planting season',
    ));

    if (cropType == 'maize') {
      recs.add(const AdvisorRecommendation(
        title: 'Split Nitrogen Applications for Maize',
        action:
            'Apply 1/3 of total N at planting and 2/3 as a side-dress at '
            'V6 (6-leaf stage). This reduces leaching and improves uptake efficiency.',
        rationale:
            'Maize takes up most nitrogen from V6 onwards. Splitting '
            'reduces N at risk of leaching during early-season rains.',
        priority: AdvisorPriority.planned,
        timing: 'At planting and at V6 stage',
      ));
    } else if (cropType == 'tomato') {
      recs.add(const AdvisorRecommendation(
        title: 'Calcium and Boron for Tomatoes',
        action:
            'Apply foliar calcium nitrate (0.5%) and boron (0.1%) at '
            'flowering stage to prevent blossom end rot and improve fruit set.',
        rationale:
            'Calcium deficiency during rapid fruit growth causes blossom '
            'end rot — a major quality and income loss in SA tomato production.',
        priority: AdvisorPriority.soon,
        timing: 'At first flowering and every 2 weeks during fruiting',
      ));
    }

    recs.add(const AdvisorRecommendation(
      title: 'Foliar Diagnosis Before Top-Dressing',
      action:
          'Take leaf samples for foliar analysis if plants show unusual '
          'yellowing or growth abnormalities. Correct deficiency before top-dressing.',
      rationale:
          'Applying the wrong nutrient compounds the problem. '
          'Foliar analysis gives a precise deficiency diagnosis.',
      priority: AdvisorPriority.planned,
      timing: 'If visual deficiency symptoms appear',
    ));

    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-FERT-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.fertilization,
      headline: 'Fertilization Recommendations for Optimal Yield',
      explanation:
          'Balanced nutrition is critical for yield and quality. '
          'Base your programme on soil analysis and crop stage. '
          'Avoid applying nitrogen before or during heavy rain events.',
      recommendations: recs,
      confidence: AdvisorConfidence.medium,
      generatedAt: DateTime.now(),
      disclaimer:
          'Recommendations are general guidelines. Always confirm with a '
          'certified agricultural advisor and current soil analysis results.',
    );
  }

  AdvisorResponse _plantingAdvice(AdvisorQuery query, AdvisorContext ctx) {
    final province = ctx.province ?? 'Limpopo';
    final cropType = ctx.cropType?.toLowerCase();

    final recs = <AdvisorRecommendation>[
      AdvisorRecommendation(
        title: 'Optimal Planting Dates for $province',
        action:
            'In $province, summer crops (maize, soybean, sorghum) are '
            'best planted between mid-October and mid-December. '
            'Planting too late reduces growing season and increases frost risk.',
        rationale:
            'Planting within the recommended window maximises days of '
            'growth before the dry season and frost period.',
        priority: AdvisorPriority.planned,
        timing: 'October–December for summer crops',
      ),
    ];

    if (cropType == 'maize') {
      recs.add(const AdvisorRecommendation(
        title: 'Maize Plant Population Target',
        action:
            'Target 30 000–40 000 plants/ha for dryland maize. '
            'Irrigated maize can support 45 000–55 000 plants/ha. '
            'Use a planter calibration chart for your target population.',
        rationale:
            'Planting population directly impacts yield. Too sparse reduces '
            'light interception; too dense causes lodging and ear leaf competition.',
        priority: AdvisorPriority.planned,
        timing: 'Before planting — planter calibration',
      ));
    }

    recs.add(const AdvisorRecommendation(
      title: 'Soil Temperature Before Planting',
      action:
          'Do not plant maize or soybean until soil temperature at 50 mm '
          'depth reaches ≥ 12°C consistently (10-day average). '
          'Cold soils cause poor germination and seedling diseases.',
      rationale:
          'Germination enzymes are temperature-sensitive. Cold soil '
          'means slow, irregular germination and higher damping-off risk.',
      priority: AdvisorPriority.planned,
      timing: 'Check before each planting decision',
    ));

    recs.add(const AdvisorRecommendation(
      title: 'Prepare Seedbed After Rain',
      action:
          'Till and prepare seedbed 7–14 days before planting. '
          'A firm, clod-free seedbed ensures good seed-to-soil contact '
          'for rapid, uniform germination.',
      rationale:
          'Poor seed-to-soil contact is one of the top causes of patchy stands. '
          'Gaps in the plant population are permanent yield losses.',
      priority: AdvisorPriority.planned,
      timing: '7–14 days before intended planting',
    ));

    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-PLNT-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.planting,
      headline: 'Planting Guidelines for ${cropType != null ? cropType[0].toUpperCase() + cropType.substring(1) : "Your Crops"}',
      explanation:
          'Successful planting depends on timing, population, seedbed quality, '
          'and variety selection. Use weather forecasts and soil temperature '
          'to decide the optimal planting date.',
      recommendations: recs,
      confidence: AdvisorConfidence.high,
      generatedAt: DateTime.now(),
    );
  }

  AdvisorResponse _harvestAdvice(AdvisorQuery query, AdvisorContext ctx) {
    final days = ctx.daysToHarvest;
    final hasFrost = ctx.frostRisk ?? false;

    final recs = <AdvisorRecommendation>[];

    if (days != null && days <= 14) {
      recs.add(AdvisorRecommendation(
        title: 'Harvest is Imminent — Prepare Equipment',
        action:
            'With only $days days to harvest, service the combine/harvester '
            'now. Check knife condition, sieve settings, and moisture meter '
            'calibration. Arrange transport and storage.',
        rationale:
            'Equipment failure during harvest costs far more in lost yield '
            'than the cost of preventive maintenance.',
        priority: AdvisorPriority.immediate,
        timing: 'This week',
      ));
    }

    if (hasFrost) {
      recs.add(const AdvisorRecommendation(
        title: 'Harvest Before Frost if Crop is Mature',
        action:
            'Frost damage to mature grain or vegetables is irreversible. '
            'If the crop is within 2 weeks of maturity, consider early harvest '
            'to avoid potential losses.',
        rationale:
            'Even a light frost (< -2°C) can damage grain fill in maize '
            'and cause severe quality loss in vegetables.',
        priority: AdvisorPriority.immediate,
        timing: 'Before forecast frost event',
      ));
    }

    recs.add(const AdvisorRecommendation(
      title: 'Check Grain Moisture Before Harvesting',
      action:
          'Harvest maize at 25–30% moisture and dry to 12.5% for safe storage. '
          'Harvesting too wet causes mould; too dry causes excessive shattering losses.',
      rationale:
          'Grain storage at > 13.5% moisture causes rapid mould growth, '
          'mycotoxin contamination (fumonisin, aflatoxin), and rejection by buyers.',
      priority: AdvisorPriority.planned,
      timing: 'During harvest operations',
    ));

    recs.add(const AdvisorRecommendation(
      title: 'Dry Bins and Storage Before Intake',
      action:
          'Inspect grain silos and bags for moisture, pests, and structural '
          'integrity before the harvest. Clean out old grain and treat with '
          'approved grain protectant.',
      rationale:
          'Stored grain pests (weevils, grain borers) can destroy '
          '50–100% of stored grain within months if left untreated.',
      priority: AdvisorPriority.soon,
      timing: 'Before harvest intake begins',
    ));

    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-HARV-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.harvestReadiness,
      headline: days != null && days <= 14
          ? 'Harvest Imminent — Final Preparations Now'
          : 'Prepare for Harvest Season',
      explanation:
          'Successful harvesting depends on timing, equipment readiness, '
          'and grain quality management. Act on these recommendations '
          'before the critical harvest window opens.',
      recommendations: recs,
      confidence: AdvisorConfidence.high,
      generatedAt: DateTime.now(),
    );
  }

  AdvisorResponse _soilHealthAdvice(AdvisorQuery query, AdvisorContext ctx) {
    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-SOIL-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.soilHealth,
      headline: 'Build Soil Health for Sustainable Yields',
      explanation:
          'SA agricultural soils are under increasing pressure from erosion, '
          'compaction, and declining organic matter. Long-term productivity '
          'depends on soil health investment.',
      recommendations: const [
        AdvisorRecommendation(
          title: 'Test Soil Every 3 Years',
          action:
              'Sample soil at 0–20 cm and 20–40 cm depth. Send to an '
              'accredited SA laboratory. Use results to optimise lime and '
              'fertilizer programmes.',
          rationale:
              'Soil analysis is the cheapest investment in precision farming. '
              'Each R300 spent on testing saves thousands in mis-applied inputs.',
          priority: AdvisorPriority.planned,
          timing: 'Off-season, before next planting season',
        ),
        AdvisorRecommendation(
          title: 'Lime Acid Soils',
          action:
              'If soil pH < 5.5, apply agricultural lime at the recommended '
              'rate to target pH 6.0–6.5. Allow 6 months for lime to react.',
          rationale:
              'Soil pH below 5.5 limits nutrient availability and can cause '
              'aluminium toxicity in sensitive crops (maize, soybeans).',
          priority: AdvisorPriority.planned,
          timing: 'Off-season incorporation with deep tillage',
        ),
        AdvisorRecommendation(
          title: 'Introduce Cover Crops',
          action:
              'Plant legume or grass cover crops in fallow fields to build '
              'organic matter, fix nitrogen, and prevent erosion. '
              'Options: cowpea, lablab, oats, ryegrass.',
          rationale:
              'Cover crops improve soil structure, add organic matter (1–2 t/ha), '
              'and can fix 50–150 kg N/ha (legumes). They also reduce weed pressure.',
          priority: AdvisorPriority.planned,
          timing: 'After main crop harvest',
        ),
        AdvisorRecommendation(
          title: 'Reduce Tillage Intensity',
          action:
              'Consider transitioning to minimum tillage or no-till on fields '
              'with good cover crop history. Reduced tillage preserves soil '
              'structure and reduces erosion.',
          rationale:
              'Excessive tillage destroys soil aggregates and earthworm '
              'populations. No-till soils accumulate organic matter faster.',
          priority: AdvisorPriority.planned,
          timing: 'Implement over 3–5 seasons',
        ),
      ],
      confidence: AdvisorConfidence.high,
      generatedAt: DateTime.now(),
    );
  }

  AdvisorResponse _marketAdvice(AdvisorQuery query, AdvisorContext ctx) {
    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-MKT-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.marketTiming,
      headline: 'Market Timing Strategies for SA Farmers',
      explanation:
          'Selling at the right time can increase farm income by 20–40%. '
          'Monitor SAFEX prices, seasonal patterns, and storage costs '
          'to make informed selling decisions.',
      recommendations: const [
        AdvisorRecommendation(
          title: 'Monitor SAFEX Maize Prices Weekly',
          action:
              'Check South African Futures Exchange (SAFEX) spot and futures '
              'prices weekly. Compare to your break-even cost of production '
              'before making selling decisions.',
          rationale:
              'SA grain prices are influenced by global markets (CBOT), '
              'the ZAR exchange rate, and local supply. Timing affects income '
              'significantly across a single season.',
          priority: AdvisorPriority.planned,
          timing: 'Weekly during the marketing season',
        ),
        AdvisorRecommendation(
          title: 'Sell in Multiple Tranches',
          action:
              'Avoid selling the entire crop at one time. Sell in 3–5 tranches '
              'over the marketing period to average out price risk.',
          rationale:
              'Price averaging reduces the risk of selling at a seasonal low. '
              'SA maize prices are most volatile in April–August.',
          priority: AdvisorPriority.planned,
          timing: 'Plan before harvest',
        ),
        AdvisorRecommendation(
          title: 'Explore Forward Contracts',
          action:
              'Contact your grain buyer or cooperative about fixing a portion '
              'of your expected harvest at current prices via a forward contract.',
          rationale:
              'Forward contracts lock in a price now, protecting income '
              'against price drops after harvest when supply is high.',
          priority: AdvisorPriority.planned,
          timing: '3–6 months before expected harvest',
        ),
      ],
      confidence: AdvisorConfidence.medium,
      generatedAt: DateTime.now(),
      disclaimer:
          'Market advice is general guidance only. Consult your grain buyer '
          'or agricultural economist for formal price risk management.',
    );
  }

  AdvisorResponse _generalAdvice(AdvisorQuery query, AdvisorContext ctx) {
    final province = ctx.province ?? 'South Africa';
    return AdvisorResponse(
      queryId: query.id,
      responseId: 'RESP-GEN-${DateTime.now().millisecondsSinceEpoch}',
      topic: AdvisorTopic.generalFarming,
      headline: 'Best Practices for Profitable $province Farming',
      explanation:
          'South African farming faces unique challenges: variable rainfall, '
          'high input costs, and demanding export standards. '
          'These foundational practices build long-term resilience.',
      recommendations: const [
        AdvisorRecommendation(
          title: 'Keep Accurate Farm Records',
          action:
              'Record all inputs, yields, pest observations, and expenses '
              'in a farm diary or app. Review records monthly.',
          rationale:
              'Records enable cost tracking, compliance (GLOBALG.A.P.), '
              'and evidence for crop insurance and finance applications.',
          priority: AdvisorPriority.planned,
          timing: 'Daily recording — review monthly',
        ),
        AdvisorRecommendation(
          title: 'Join a Farmers Association',
          action:
              'Connect with Agri SA, Grain SA, or your local commodity '
              'organisation for market information, training, and advocacy.',
          rationale:
              'Collective bargaining and shared knowledge networks '
              'reduce individual farm risk and improve access to markets.',
          priority: AdvisorPriority.planned,
          timing: 'Anytime',
        ),
        AdvisorRecommendation(
          title: 'Invest in Training Annually',
          action:
              'Attend at least one Agri-training workshop or field day per '
              'year. Topics to prioritise: soil health, IPM, and water management.',
          rationale:
              'Continuous learning keeps farming practices up to date '
              'with new varieties, technologies, and market requirements.',
          priority: AdvisorPriority.planned,
          timing: 'Off-season planning',
        ),
      ],
      confidence: AdvisorConfidence.medium,
      generatedAt: DateTime.now(),
    );
  }
}

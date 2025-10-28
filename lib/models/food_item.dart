// lib/models/food_item.dart

class FoodItem {
  final int? fdcId; // oanvänd, men kvar för kompatibilitet
  final String name;
  final String? brand;

  /// Näringsvärden per 100 g (från Open Food Facts)
  final double? caloriesKcal;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  /// Serveringsstorlek (t.ex. 30 g eller 1 bar (50 g))
  final double? servingSize;
  final String? servingUnit;

  /// Thumbnail eller front-bild
  final String? imageThumbUrl;

  FoodItem({
    required this.name,
    this.brand,
    this.caloriesKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.servingSize,
    this.servingUnit,
    this.imageThumbUrl,
    this.fdcId,
  });

  // -------------------------------
  // Hjälpfunktioner
  // -------------------------------

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().replaceAll(',', '.').trim();
    return double.tryParse(s);
  }

  /// Försök tolka "serving_size" från OFF, t.ex. "30 g", "1 bar (50 g)"
  static (double? size, String? unit) _parseServing(String? servingSizeRaw) {
    if (servingSizeRaw == null || servingSizeRaw.trim().isEmpty) {
      return (null, null);
    }
    final str = servingSizeRaw.toLowerCase();

    // Hitta "xx g" eller "xx ml"
    final reSimple = RegExp(r'(\d+(?:[.,]\d+)?)\s*(g|gram|ml|l)');
    final m1 = reSimple.firstMatch(str);
    if (m1 != null) {
      final size = _toDouble(m1.group(1));
      var unit = m1.group(2);
      if (unit == 'gram') unit = 'g';
      if (unit == 'l') unit = 'L';
      return (size, unit);
    }

    // Fångar första talet om inget annat hittas
    final reAnyNum = RegExp(r'(\d+(?:[.,]\d+)?)');
    final m2 = reAnyNum.firstMatch(str);
    if (m2 != null) {
      final size = _toDouble(m2.group(1));
      return (size, null);
    }

    return (null, null);
  }

  // -------------------------------
  // Open Food Facts parser
  // -------------------------------
  factory FoodItem.fromOpenFoodFactsProduct(Map<String, dynamic> p) {
    final nutr = (p['nutriments'] as Map?) ?? const {};
    // kcal
    double? kcal = _toDouble(nutr['energy-kcal_100g']);
    kcal ??= (() {
      final kJ = _toDouble(nutr['energy_100g']);
      return kJ == null ? null : kJ / 4.184;
    })();

    final protein = _toDouble(nutr['proteins_100g']);
    final carbs = _toDouble(nutr['carbohydrates_100g']);
    final fat = _toDouble(nutr['fat_100g']);

    final servingRaw = (p['serving_size'] as String?)?.trim();
    final (sv, su) = _parseServing(servingRaw);

    return FoodItem(
      name: (p['product_name'] as String?)?.trim().isNotEmpty == true
          ? (p['product_name'] as String).trim()
          : (p['generic_name'] as String?) ?? 'Unknown product',
      brand: (p['brands'] as String?)?.split(',').first.trim(),
      caloriesKcal: kcal,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      servingSize: sv,
      servingUnit: su,
      imageThumbUrl: (p['image_front_small_url'] as String?) ??
          (p['image_front_url'] as String?),
      fdcId: null,
    );
  }

  // -------------------------------
  // Skalar om värden till valfri gram-mängd
  // -------------------------------
  Map<String, double?> scaledValues(double grams) {
    final factor = grams / 100;
    return {
      'kcal': caloriesKcal == null ? null : caloriesKcal! * factor,
      'protein': proteinG == null ? null : proteinG! * factor,
      'carbs': carbsG == null ? null : carbsG! * factor,
      'fat': fatG == null ? null : fatG! * factor,
    };
  }
}

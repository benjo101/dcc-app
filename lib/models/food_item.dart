// lib/models/food_item.dart
class FoodItem {
  final int fdcId;
  final String name;
  final String? brand;
  final double? caloriesKcal; // per 100g eller per serving, beroende på källa
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? servingSize;
  final String? servingUnit;

  FoodItem({
    required this.fdcId,
    required this.name,
    this.brand,
    this.caloriesKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.servingSize,
    this.servingUnit,
  });

  factory FoodItem.fromFoodDataCentralSearchJson(Map<String, dynamic> json) {
    // FDC “foods” element (v1/foods/search)
    final nutrients = (json['foodNutrients'] as List?) ?? [];

    double? getNutrient(String nameContains, {String? unit}) {
      // Sök på namn (t.ex. "Energy", "Protein", "Carbohydrate, by difference", "Total lipid (fat)")
      // Vissa poster har namn, andra “nutrientName”.
      for (final n in nutrients) {
        final nn = (n['nutrientName'] ?? n['name'] ?? '') as String;
        final u = (n['unitName'] ?? n['unit'] ?? '') as String;
        if (nn.toLowerCase().contains(nameContains.toLowerCase())) {
          if (unit != null && u.toLowerCase() != unit.toLowerCase()) {
            continue;
          }
          final v = (n['value'] as num?)?.toDouble();
          if (v != null) return v;
        }
      }
      return null;
    }

    // Energy kan rapporteras i kJ/kcal. Försök kcal först, annars konvertera från kJ.
    double? kcal = getNutrient('Energy', unit: 'KCAL');
    kcal ??= (() {
      final kj = getNutrient('Energy', unit: 'KJ');
      if (kj != null) return kj / 4.184;
      return null;
    })();

    final protein = getNutrient('Protein');
    final carbs = getNutrient('Carbohydrate');
    final fat = getNutrient('Total lipid');

    return FoodItem(
      fdcId: (json['fdcId'] as num).toInt(),
      name: (json['description'] as String?)?.trim() ?? 'Unknown',
      brand: (json['brandOwner'] as String?)?.trim(),
      caloriesKcal: kcal,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      servingSize: (json['servingSize'] as num?)?.toDouble(),
      servingUnit: (json['servingSizeUnit'] as String?),
    );
  }
}

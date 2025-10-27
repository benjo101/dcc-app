// lib/models/diary_entry.dart
import 'food_item.dart';

enum MealType { breakfast, lunch, dinner, snacks }

String mealTypeLabel(MealType m) {
  switch (m) {
    case MealType.breakfast: return 'Breakfast';
    case MealType.lunch: return 'Lunch';
    case MealType.dinner: return 'Dinner';
    case MealType.snacks: return 'Snacks';
  }
}

class DiaryEntry {
  final String id;
  final DateTime date;        // Endast datumets dag räknas
  final MealType meal;
  final FoodItem food;
  final double grams;         // användarens valda gram

  DiaryEntry({
    required this.id,
    required this.date,
    required this.meal,
    required this.food,
    required this.grams,
  });

  // Antag: food.* är per 100 g om serving saknas. Skala efter grams.
  double _scale(double? per100g) {
    if (per100g == null) return 0;
    return per100g * (grams / 100.0);
  }

  double get kcal     => _scale(food.caloriesKcal);
  double get proteinG => _scale(food.proteinG);
  double get carbsG   => _scale(food.carbsG);
  double get fatG     => _scale(food.fatG);

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': DateTime(date.year, date.month, date.day).toIso8601String(),
    'meal': meal.index,
    'food': {
      'fdcId': food.fdcId,
      'name': food.name,
      'brand': food.brand,
      'caloriesKcal': food.caloriesKcal,
      'proteinG': food.proteinG,
      'carbsG': food.carbsG,
      'fatG': food.fatG,
      'servingSize': food.servingSize,
      'servingUnit': food.servingUnit,
    },
    'grams': grams,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> j) {
    final f = j['food'] as Map<String, dynamic>;
    return DiaryEntry(
      id: j['id'] as String,
      date: DateTime.parse(j['date'] as String),
      meal: MealType.values[(j['meal'] as num).toInt()],
      food: FoodItem(
        fdcId: (f['fdcId'] as num).toInt(),
        name: f['name'] as String,
        brand: f['brand'] as String?,
        caloriesKcal: (f['caloriesKcal'] as num?)?.toDouble(),
        proteinG: (f['proteinG'] as num?)?.toDouble(),
        carbsG: (f['carbsG'] as num?)?.toDouble(),
        fatG: (f['fatG'] as num?)?.toDouble(),
        servingSize: (f['servingSize'] as num?)?.toDouble(),
        servingUnit: f['servingUnit'] as String?,
      ),
      grams: (j['grams'] as num).toDouble(),
    );
  }
}

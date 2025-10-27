// lib/providers/diary_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class DayTotals {
  final double kcal, proteinG, carbsG, fatG;
  const DayTotals({required this.kcal, required this.proteinG, required this.carbsG, required this.fatG});
}

class DiaryProvider extends ChangeNotifier {
  static const _kEntriesKey = 'diary_entries_v1';
  static const _kCalGoalKey = 'calorie_goal_v1';

  final Map<String, List<DiaryEntry>> _byDate = {};
  double _calorieGoal = 2400;

  DiaryProvider() {
    _load();
  }

  double get calorieGoal => _calorieGoal;
  set calorieGoal(double v) {
    _calorieGoal = v.clamp(800, 6000);
    _persist();
    notifyListeners();
  }

  // Helpers
  String _keyForDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  List<DiaryEntry> entriesFor(DateTime d) {
    return List.unmodifiable(_byDate[_keyForDate(d)] ?? const []);
  }

  List<DiaryEntry> entriesForMeal(DateTime d, MealType meal) {
    return entriesFor(d).where((e) => e.meal == meal).toList();
  }

  DayTotals totalsFor(DateTime d) {
    final list = entriesFor(d);
    double k=0, p=0, c=0, f=0;
    for (final e in list) {
      k += e.kcal; p += e.proteinG; c += e.carbsG; f += e.fatG;
    }
    return DayTotals(kcal: k, proteinG: p, carbsG: c, fatG: f);
  }

  DayTotals totalsForMeal(DateTime d, MealType meal) {
    final list = entriesForMeal(d, meal);
    double k=0, p=0, c=0, f=0;
    for (final e in list) {
      k += e.kcal; p += e.proteinG; c += e.carbsG; f += e.fatG;
    }
    return DayTotals(kcal: k, proteinG: p, carbsG: c, fatG: f);
  }

  void addEntry(DiaryEntry entry) {
    final key = _keyForDate(entry.date);
    final list = _byDate.putIfAbsent(key, () => []);
    list.add(entry);
    _persist();
    notifyListeners();
  }

  void removeEntry(String id, DateTime date) {
    final key = _keyForDate(date);
    _byDate[key]?.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _calorieGoal = sp.getDouble(_kCalGoalKey) ?? 2400;
    final raw = sp.getString(_kEntriesKey);
    if (raw != null) {
      final map = json.decode(raw) as Map<String, dynamic>;
      map.forEach((dateKey, listJson) {
        final list = (listJson as List).cast<Map<String, dynamic>>();
        _byDate[dateKey] = list.map((j) => DiaryEntry.fromJson(j)).toList();
      });
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kCalGoalKey, _calorieGoal);
    final out = <String, List<Map<String, dynamic>>>{};
    _byDate.forEach((k, v) {
      out[k] = v.map((e) => e.toJson()).toList();
    });
    await sp.setString(_kEntriesKey, json.encode(out));
  }
}

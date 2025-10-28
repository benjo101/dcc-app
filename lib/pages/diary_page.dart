// lib/pages/diary_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../widgets/macro_card.dart';
import 'nutrition_search_page.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final prov = context.watch<DiaryProvider>();
    final totals = prov.totalsFor(today);

    const pGoal = 180.0, cGoal = 400.0, fGoal = 80.0;
    final pProg = totals.proteinG / pGoal;
    final cProg = totals.carbsG / cGoal;
    final fProg = totals.fatG / fGoal;
    final kcalProg =
        prov.calorieGoal <= 0 ? 0 : (totals.kcal / prov.calorieGoal);

    String g(double v) =>
        v.toStringAsFixed(v % 1 == 0 ? 0 : 1).replaceAll('.0', '');

    Widget header() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Today',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            Text('Overview',
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            Text('DCC',
                style: TextStyle(
                    color: Color(0xFFFFD347),
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
          ],
        ),
      );
    }

    Widget macroSection() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            MacroCard(
              title: 'Protein',
              value: '${g(totals.proteinG)}',
              target: '${g(pGoal)}g',
              progress: pProg,
            ),
            MacroCard(
              title: 'Carbs',
              value: '${g(totals.carbsG)}',
              target: '${g(cGoal)}g',
              progress: cProg,
            ),
            MacroCard(
              title: 'Fat',
              value: '${g(totals.fatG)}',
              target: '${g(fGoal)}g',
              progress: fProg,
            ),
            MacroCard(
              title: 'KCAL',
              value: '${g(totals.kcal)}',
              target: '${g(prov.calorieGoal)}',
              progress: kcalProg.toDouble(),
              isKcal: true,
            ),
          ],
        ),
      );
    }

    Widget programsBanner() {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Text('Programs out!',
            style: TextStyle(
                color: Color(0xFFFFD347),
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      );
    }

    Widget mealSection(MealType meal) {
      final list = prov.entriesForMeal(today, meal);
      final mTot = prov.totalsForMeal(today, meal);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          color: const Color(0xFF1A1A1A),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(mealTypeLabel(meal),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  const Spacer(),
                  Text('${mTot.kcal.round()}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Text('kcal',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Color(0xFFFFD347)),
                    tooltip: 'Add food',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NutritionSearchPage(preselectedMeal: meal),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 8),
                if (list.isEmpty)
                  const Text('No foods added',
                      style: TextStyle(color: Colors.white54))
                else
                  ...list.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(e.food.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Text('${e.kcal.round()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('More',
                        style: TextStyle(
                            color: Color(0xFFFFD347),
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        children: [
          header(),
          programsBanner(),
          macroSection(),
          const SizedBox(height: 10),
          mealSection(MealType.breakfast),
          mealSection(MealType.lunch),
          mealSection(MealType.dinner),
          mealSection(MealType.snacks),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

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

    String g(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

    Widget topHeader() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text('Today',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Overview')),
            const SizedBox(width: 4),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4C6FFF),
              child: Text('D',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    double kcalProg =
        prov.calorieGoal <= 0 ? 0 : (totals.kcal / prov.calorieGoal);
    const pGoal = 180.0, cGoal = 400.0, fGoal = 80.0;
    final pProg = totals.proteinG / pGoal;
    final cProg = totals.carbsG / cGoal;
    final fProg = totals.fatG / fGoal;

    Widget macroGrid() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MacroCard(
                title: 'Protein',
                value: '${g(totals.proteinG)}g',
                target: '${g(pGoal)}g',
                progress: pProg),
            MacroCard(
                title: 'Carbs',
                value: '${g(totals.carbsG)}g',
                target: '${g(cGoal)}g',
                progress: cProg),
            MacroCard(
                title: 'Fat',
                value: '${g(totals.fatG)}g',
                target: '${g(fGoal)}g',
                progress: fProg),
            MacroCard(
                title: 'KCAL',
                value: g(totals.kcal),
                target: g(prov.calorieGoal),
                progress: kcalProg,
                isKcal: true),
          ],
        ),
      );
    }

    Widget goalRow() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text('Goal', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            InkWell(
              onTap: () async {
                final controller = TextEditingController(
                    text: prov.calorieGoal.round().toString());
                final v = await showDialog<double>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Set daily kcal goal'),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: 'e.g. 2400'),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            final vv =
                                double.tryParse(controller.text.trim());
                            Navigator.pop(context, vv);
                          },
                          child: const Text('Save')),
                    ],
                  ),
                );
                if (v != null) prov.calorieGoal = v;
              },
              child: Text('${prov.calorieGoal.round()} kcal',
                  style:
                      const TextStyle(decoration: TextDecoration.underline)),
            ),
            const Spacer(),
            Text('${totals.kcal.round()} / ${prov.calorieGoal.round()}'),
          ],
        ),
      );
    }

    Widget mealSection(MealType meal) {
      final list = prov.entriesForMeal(today, meal);
      final mTot = prov.totalsForMeal(today, meal);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(mealTypeLabel(meal),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const Spacer(),
                  Text('${mTot.kcal.round()} kcal',
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Color(0xFF4C6FFF)),
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
                const SizedBox(height: 6),
                Text(
                  '${g(mTot.proteinG)}g P • ${g(mTot.carbsG)}g C • ${g(mTot.fatG)}g F',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                if (list.isEmpty)
                  const Text('Nothing added yet',
                      style: TextStyle(color: Colors.black54))
                else
                  ...list.map((e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(e.food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text('${e.grams.round()} g • '
                            '${g(e.proteinG)}g P • ${g(e.carbsG)}g C • ${g(e.fatG)}g F'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${e.kcal.round()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  prov.removeEntry(e.id, today),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: const Text('DCC',
                style: TextStyle(fontWeight: FontWeight.w800)),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                topHeader(),
                const SizedBox(height: 12),
                macroGrid(),
                const SizedBox(height: 10),
                goalRow(),
                const SizedBox(height: 8),
                mealSection(MealType.breakfast),
                mealSection(MealType.lunch),
                mealSection(MealType.dinner),
                mealSection(MealType.snacks),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/food_api.dart';
import '../models/food_item.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';

class NutritionSearchPage extends StatefulWidget {
  final MealType? preselectedMeal;
  const NutritionSearchPage({super.key, this.preselectedMeal});

  @override
  State<NutritionSearchPage> createState() => _NutritionSearchPageState();
}

class _NutritionSearchPageState extends State<NutritionSearchPage> {
  final _controller = TextEditingController();
  final _api = FoodApi();
  Timer? _debounce;

  bool _loading = false;
  String _error = '';
  List<FoodItem> _results = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = _controller.text.trim();

      if (q.length >= 2) {
        await _search(q);
      } else {
        setState(() {
          _results = [];
          _error = '';
        });
      }
    });
  }

  Future<void> _search(String q) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final list = await _api.searchFoods(q);
      setState(() => _results = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addFoodFlow(FoodItem f) async {
    final diary = context.read<DiaryProvider>();
    final gramsController =
        TextEditingController(text: (f.servingSize ?? 100).round().toString());
    final meal = widget.preselectedMeal ?? MealType.lunch;

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        double grams = f.servingSize ?? 100;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final scaled = f.scaledValues(grams);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  if ((f.brand ?? '').isNotEmpty)
                    Text(f.brand!, style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: gramsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Grams',
                            hintText: 'e.g. 150',
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val) ?? grams;
                            setModalState(() => grams = parsed);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${scaled["kcal"]?.round() ?? 0} kcal',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '${scaled["protein"]?.round() ?? 0}P • '
                            '${scaled["carbs"]?.round() ?? 0}C • '
                            '${scaled["fat"]?.round() ?? 0}F',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Add to diary'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirm == true) {
      final grams = double.tryParse(gramsController.text.trim()) ?? 100;
      final id = const Uuid().v4();
      final now = DateTime.now();
      diary.addEntry(DiaryEntry(
        id: id,
        date: DateTime(now.year, now.month, now.day),
        meal: meal,
        food: f,
        grams: grams,
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${f.name} to ${mealTypeLabel(meal)}')),
        );
      }
    }
  }

  Widget _tile(FoodItem f) {
    final gramsShown = f.servingSize ?? 100;
    final scaled = f.scaledValues(gramsShown);

    String fmt(double? v, {String unit = 'g'}) =>
        v == null ? '--$unit' : '${v.round()}$unit';

    final subtitle = [
      if ((f.brand ?? '').isNotEmpty) f.brand!,
      if (f.servingSize != null && f.servingUnit != null)
        '${f.servingSize!.round()} ${f.servingUnit}',
    ].where((s) => s.isNotEmpty).join(' • ');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(
          f.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${scaled["kcal"]?.round() ?? 0} kcal',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${scaled["protein"]?.round() ?? 0}P • '
              '${scaled["carbs"]?.round() ?? 0}C • '
              '${scaled["fat"]?.round() ?? 0}F',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        onTap: () => _addFoodFlow(f),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.preselectedMeal;
    final title = meal != null ? 'Add to ${mealTypeLabel(meal)}' : 'Search Food';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search for a food or a brand...',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 30),
                child: CircularProgressIndicator(),
              ))
            else if (_error.isNotEmpty)
              Text(_error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error))
            else if (_results.isEmpty && _controller.text.trim().length >= 2)
              const Text('No results.')
            else
              ..._results.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _tile(f),
                  )),
          ],
        ),
      ),
    );
  }
}

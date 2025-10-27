// lib/pages/nutrition_search_page.dart
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
  List<FoodItem> _results = [];
  String _error = '';

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
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final q = _controller.text;
      await _search(q);
    });
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = '';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final list = await _api.searchFoods(q);
      setState(() {
        _results = list;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _addFoodFlow(FoodItem f) async {
    final diary = context.read<DiaryProvider>();
    final gramsController =
        TextEditingController(text: (f.servingSize ?? 100).round().toString());
    MealType meal = widget.preselectedMeal ?? MealType.lunch;

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setStateModal) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              if ((f.brand ?? '').isNotEmpty)
                Text(f.brand!, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              TextField(
                controller: gramsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Grams',
                  hintText: 'e.g. 150',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Add to diary'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
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
        Navigator.pop(context); // stäng sökvyn
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${f.name} to ${mealTypeLabel(meal)}')),
        );
      }
    }
  }

  Widget _tile(FoodItem f) {
    final subtitle = [
      if ((f.brand ?? '').isNotEmpty) f.brand!,
      if (f.servingSize != null && f.servingUnit != null)
        '${f.servingSize!.toStringAsFixed(0)} ${f.servingUnit}',
    ].join(' • ');

    String fmt(double? v, {String unit = 'g'}) =>
        v == null ? '--$unit' : '${v.toStringAsFixed(1)}$unit';

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(f.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${(f.caloriesKcal ?? 0).round()} kcal',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${fmt(f.proteinG)} • ${fmt(f.carbsG)} • ${fmt(f.fatG)}',
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
        onTap: () => _addFoodFlow(f),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.preselectedMeal;
    final title = meal != null
        ? 'Add to ${mealTypeLabel(meal)}'
        : 'Search Food';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Search foods (e.g. “chicken breast”)',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error.isNotEmpty)
              Text(_error,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error))
            else if (_results.isEmpty)
              const Text('Search for a food to see results.')
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

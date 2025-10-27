// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'pages/diary_page.dart';
import 'pages/nutrition_search_page.dart';
import 'pages/training_page.dart';
import 'providers/diary_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const DccApp());
}

class DccApp extends StatelessWidget {
  const DccApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4C6FFF), // modern blå
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
      ],
      child: MaterialApp(
        title: 'DCC',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: Color(0xFFFFD347),
    secondary: Color(0xFFFFD347),
    background: Color(0xFF0E0E0E),
    surface: Color(0xFF1A1A1A),
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF0E0E0E),
  cardTheme: const CardThemeData(
    color: Color(0xFF1A1A1A),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    elevation: 2,
    shadowColor: Colors.black54,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0E0E0E),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    bodyLarge: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1C1C1C),
    hintStyle: const TextStyle(color: Colors.white54),
    prefixIconColor: Colors.white54,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF1A1A1A),
    indicatorColor: Color(0xFFFFD347),
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  ),
),
        home: const _RootTabs(),
      ),
    );
  }
}

class _RootTabs extends StatefulWidget {
  const _RootTabs();

  @override
  State<_RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<_RootTabs> {
  int _idx = 0;
  late final _pages = [
    const DiaryPage(),
    const NutritionSearchPage(),
    const TrainingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Diary'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Training'),
        ],
      ),
    );
  }
}

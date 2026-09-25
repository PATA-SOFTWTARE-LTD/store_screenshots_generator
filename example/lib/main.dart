import 'package:example/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final String locale;
  const MyApp({super.key, this.locale = 'it-IT'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshots Demo',
      locale: Locale(locale.split('-')[0]),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const MainNavigationScreen(),
      routes: {
        '/home_light': (context) => const HomeLightScreen(),
        '/home_dark': (context) => const HomeDarkScreen(),
        '/insights_screen': (context) => const InsightsScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/home_light'),
            child: Text(l10n.homeLight),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/home_dark'),
            child: Text(l10n.homeDark),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/insights_screen'),
            child: Text(l10n.insights),
          ),
        ],
      ),
    );
  }
}

class HomeLightScreen extends StatelessWidget {
  const HomeLightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.healthTracking),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                l10n.everythingInCheck,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(l10n.trackSymptoms, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class HomeDarkScreen extends StatelessWidget {
  const HomeDarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.healthTracking),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.nightlight_round,
                size: 80,
                color: Colors.indigoAccent,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.nightMode,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  l10n.nightDesign,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.indigoAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insights),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.weeklyTrend, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: const Center(
              child: Icon(Icons.bar_chart, size: 100, color: Colors.purple),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.topCorrelations,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.local_pizza, color: Colors.white),
            ),
            title: Text(l10n.junkFood),
            subtitle: Text(l10n.junkFoodSub),
            trailing: const Icon(Icons.arrow_upward, color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Colors.grey.withOpacity(0.05),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.water_drop, color: Colors.white),
            ),
            title: Text(l10n.optimalHydration),
            subtitle: Text(l10n.optimalHydrationSub),
            trailing: const Icon(Icons.check, color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Colors.grey.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/bienvenida.dart';
import 'screens/calendario.dart';
import 'screens/estadisticas.dart';
import 'screens/home.dart';
import 'screens/mas.dart';
import 'store.dart';
import 'util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await store.cargar();
  } catch (_) {}
  runApp(const StudyPlanApp());
}

class StudyPlanApp extends StatelessWidget {
  const StudyPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: colorPrincipal),
        scaffoldBackgroundColor: colorFondo,
      ),
      home: ListenableBuilder(
        listenable: store,
        builder: (context, _) => store.usuario == null ? const BienvenidaScreen() : const Principal(),
      ),
    );
  }
}

class Principal extends StatefulWidget {
  const Principal({super.key});
  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int _i = 0;
  final _pantallas = const [HomeScreen(), CalendarioScreen(), EstadisticasScreen(), MasScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(top: false, child: IndexedStack(index: _i, children: _pantallas)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendario'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }
}

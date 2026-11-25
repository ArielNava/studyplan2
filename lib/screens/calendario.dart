import 'package:flutter/material.dart';
import '../store.dart';
import '../util.dart';
import 'registro.dart';
import 'sesion_tile.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});
  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _sel = soloFecha(DateTime.now());

  void _moverMes(int d) => setState(() => _mes = DateTime(_mes.year, _mes.month + d));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final offset = DateTime(_mes.year, _mes.month, 1).weekday - 1;
        final dias = DateTime(_mes.year, _mes.month + 1, 0).day;
        final sesionesDia = store.sesionesDelDia(_sel);
        final hoy = soloFecha(DateTime.now());

        return Scaffold(
          appBar: AppBar(title: const Text('Calendario'), backgroundColor: colorFondo),
          floatingActionButton: FloatingActionButton(
            onPressed: () => abrirRegistro(context, fecha: _sel),
            child: const Icon(Icons.add),
          ),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(onPressed: () => _moverMes(-1), icon: const Icon(Icons.chevron_left)),
              Text('${meses[_mes.month - 1]} ${_mes.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => _moverMes(1), icon: const Icon(Icons.chevron_right)),
            ]),
            Row(children: [
              for (final l in ['L', 'M', 'X', 'J', 'V', 'S', 'D'])
                Expanded(child: Center(child: Text(l, style: const TextStyle(color: Colors.black45)))),
            ]),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < offset; i++) const SizedBox(),
                for (var d = 1; d <= dias; d++) _celda(DateTime(_mes.year, _mes.month, d), hoy),
              ],
            ),
            const SizedBox(height: 12),
            Text('Sesiones del ${fmtFecha(_sel)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (sesionesDia.isEmpty) tarjeta(child: const Text('Sin sesiones este día.')),
            for (final s in sesionesDia) SesionTile(s),
          ]),
        );
      },
    );
  }

  Widget _celda(DateTime dia, DateTime hoy) {
    final sel = dia == _sel;
    final hay = store.sesionesDelDia(dia).isNotEmpty;
    return GestureDetector(
      onTap: () => setState(() => _sel = dia),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: sel ? colorPrincipal : null,
          border: !sel && dia == hoy ? Border.all(color: colorPrincipal) : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${dia.day}', style: TextStyle(color: sel ? Colors.white : Colors.black87)),
          if (hay)
            Container(
              width: 5, height: 5, margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? Colors.white : colorPrincipal),
            ),
        ]),
      ),
    );
  }
}

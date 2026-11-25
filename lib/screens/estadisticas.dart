import 'dart:math';
import 'package:flutter/material.dart';
import '../store.dart';
import '../util.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final total = store.horasSemana(DateTime.now());
        final meta = store.metaSemanal;
        final prog = meta <= 0 ? 0.0 : (total / meta).clamp(0.0, 1.0);
        final dist = store.distribucion();
        final suma = dist.fold(0.0, (a, e) => a + e.value);
        final v = store.variacionSemanal();

        return Scaffold(
          appBar: AppBar(title: const Text('Estadísticas'), backgroundColor: colorFondo),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            tarjeta(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total de horas de estudio (semana)', style: TextStyle(color: Colors.black54)),
                Text('${fmtHoras(total)} h', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text(
                  v == null
                      ? 'Sin datos de la semana anterior'
                      : '${v >= 0 ? '▲' : '▼'} ${v.abs().toStringAsFixed(0)}% vs. semana anterior',
                  style: TextStyle(color: v == null ? Colors.black45 : (v >= 0 ? colorOk : Colors.redAccent)),
                ),
              ]),
            ),
            tarjeta(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tu meta semanal', style: TextStyle(color: Colors.black54)),
                Text('${fmtHoras(total)} / ${fmtHoras(meta)} h',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: prog, minHeight: 8, color: colorOk,
                  borderRadius: BorderRadius.circular(8), backgroundColor: const Color(0xFFE5E7EB),
                ),
              ]),
            ),
            tarjeta(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Distribución por materia', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (dist.isEmpty)
                  const Text('Completa sesiones esta semana para ver tu distribución.')
                else
                  Row(children: [
                    SizedBox(
                      width: 130, height: 130,
                      child: CustomPaint(
                        painter: PiePainter(
                          [for (final e in dist) e.value],
                          [for (final e in dist) Color(e.key.color)],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(children: [
                        for (final e in dist)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(children: [
                              Icon(Icons.circle, size: 10, color: Color(e.key.color)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e.key.nombre)),
                              Text('${(e.value / suma * 100).round()}%'),
                            ]),
                          ),
                      ]),
                    ),
                  ]),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class PiePainter extends CustomPainter {
  final List<double> valores;
  final List<Color> colores;
  PiePainter(this.valores, this.colores);

  @override
  void paint(Canvas canvas, Size size) {
    final grosor = size.width * 0.22;
    final rect = (Offset.zero & size).deflate(grosor / 2);
    final total = valores.fold(0.0, (a, b) => a + b);
    var ang = -pi / 2;
    for (var i = 0; i < valores.length; i++) {
      final barrido = total == 0 ? 0.0 : valores[i] / total * 2 * pi;
      canvas.drawArc(
        rect, ang, barrido, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = grosor
          ..color = colores[i],
      );
      ang += barrido;
    }
  }

  @override
  bool shouldRepaint(covariant PiePainter old) => old.valores != valores || old.colores != colores;
}

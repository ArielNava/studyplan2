import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../util.dart';
import 'registro.dart';
import 'sesion_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final hoy = DateTime.now();
        final hechas = store.horasSemana(hoy);
        final meta = store.metaSemanal;
        final prog = meta <= 0 ? 0.0 : (hechas / meta).clamp(0.0, 1.0);
        final prox = store.proxima();
        final deHoy = store.sesionesDelDia(hoy);

        return ListView(padding: EdgeInsets.zero, children: [
          Container(
            color: colorPrincipal,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('¡Hola, ${store.usuario?.nombre ?? 'estudiante'}! 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Text('Hoy es un gran día para aprender.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              tarjeta(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.track_changes, color: colorPrincipal),
                    SizedBox(width: 8),
                    Text('Tu meta de esta semana', style: TextStyle(color: Colors.black54)),
                  ]),
                  const SizedBox(height: 8),
                  Text('${fmtHoras(hechas)} / ${fmtHoras(meta)} horas',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: prog,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: colorOk,
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Próxima sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (prox == null)
                tarjeta(child: const Text('No tienes sesiones próximas. ¡Planifica una!'))
              else
                tarjeta(
                  child: Row(children: [
                    Icon(Icons.menu_book, color: Color(store.materia(prox.idMateria).color)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(store.materia(prox.idMateria).nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${fmtFecha(prox.inicio)} · ${fmtHora(prox.inicio)} – ${fmtHora(prox.fin)}',
                          style: const TextStyle(color: Colors.black54)),
                    ]),
                  ]),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => abrirRegistro(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva sesión'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Sesiones de hoy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (deHoy.isEmpty) tarjeta(child: const Text('Aún no hay sesiones para hoy.')),
              for (final s in deHoy) SesionTile(s),
              if (deHoy.any((s) => s.estado == EstadoSesion.completada))
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Toca una sesión para marcarla como completada o pendiente.',
                      style: TextStyle(color: Colors.black45, fontSize: 12)),
                ),
            ]),
          ),
        ]);
      },
    );
  }
}

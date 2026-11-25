import 'package:flutter/material.dart';
import '../store.dart';
import '../util.dart';

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  Future<void> _editarMeta(BuildContext context) async {
    final c = TextEditingController(text: fmtHoras(store.metaSemanal));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Meta semanal (horas)'),
        content: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
    final v = double.tryParse(c.text.replaceAll(',', '.'));
    if (ok == true && v != null && v > 0) store.definirMeta(v);
  }

  Future<void> _nuevaMateria(BuildContext context) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva materia'),
        content: TextField(controller: c, textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Agregar')),
        ],
      ),
    );
    if (ok == true && c.text.trim().isNotEmpty) store.agregarMateria(c.text.trim());
  }

  Future<void> _borrarTodo(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar mis datos'),
        content: const Text('Se borrarán tu perfil, materias, sesiones y metas de este dispositivo. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) await store.borrarTodo();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Más'), backgroundColor: colorFondo),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          tarjeta(
            onTap: () => _editarMeta(context),
            child: Row(children: [
              const Icon(Icons.track_changes, color: colorPrincipal),
              const SizedBox(width: 12),
              Expanded(child: Text('Meta semanal: ${fmtHoras(store.metaSemanal)} horas')),
              const Icon(Icons.edit, size: 18),
            ]),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Mis materias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(onPressed: () => _nuevaMateria(context), icon: const Icon(Icons.add), label: const Text('Agregar')),
          ]),
          for (final m in store.materias)
            tarjeta(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Icon(Icons.circle, size: 14, color: Color(m.color)),
                const SizedBox(width: 12),
                Text(m.nombre),
              ]),
            ),
          const SizedBox(height: 24),
          tarjeta(
            child: Text('Perfil: ${store.usuario?.nombre ?? ''} · ${store.usuario?.correo ?? ''}',
                style: const TextStyle(color: Colors.black54)),
          ),
          OutlinedButton.icon(
            onPressed: () => _borrarTodo(context),
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            label: const Text('Eliminar mis datos', style: TextStyle(color: Colors.redAccent)),
          ),
        ]),
      ),
    );
  }
}

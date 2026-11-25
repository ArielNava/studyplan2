import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../util.dart';

/// Fila de una sesión: toque = completar/descompletar, ícono = eliminar.
class SesionTile extends StatelessWidget {
  final SesionEstudio s;
  const SesionTile(this.s, {super.key});

  @override
  Widget build(BuildContext context) {
    final m = store.materia(s.idMateria);
    final hecha = s.estado == EstadoSesion.completada;
    return tarjeta(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onTap: () => store.cambiarEstado(s.id, hecha ? EstadoSesion.pendiente : EstadoSesion.completada),
      child: Row(children: [
        Icon(hecha ? Icons.check_circle : Icons.radio_button_unchecked,
            color: hecha ? colorOk : Color(m.color)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('${fmtHora(s.inicio)} – ${fmtHora(s.fin)}', style: const TextStyle(color: Colors.black54)),
            if (s.notas.isNotEmpty) Text(s.notas, style: const TextStyle(color: Colors.black45, fontSize: 12)),
          ]),
        ),
        Chip(
          label: Text(s.estado.texto, style: const TextStyle(fontSize: 11)),
          visualDensity: VisualDensity.compact,
          backgroundColor: hecha ? const Color(0xFFD1FAE5) : const Color(0xFFE0E7FF),
          side: BorderSide.none,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () => store.eliminarSesion(s.id),
        ),
      ]),
    );
  }
}

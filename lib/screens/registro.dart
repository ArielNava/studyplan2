import 'package:flutter/material.dart';
import '../models.dart';
import '../store.dart';
import '../util.dart';
import 'motivacion.dart';

/// Abre el formulario y, si se guardó una sesión completada, muestra la pantalla de motivación.
Future<void> abrirRegistro(BuildContext context, {DateTime? fecha}) async {
  final estado = await Navigator.push<EstadoSesion>(
    context,
    MaterialPageRoute(builder: (_) => RegistroScreen(fechaInicial: fecha)),
  );
  if (estado == EstadoSesion.completada && context.mounted) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MotivacionScreen()));
  }
}

class RegistroScreen extends StatefulWidget {
  final DateTime? fechaInicial;
  const RegistroScreen({super.key, this.fechaInicial});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  late String _idMateria = store.materias.first.id;
  late DateTime _fecha = soloFecha(widget.fechaInicial ?? DateTime.now());
  TimeOfDay _ini = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _fin = const TimeOfDay(hour: 11, minute: 30);
  EstadoSesion _estado = EstadoSesion.programada;
  final _notas = TextEditingController();

  DateTime _combinar(TimeOfDay t) => DateTime(_fecha.year, _fecha.month, _fecha.day, t.hour, t.minute);

  Future<void> _elegirFecha() async {
    final f = await showDatePicker(
        context: context, initialDate: _fecha, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _elegirHora(bool inicio) async {
    final t = await showTimePicker(context: context, initialTime: inicio ? _ini : _fin);
    if (t != null) setState(() => inicio ? _ini = t : _fin = t);
  }

  void _guardar() {
    final ini = _combinar(_ini);
    final fin = _combinar(_fin);
    if (!fin.isAfter(ini)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La hora de fin debe ser posterior a la de inicio.')));
      return;
    }
    store.agregarSesion(SesionEstudio(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      idMateria: _idMateria,
      inicio: ini,
      fin: fin,
      estado: _estado,
      notas: _notas.text.trim(),
    ));
    Navigator.pop(context, _estado);
  }

  @override
  void dispose() {
    _notas.dispose();
    super.dispose();
  }

  Widget _campo(String etiqueta, Widget hijo) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(etiqueta, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          hijo,
        ]),
      );

  Widget _boton(IconData icono, String texto, VoidCallback onTap) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icono, size: 18),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48), alignment: Alignment.centerLeft),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar sesión'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _campo(
          'Materia',
          DropdownButtonFormField<String>(
            value: _idMateria,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [for (final m in store.materias) DropdownMenuItem(value: m.id, child: Text(m.nombre))],
            onChanged: (v) => setState(() => _idMateria = v!),
          ),
        ),
        _campo('Fecha', _boton(Icons.event, fmtFecha(_fecha), _elegirFecha)),
        _campo('Hora de inicio', _boton(Icons.schedule, _ini.format(context), () => _elegirHora(true))),
        _campo('Hora de fin', _boton(Icons.schedule, _fin.format(context), () => _elegirHora(false))),
        _campo(
          'Estado',
          Wrap(spacing: 8, children: [
            for (final e in EstadoSesion.values)
              ChoiceChip(
                label: Text(e.texto),
                selected: _estado == e,
                onSelected: (_) => setState(() => _estado = e),
              ),
          ]),
        ),
        _campo(
          'Notas (opcional)',
          TextField(
            controller: _notas,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Repasar ejercicios del capítulo 4.'),
          ),
        ),
        FilledButton(
          onPressed: _guardar,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text('Guardar'),
        ),
      ]),
    );
  }
}

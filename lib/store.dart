import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'models.dart';

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime lunesDe(DateTime d) {
  final f = soloFecha(d);
  return f.subtract(Duration(days: f.weekday - 1));
}

String _dos(int n) => n.toString().padLeft(2, '0');
String _fechaSql(DateTime d) => '${d.year}-${_dos(d.month)}-${_dos(d.day)}';
String _horaSql(DateTime d) => '${_dos(d.hour)}:${_dos(d.minute)}';
DateTime _unir(String fecha, String hora) => DateTime.parse('${fecha}T$hora:00');

const paletaColores = [0xFF3B82F6, 0xFF10B981, 0xFFA855F7, 0xFFF59E0B, 0xFF9CA3AF, 0xFFEF4444, 0xFF14B8A6];

/// Lógica de negocio + acceso a datos. Los datos viven en SQLite (archivo studyplan.db
/// en el dispositivo) y se mantienen en memoria para que la interfaz sea inmediata.
class StudyStore extends ChangeNotifier {
  late Database _db;
  Usuario? usuario;
  List<Materia> materias = [];
  List<SesionEstudio> sesiones = [];
  double metaSemanal = 20;

  // ------------------------------------------------------------ base de datos
  Future<void> cargar() async {
    final ruta = p.join(await getDatabasesPath(), 'studyplan.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE usuario (
            id_usuario     TEXT PRIMARY KEY,
            nombre         TEXT NOT NULL,
            correo         TEXT NOT NULL UNIQUE,
            fecha_registro TEXT NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE materia (
            id_materia TEXT PRIMARY KEY,
            id_usuario TEXT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
            nombre     TEXT NOT NULL,
            color      INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE sesion_estudio (
            id_sesion   TEXT PRIMARY KEY,
            id_usuario  TEXT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
            id_materia  TEXT NOT NULL REFERENCES materia(id_materia) ON DELETE CASCADE,
            fecha       TEXT NOT NULL,
            hora_inicio TEXT NOT NULL,
            hora_fin    TEXT NOT NULL,
            estado      TEXT NOT NULL CHECK (estado IN ('Completada','Pendiente','Programada')),
            notas       TEXT,
            CHECK (hora_fin > hora_inicio)
          )''');
        await db.execute('''
          CREATE TABLE meta_semanal (
            id_meta        TEXT PRIMARY KEY,
            id_usuario     TEXT NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
            fecha_inicio   TEXT NOT NULL,
            horas_objetivo REAL NOT NULL CHECK (horas_objetivo > 0)
          )''');
        await db.execute('CREATE INDEX idx_sesion_fecha ON sesion_estudio (id_usuario, fecha)');
      },
    );
    await _leer();
  }

  Future<void> _leer() async {
    final u = await _db.query('usuario', limit: 1);
    if (u.isEmpty) {
      usuario = null;
      materias = [];
      sesiones = [];
      metaSemanal = 20;
      notifyListeners();
      return;
    }
    final r = u.first;
    usuario = Usuario(
      id: r['id_usuario'] as String,
      nombre: r['nombre'] as String,
      correo: r['correo'] as String,
      fechaRegistro: DateTime.parse(r['fecha_registro'] as String),
    );
    materias = (await _db.query('materia', where: 'id_usuario = ?', whereArgs: [usuario!.id], orderBy: 'rowid'))
        .map((m) => Materia(id: m['id_materia'] as String, nombre: m['nombre'] as String, color: m['color'] as int))
        .toList();
    sesiones = (await _db.query('sesion_estudio', where: 'id_usuario = ?', whereArgs: [usuario!.id]))
        .map((s) => SesionEstudio(
              id: s['id_sesion'] as String,
              idMateria: s['id_materia'] as String,
              inicio: _unir(s['fecha'] as String, s['hora_inicio'] as String),
              fin: _unir(s['fecha'] as String, s['hora_fin'] as String),
              estado: EstadoSesion.values.firstWhere((e) => e.texto == s['estado']),
              notas: (s['notas'] as String?) ?? '',
            ))
        .toList();
    final meta = await _db.query('meta_semanal',
        where: 'id_usuario = ? AND fecha_inicio <= ?',
        whereArgs: [usuario!.id, _fechaSql(lunesDe(DateTime.now()))],
        orderBy: 'fecha_inicio DESC',
        limit: 1);
    metaSemanal = meta.isEmpty ? 20 : (meta.first['horas_objetivo'] as num).toDouble();
    notifyListeners();
  }

  // ------------------------------------------------------------ escrituras
  Future<void> registrarUsuario(String nombre, String correo) async {
    final id = 'u${DateTime.now().microsecondsSinceEpoch}';
    await _db.transaction((txn) async {
      await txn.insert('usuario', {
        'id_usuario': id,
        'nombre': nombre,
        'correo': correo,
        'fecha_registro': DateTime.now().toIso8601String(),
      });
      const nombres = ['Matemáticas', 'Historia', 'Inglés', 'Ciencias', 'Otras'];
      for (var i = 0; i < nombres.length; i++) {
        await txn.insert('materia',
            {'id_materia': '$id-m$i', 'id_usuario': id, 'nombre': nombres[i], 'color': paletaColores[i]});
      }
      await txn.insert('meta_semanal', {
        'id_meta': '$id-meta0',
        'id_usuario': id,
        'fecha_inicio': _fechaSql(lunesDe(DateTime.now())),
        'horas_objetivo': 20.0,
      });
    });
    await _leer();
  }

  Future<void> agregarSesion(SesionEstudio s) async {
    await _db.insert('sesion_estudio', {
      'id_sesion': s.id,
      'id_usuario': usuario!.id,
      'id_materia': s.idMateria,
      'fecha': _fechaSql(s.inicio),
      'hora_inicio': _horaSql(s.inicio),
      'hora_fin': _horaSql(s.fin),
      'estado': s.estado.texto,
      'notas': s.notas,
    });
    sesiones.add(s);
    notifyListeners();
  }

  Future<void> eliminarSesion(String id) async {
    await _db.delete('sesion_estudio', where: 'id_sesion = ?', whereArgs: [id]);
    sesiones.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> cambiarEstado(String id, EstadoSesion e) async {
    await _db.update('sesion_estudio', {'estado': e.texto}, where: 'id_sesion = ?', whereArgs: [id]);
    final i = sesiones.indexWhere((s) => s.id == id);
    if (i >= 0) sesiones[i] = sesiones[i].copyWith(estado: e);
    notifyListeners();
  }

  Future<void> agregarMateria(String nombre) async {
    final m = Materia(
        id: 'm${DateTime.now().microsecondsSinceEpoch}',
        nombre: nombre,
        color: paletaColores[materias.length % paletaColores.length]);
    await _db.insert('materia',
        {'id_materia': m.id, 'id_usuario': usuario!.id, 'nombre': m.nombre, 'color': m.color});
    materias.add(m);
    notifyListeners();
  }

  Future<void> definirMeta(double horas) async {
    final lunes = _fechaSql(lunesDe(DateTime.now()));
    await _db.delete('meta_semanal',
        where: 'id_usuario = ? AND fecha_inicio = ?', whereArgs: [usuario!.id, lunes]);
    await _db.insert('meta_semanal', {
      'id_meta': 'meta${DateTime.now().microsecondsSinceEpoch}',
      'id_usuario': usuario!.id,
      'fecha_inicio': lunes,
      'horas_objetivo': horas,
    });
    metaSemanal = horas;
    notifyListeners();
  }

  /// Borra el usuario y, por ON DELETE CASCADE, todas sus materias, sesiones y metas.
  Future<void> borrarTodo() async {
    await _db.delete('usuario');
    await _leer();
  }

  // ------------------------------------------------------------ consultas
  Materia materia(String id) => materias.firstWhere((m) => m.id == id, orElse: () => materias.first);

  List<SesionEstudio> sesionesDelDia(DateTime d) {
    final f = soloFecha(d);
    final l = sesiones.where((s) => soloFecha(s.inicio) == f).toList();
    l.sort((a, b) => a.inicio.compareTo(b.inicio));
    return l;
  }

  SesionEstudio? proxima() {
    final ahora = DateTime.now();
    final l = sesiones.where((s) => s.estado != EstadoSesion.completada && s.fin.isAfter(ahora)).toList();
    if (l.isEmpty) return null;
    l.sort((a, b) => a.inicio.compareTo(b.inicio));
    return l.first;
  }

  Iterable<SesionEstudio> _completadasSemana(DateTime ref) {
    final ini = lunesDe(ref);
    final fin = ini.add(const Duration(days: 7));
    return sesiones.where((s) =>
        s.estado == EstadoSesion.completada && !s.inicio.isBefore(ini) && s.inicio.isBefore(fin));
  }

  double horasSemana(DateTime ref) => _completadasSemana(ref).fold(0.0, (a, s) => a + s.horas);

  /// Variación porcentual frente a la semana anterior (null si no hay base).
  double? variacionSemanal() {
    final ahora = DateTime.now();
    final ant = horasSemana(ahora.subtract(const Duration(days: 7)));
    if (ant == 0) return null;
    return (horasSemana(ahora) - ant) / ant * 100;
  }

  /// Horas completadas por materia en la semana actual, de mayor a menor.
  List<MapEntry<Materia, double>> distribucion() {
    final mapa = <String, double>{};
    for (final s in _completadasSemana(DateTime.now())) {
      mapa[s.idMateria] = (mapa[s.idMateria] ?? 0) + s.horas;
    }
    final l = mapa.entries.map((e) => MapEntry(materia(e.key), e.value)).toList();
    l.sort((a, b) => b.value.compareTo(a.value));
    return l;
  }
}

final store = StudyStore();

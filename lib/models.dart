enum EstadoSesion { completada, pendiente, programada }

extension EstadoTexto on EstadoSesion {
  String get texto {
    switch (this) {
      case EstadoSesion.completada:
        return 'Completada';
      case EstadoSesion.pendiente:
        return 'Pendiente';
      case EstadoSesion.programada:
        return 'Programada';
    }
  }
}

class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final DateTime fechaRegistro;
  const Usuario({required this.id, required this.nombre, required this.correo, required this.fechaRegistro});
}

class Materia {
  final String id;
  final String nombre;
  final int color;
  const Materia({required this.id, required this.nombre, required this.color});
}

class SesionEstudio {
  final String id;
  final String idMateria;
  final DateTime inicio;
  final DateTime fin;
  final EstadoSesion estado;
  final String notas;

  const SesionEstudio({
    required this.id,
    required this.idMateria,
    required this.inicio,
    required this.fin,
    this.estado = EstadoSesion.programada,
    this.notas = '',
  });

  double get horas => fin.difference(inicio).inMinutes / 60.0;

  SesionEstudio copyWith({EstadoSesion? estado}) => SesionEstudio(
        id: id,
        idMateria: idMateria,
        inicio: inicio,
        fin: fin,
        estado: estado ?? this.estado,
        notas: notas,
      );
}

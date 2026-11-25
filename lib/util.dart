import 'package:flutter/material.dart';

const colorPrincipal = Color(0xFF4F46E5);
const colorFondo = Color(0xFFF5F6FB);
const colorOk = Color(0xFF10B981);

const meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];
const mesesCortos = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

String fmtHora(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
String fmtFecha(DateTime d) => '${d.day} ${mesesCortos[d.month - 1]} ${d.year}';
String fmtHoras(double h) => h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);

Widget tarjeta({required Widget child, EdgeInsets? padding, VoidCallback? onTap}) => Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
      ),
    );

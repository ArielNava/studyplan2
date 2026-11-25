import 'package:flutter/material.dart';
import '../store.dart';
import '../util.dart';

/// Primera pantalla: crea el perfil local (tabla USUARIO). No hay contraseña ni servidor.
class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});
  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  bool _guardando = false;

  Future<void> _comenzar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    await store.registrarUsuario(_nombre.text.trim(), _correo.text.trim());
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Icon(Icons.menu_book_rounded, size: 72, color: Colors.white),
              const SizedBox(height: 8),
              const Text('StudyPlan',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Organiza tu tiempo, alcanza tus metas.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    child: Column(children: [
                      const Text('Crea tu perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      const Text('Tus datos se guardan solo en este dispositivo.',
                          style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nombre,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _correo,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
                        validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
                            ? null
                            : 'Escribe un correo válido',
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _guardando ? null : _comenzar,
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Comenzar'),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

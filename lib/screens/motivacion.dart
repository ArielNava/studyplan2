import 'package:flutter/material.dart';
import '../util.dart';

class MotivacionScreen extends StatelessWidget {
  const MotivacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.emoji_events, size: 96, color: Color(0xFFFBBF24)),
            const SizedBox(height: 16),
            const Text('¡Sigue así!',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tu constancia te acerca a tus metas.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: colorPrincipal),
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Volver al inicio'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

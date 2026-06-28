import 'package:flutter/material.dart';
import '../services/academic_service.dart';
import '../models/event_model.dart';

class AcademicEventsScreen extends StatefulWidget {
  const AcademicEventsScreen({super.key});

  @override
  State<AcademicEventsScreen> createState() => _AcademicEventsScreenState();
}

class _AcademicEventsScreenState extends State<AcademicEventsScreen> {
  final AcademicService _academicService = AcademicService();
  late Future<List<AcademicEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    // Inicialización del Future para evitar múltiples lecturas del archivo en re-builds
    _eventsFuture = _academicService.loadLocalEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduSync - Eventos Académicos'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // Fondo gris/azul claro para resaltar la separación de las tarjetas blancas
      backgroundColor: const Color(0xFFEDF2F7),
      body: FutureBuilder<List<AcademicEvent>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error al leer el archivo JSON: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron registros en el archivo.'),
            );
          }

          final eventos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Alineación estricta a la izquierda
                    children: [
                      // Información Principal en Negrita
                      Text(
                        evento.titulo,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold, // Texto principal en negrita
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 14,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            evento.fecha,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            evento.aula,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      Text(
                        evento.descripcion,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

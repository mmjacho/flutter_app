import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/event_model.dart';

class AcademicService {
  Future<List<AcademicEvent>> loadLocalEvents() async {
    try {
      // Simula o realiza la lectura asíncrona del archivo JSON en assets
      final String response = await rootBundle.loadString(
        'assets/data/academic_events.json',
      );
      final data = await json.decode(response);
      debugPrint('📘 JSON cargado desde academic_events.json:');
      debugPrint(data.toString());

      final List<dynamic> list = data['eventos'] ?? [];

      // Convierte cada mapa de la lista en una instancia del modelo AcademicEvent
      return list.map((e) => AcademicEvent.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error al procesar el archivo JSON local: $e');
    }
  }
}

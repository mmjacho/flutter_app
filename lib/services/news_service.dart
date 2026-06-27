import 'dart:convert';
import 'package:http/http.dart' as http;

class Noticia {
  final String titulo;
  final String contenido;
  final String urlImagen;
  final String periodico;
  final String fecha;

  Noticia({
    required this.titulo,
    required this.contenido,
    required this.urlImagen,
    required this.periodico,
    required this.fecha,
  });
}

class NewsService {
  // Consumo HTTP asíncrono utilizando la API REST de prueba JSONPlaceholder
  Future<List<Noticia>> fetchNewsFromSource(String sourceId) async {
    // Segmentación lógica de datos según el periódico seleccionado
    final int userId = (sourceId == 'el_universo') ? 1 : 2;
    final String periodicoNombre = (sourceId == 'el_universo')
        ? 'El Universo'
        : 'El Comercio';

    final url = Uri.parse(
      'https://jsonplaceholder.typicode.com/posts?userId=$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Mapear y procesar los primeros 5 artículos de la descarga HTTP
        return data.take(5).map((item) {
          final int mockId = item['id'] ?? 1;
          // Actualización dinámica de imágenes basadas en el ID de contenido del post descargado
          final String dynamicImg =
              'https://picsum.photos/id/${mockId + 12}/600/400';

          return Noticia(
            titulo: _capitalize(item['title'] ?? ''),
            contenido: _capitalize(item['body'] ?? ''),
            urlImagen: dynamicImg,
            periodico: periodicoNombre,
            fecha: 'Hoy, 11:45 AM',
          );
        }).toList();
      } else {
        throw Exception('Error de red: Código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo en la descarga HTTP de noticias: $e');
    }
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

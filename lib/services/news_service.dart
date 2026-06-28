import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para detectar kIsWeb
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

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
  final String _urlElUniverso =
      'https://www.eluniverso.com/arc/outboundfeeds/rss/?outputType=xml';
  final String _urlMetroEcuador =
      'https://www.metroecuador.com.ec/arc/outboundfeeds/rss/?outputType=xml';

  Future<List<Noticia>> fetchNewsFromSource(String sourceId) async {
    final bool isElUniverso = sourceId == 'el_universo';
    final String urlOriginal = isElUniverso ? _urlElUniverso : _urlMetroEcuador;
    final String periodicoNombre = isElUniverso
        ? 'El Universo'
        : 'Metro Ecuador';

    String? xmlContent;

    if (kIsWeb) {
      // Sistema de redundancia académica: si un proxy falla, el código salta al siguiente
      final List<String> proxies = [
        'https://corsproxy.io/?${Uri.encodeComponent(urlOriginal)}',
        'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(urlOriginal)}',
        'https://api.allorigins.win/raw?url=${Uri.encodeComponent(urlOriginal)}',
      ];

      for (String proxyUrl in proxies) {
        try {
          final response = await http
              .get(Uri.parse(proxyUrl))
              .timeout(const Duration(seconds: 4));

          // Validar que la respuesta sea exitosa y que NO sea un HTML de error de Cloudflare
          if (response.statusCode == 200 &&
              !response.body.contains('</BODY>') &&
              !response.body.contains('</html>')) {
            xmlContent = utf8.decode(response.bodyBytes);
            break; // Éxito: rompemos el bucle y continuamos con el parseo
          }
        } catch (_) {
          // Si el proxy da error o timeout, el bucle continúa silenciosamente con el siguiente
        }
      }
    } else {
      // En Windows, Android o iOS va directo y sin intermediarios
      try {
        final response = await http
            .get(Uri.parse(urlOriginal))
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          xmlContent = utf8.decode(response.bodyBytes);
        }
      } catch (e) {
        throw Exception('Error de conexión nativa: $e');
      }
    }

    // Si ningún proxy funcionó en la Web o la petición falló
    if (xmlContent == null || xmlContent.isEmpty) {
      throw Exception(
        'No se pudo recuperar el contenido debido a restricciones de red o CORS.',
      );
    }

    try {
      final feed = RssFeed.parse(xmlContent);
      final List<Noticia> listaNoticias = [];

      if (feed.items != null) {
        final int totalItems = feed.items!.length > 8 ? 8 : feed.items!.length;

        for (int i = 0; i < totalItems; i++) {
          final item = feed.items![i];

          listaNoticias.add(
            Noticia(
              titulo: item.title ?? 'Sin título disponible',
              contenido: _cleanHtml(
                item.description ?? 'No hay descripción disponible.',
              ),
              urlImagen: _extractRealImage(item),
              periodico: periodicoNombre,
              fecha: item.pubDate != null
                  ? item.pubDate.toString()
                  : 'Reciente',
            ),
          );
        }
      }
      return listaNoticias;
    } catch (e) {
      throw Exception('Error al parsear el árbol XML: $e');
    }
  }

  String _extractRealImage(RssItem item) {
    String? urlDetectada;

    try {
      // 1. Extraer desde la extensión de Yahoo Media
      if (item.media != null &&
          item.media!.contents != null &&
          item.media!.contents!.isNotEmpty) {
        urlDetectada = item.media!.contents!.first.url;
      }
      // 2. Respaldo por tag enclosure estándar
      if ((urlDetectada == null || urlDetectada.isEmpty) &&
          item.enclosure != null) {
        urlDetectada = item.enclosure!.url;
      }
    } catch (_) {}

    // Validación y saneamiento de la URL
    if (urlDetectada != null &&
        urlDetectada.isNotEmpty &&
        urlDetectada.startsWith('http')) {
      if (kIsWeb) {
        return 'https://corsproxy.io/?${Uri.encodeComponent(urlDetectada)}';
      }
      return urlDetectada;
    }

    // Imagen de respaldo por defecto si el artículo no tiene foto
    return 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=600&auto=format&fit=crop';
  }

  String _cleanHtml(String htmlString) {
    final regExp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(regExp, '').trim();
  }
}

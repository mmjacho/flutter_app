class AcademicEvent {
  final String id;
  final String titulo;
  final String fecha;
  final String aula;
  final String descripcion;

  AcademicEvent({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.aula,
    required this.descripcion,
  });

  // Constructor factory para mapear el mapa JSON de forma segura
  factory AcademicEvent.fromJson(Map<String, dynamic> json) {
    return AcademicEvent(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? 'Sin título disponible',
      fecha: json['fecha'] ?? 'Fecha pendiente',
      aula: json['aula'] ?? 'N/A',
      descripcion: json['descripcion'] ?? 'No hay descripción disponible.',
    );
  }
}

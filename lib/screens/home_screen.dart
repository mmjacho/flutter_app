import 'package:flutter/material.dart';
import 'formulario_screen.dart'; // Importar tu formulario existente sin tocarlo
import '../services/news_service.dart'; // Importación de nuestro nuevo servicio RSS

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice para controlar la pestaña activa de la NavigationBar
  int _currentIndex = 0;

  // LISTA DE PANTALLAS ORIGINALES PRESERVADAS SIN ELIMINAR NADA
  final List<Widget> _screens = [
    const _InicioTab(), // Pestaña 0: Inicio / Dashboard original
    const FormularioScreen(), // Pestaña 1: Formulario original
    const _NoticiasTab(), // Pestaña 2: Noticias REALES y en vivo por RSS (HTTP)
    const _PerfilTab(), // Pestaña 3: Perfil / Cuenta original
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EduSync Portal',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No tienes notificaciones pendientes.'),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Formulario',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Noticias HTTP',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Sub-pantalla para pestaña de Inicio (TOTALMENTE PRESERVADA)
// ==========================================
class _InicioTab extends StatelessWidget {
  const _InicioTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 90, color: theme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Bienvenido a EduSync',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tu plataforma de sincronización y gestión académica en tiempo real.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(Icons.info, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        'Accede a la pestaña "Formulario" en la barra inferior para completar tu ficha académica obligatoria.',
                        style: TextStyle(fontSize: 14, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET MEJORADO: Renderizador de Feeds RSS Reales por HTTP
// ==========================================
class _NoticiasTab extends StatefulWidget {
  const _NoticiasTab();

  @override
  State<_NoticiasTab> createState() => _NoticiasTabState();
}

class _NoticiasTabState extends State<_NoticiasTab> {
  final NewsService _newsService = NewsService();
  String _selectedSource = 'el_universo'; // Control del menú seleccionado
  late Future<List<Noticia>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
    setState(() {
      _newsFuture = _newsService.fetchNewsFromSource(_selectedSource);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtro superior interactivo para alternar el RSS del periódico digital
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text(
                  'El Universo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: _selectedSource == 'el_universo',
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedSource = 'el_universo';
                      _loadNews();
                    });
                  }
                },
              ),
              ChoiceChip(
                // CORRECCIÓN DE TEXTO E IDENTIFICADOR AQUÍ
                label: const Text(
                  'Metro Ecuador',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                selected:
                    _selectedSource ==
                    'el_comercio', // Mantenemos tu variable id para no cambiar lógica
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedSource = 'el_comercio';
                      _loadNews();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        // FutureBuilder para manejar los estados asíncronos del HTTP y del webfeed
        Expanded(
          child: FutureBuilder<List<Noticia>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error al descargar RSS: ${snapshot.error}\n\nVerifique la conexión a internet de su dispositivo.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay publicaciones de última hora en el canal.',
                  ),
                );
              }

              final noticias = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: noticias.length,
                itemBuilder: (context, index) {
                  final noticia = noticias[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen de la noticia parseada desde el XML del periódico
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: Image.network(
                            noticia.urlImagen,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      noticia.periodico,
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      noticia.fecha,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                noticia.titulo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.25,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                noticia.contenido,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// Sub-pantalla para pestaña de Perfil (TOTALMENTE PRESERVADA)
// ==========================================
class _PerfilTab extends StatelessWidget {
  const _PerfilTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Estudiante EduSync',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'grupo2@edusync.edu.ec',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración de Cuenta'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Cambiar Contraseña'),
              onTap: () {},
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar Sesión'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

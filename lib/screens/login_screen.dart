import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clave global para controlar y validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto introducido
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Credenciales predefinidas solicitadas por la tarea
  final String _validEmail = "admin@correo.com";
  final String _validPassword = "password123";

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Si pasa las validaciones de campos obligatorios, verificamos credenciales
      if (_emailController.text == _validEmail &&
          _passwordController.text == _validPassword) {
        debugPrint("Acceso concedido"); // FIX: Cambiado print por debugPrint
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        debugPrint("Acceso Negado"); // FIX: Cambiado print por debugPrint
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acceso Negado: Credenciales incorrectas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _register() {
    debugPrint(
      "Va a registrar un nuevo usuario",
    ); // FIX: Cambiado print por debugPrint
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo de pantalla completo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1579546929518-9e396f3cc809',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // FIX: Se cambió withOpacity por .withValues(alpha: ...)
          Container(color: Colors.black.withValues(alpha: 0.4)),

          // 2. Contenido del Formulario protegido con SafeArea
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // REQUERIMIENTO: Nombres y Apellidos en la parte superior
                      const Text(
                        'Grupo 2:\nCamaton Lainez Segundo Rodolfo\nGuevara Bustos Yandri David\nGutierrez Paredes Andy Luis\nJacho Cedeño Mario Mauricio\nQuiroga Peralta Ruben Alfredo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Desarrollo de Aplicaciones Móviles',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 40),

                      // Contenedor semitransparente para los campos de entrada
                      Card(
                        // FIX: Se cambió withOpacity por .withValues(alpha: ...)
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Campo Obligatorio: Correo Electrónico
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Correo Electrónico',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El correo es obligatorio';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Ingrese un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Campo Obligatorio: Clave de Acceso
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Clave de Acceso',
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La clave es obligatoria';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),

                      // Botón Ingresar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Ingresar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Botón Registrarse
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _register,
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

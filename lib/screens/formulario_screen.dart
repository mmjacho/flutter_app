import 'package:flutter/material.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  // Llave global para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Estados de los campos especiales requeridos
  DateTime? _fechaSeleccionada; // Campo de Calendario (DatePicker)
  String? _rolSeleccionado; // Campo de ComboBox (Dropdown)
  String _jornadaSeleccionada = 'Matutina'; // Campo de RadioButton
  bool _aceptaTerminos = false; // Campo de Checkbox (Adicional)

  // Lista de opciones para el ComboBox (Roles académicos)
  final List<String> _roles = [
    'Estudiante',
    'Docente',
    'Administrativo',
    'Padre de Familia',
  ];

  @override
  void dispose() {
    // Liberar recursos de controladores al cerrar pantalla
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Método para desplegar el Calendario (DatePicker) de forma segura
  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Inicializado hace 18 años
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Color principal
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  // Evento Aceptar: Muestra en consola y despliega un diálogo de confirmación
  void _procesarDatos() {
    if (_formKey.currentState!.validate()) {
      if (_fechaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona tu fecha de nacimiento.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_rolSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona tu rol institucional.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (!_aceptaTerminos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Debes aceptar los Términos y Condiciones de EduSync.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // 1. Mostrar por consola los datos ingresados por el usuario en la APP
      debugPrint('==================================================');
      debugPrint('   DATOS ENVIADOS DESDE EL FORMULARIO EDUSYNC     ');
      debugPrint('==================================================');
      debugPrint('1. Nombre Completo : ${_nombreController.text}');
      debugPrint('2. Correo de Usuario: ${_emailController.text}');
      debugPrint('3. Teléfono Móvil   : ${_telefonoController.text}');
      debugPrint(
        '4. Fecha Nacimiento : ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
      );
      debugPrint('5. Rol Académico    : $_rolSeleccionado');
      debugPrint('6. Jornada Escogida : $_jornadaSeleccionada');
      debugPrint('7. Acepta Términos  : $_aceptaTerminos');
      debugPrint('==================================================');

      // 2. Mostrar un diálogo visual con los datos
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text('Registro Exitoso'),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text(
                    'Los siguientes datos han sido registrados en la consola del sistema:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildDataRow('Nombre', _nombreController.text),
                  _buildDataRow('Correo', _emailController.text),
                  _buildDataRow('Teléfono', _telefonoController.text),
                  _buildDataRow(
                    'F. Nacimiento',
                    '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                  ),
                  _buildDataRow('Rol', _rolSeleccionado ?? ''),
                  _buildDataRow('Jornada', _jornadaSeleccionada),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
              ),
            ],
          );
        },
      );
    }
  }

  // Helper para mostrar filas de datos en el diálogo
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // Evento Borrar: Limpia todos los campos del formulario
  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    setState(() {
      _nombreController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _fechaSeleccionada = null;
      _rolSeleccionado = null;
      _jornadaSeleccionada = 'Matutina';
      _aceptaTerminos = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se han borrado todos los campos del formulario.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera estilizada basada en el Login
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment_ind,
                        color: theme.primaryColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registro Ficha Académica',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          Text(
                            'Completa los datos para EduSync',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Campo 1: Nombre Completo (Texto)
                const Text(
                  'Nombre Completo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    hintText: 'Ej. Juan Antonio Pérez',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, ingresa tu nombre completo';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Por favor, ingresa al menos un nombre y un apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo 2: Correo Electrónico (Texto)
                const Text(
                  'Correo Electrónico',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'ejemplo@edusync.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, ingresa tu correo electrónico';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Ingresa un formato de correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo 3: Teléfono Móvil (Texto con teclado numérico)
                const Text(
                  'Teléfono Móvil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ej. 0998877665',
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, ingresa un número telefónico';
                    }
                    if (value.length < 9) {
                      return 'Ingresa un número de teléfono válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo 4: Calendario - Fecha de Nacimiento (OBLIGATORIO)
                const Text(
                  'Fecha de Nacimiento',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _seleccionarFecha(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _fechaSeleccionada == null
                                  ? 'Seleccionar fecha...'
                                  : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                              style: TextStyle(
                                fontSize: 15,
                                color: _fechaSeleccionada == null
                                    ? Colors.grey[600]
                                    : Colors.black87,
                                fontWeight: _fechaSeleccionada == null
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo 5: ComboBox (DropdownButton) - Rol Institucional (OBLIGATORIO)
                const Text(
                  'Rol Institucional',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _rolSeleccionado,
                  hint: const Text('Seleccionar rol...'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _roles.map((String rol) {
                    return DropdownMenuItem<String>(
                      value: rol,
                      child: Text(rol),
                    );
                  }).toList(),
                  onChanged: (String? nuevoValor) {
                    setState(() {
                      _rolSeleccionado = nuevoValor;
                    });
                  },
                  validator: (value) => value == null
                      ? 'Por favor, selecciona un rol institucional'
                      : null,
                ),
                const SizedBox(height: 20),

                // Campo 6: RadioButton - Jornada (OBLIGATORIO)
                const Text(
                  'Jornada de Estudio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RadioGroup<String>(
                      groupValue: _jornadaSeleccionada,
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _jornadaSeleccionada = value;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Matutina (07:00 - 13:00)'),
                            value: 'Matutina',
                            activeColor: theme.primaryColor,
                          ),
                          RadioListTile<String>(
                            title: const Text('Vespertina (13:00 - 19:00)'),
                            value: 'Vespertina',
                            activeColor: theme.primaryColor,
                          ),
                          RadioListTile<String>(
                            title: const Text('Nocturna (19:00 - 22:00)'),
                            value: 'Nocturna',
                            activeColor: theme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Campo Adicional: Checkbox - Términos y Condiciones
                Row(
                  children: [
                    Checkbox(
                      value: _aceptaTerminos,
                      activeColor: theme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _aceptaTerminos = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Acepto los términos, condiciones de uso y políticas de seguridad de EduSync.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Dos botones al final: Aceptar y Borrar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _limpiarFormulario,
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: const Text(
                          'Borrar',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _procesarDatos,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Aceptar',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

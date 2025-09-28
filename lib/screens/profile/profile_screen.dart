import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_notifier.dart';
import '../../providers/pet_provider.dart';
import '../../router/app_router.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic> _userProfile = {
    'name': 'Usuario',
    'email': 'usuario@ejemplo.com',
    'phone': 'No especificado',
    'location': 'No especificada',
    'bio': 'Usuario de Woofy',
      'preferences': {
        'push_notifications': true,
      'email_updates': true,
        'dark_mode': false,
      },
    };

  List<Map<String, dynamic>> _userPets = [
      {
        'id': '1',
        'name': 'Max',
        'breed': 'Golden Retriever',
        'age': 3,
        'gender': 'male',
        'weight': 25.5,
        'color': 'Dorado',
        'medical_notes': 'Alérgico al polen, necesita medicamento diario',
        'vaccination_status': 'up_to_date',
      'last_vet_visit': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': '2',
        'name': 'Luna',
        'breed': 'Labrador',
        'age': 2,
        'gender': 'female',
        'weight': 22.0,
        'color': 'Negro',
        'medical_notes': 'Saludable, necesita ejercicio diario',
        'vaccination_status': 'up_to_date',
      'last_vet_visit': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'id': '3',
        'name': 'Rocky',
        'breed': 'Pastor Alemán',
        'age': 1,
        'gender': 'male',
        'weight': 18.0,
        'color': 'Marrón y Negro',
        'medical_notes': 'Cachorro activo, en proceso de socialización',
        'vaccination_status': 'in_progress',
      'last_vet_visit': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      },
    ];

  Map<String, dynamic> _userStats = {
      'total_appointments': 24,
      'completed_appointments': 22,
      'active_reminders': 5,
    'member_since': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Usar solo datos hardcodeados
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProfileHeader(theme),
                          _buildStatsSection(theme),
                          _buildPetsSection(theme),
                          _buildSettingsSection(theme),
                          _buildPreferencesSection(theme),
                          const SizedBox(
                            height: 100,
                          ), // Espacio para bottom nav
                        ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
              CircleAvatar(
                radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                backgroundImage: _userProfile['avatar_url'] != null
                    ? NetworkImage(_userProfile['avatar_url'])
                    : null,
                child: _userProfile['avatar_url'] == null
                ? Icon(
                        Icons.person,
                        size: 60,
                    color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
          ),
          const SizedBox(height: 16),
          // Nombre y email
          Text(
            _userProfile['name'] ?? 'Usuario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile['email'] ?? '',
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          // Bio
          if (_userProfile['bio'] != null && _userProfile['bio'].isNotEmpty)
            Text(
              _userProfile['bio'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          // Información adicional
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem(
                Icons.location_on,
                _userProfile['location'] ?? 'No especificada',
                'Ubicación',
              ),
              _buildInfoItem(
                Icons.phone,
                _userProfile['phone'] ?? 'No especificado',
                'Teléfono',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Citas Totales',
                  _userStats['total_appointments'].toString(),
                  Icons.event,
                  const Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completadas',
                  _userStats['completed_appointments'].toString(),
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Recordatorios',
                  _userStats['active_reminders'].toString(),
                  Icons.notifications,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetsSection(ThemeData theme) {
    final pets = ref.watch(petNotifierProvider);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Mascotas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddPetDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pets.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.pets,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No tienes mascotas registradas',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showAddPetDialog(),
                    child: const Text('Agregar tu primera mascota'),
                  ),
                ],
              ),
            )
          else
            ...pets.map((pet) => _buildPetCard(pet)),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.pets,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${pet.breed} • ${pet.age} años',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  _getVaccinationText(pet.vaccinationStatus),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getVaccinationColor(pet.vaccinationStatus),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditPetDialog(pet);
              } else if (value == 'delete') {
                _showDeletePetDialog(pet);
              } else if (value == 'details') {
                _showPetDetailsModal(pet);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info, size: 18),
                    SizedBox(width: 8),
                    Text('Ver detalles'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
            ],
            child: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            Icons.edit,
            'Editar Perfil',
            'Actualiza tu información personal',
            _editProfile,
          ),
          _buildSettingItem(
            Icons.security,
            'Privacidad',
            'Gestiona tu privacidad y seguridad',
            _openPrivacy,
          ),
          _buildSettingItem(
            Icons.help,
            'Ayuda y Soporte',
            'Obtén ayuda cuando la necesites',
            _openHelp,
          ),
          _buildSettingItem(
            Icons.info,
            'Acerca de',
            'Información de la aplicación',
            _openAbout,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeSelector(),
          _buildPreferenceSwitch(
            'Notificaciones Push',
            'Recibir notificaciones en tiempo real',
            _userProfile['preferences']?['push_notifications'] ?? true,
            (value) => _updatePreference('push_notifications', value),
          ),
          _buildPreferenceSwitch(
            'Actualizaciones por Email',
            'Recibir notificaciones por correo',
            _userProfile['preferences']?['email_updates'] ?? true,
            (value) => _updatePreference('email_updates', value),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    
    return ListTile(
      leading: Icon(
        themeNotifier.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Tema de la aplicación',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        _getThemeDescription(themeMode),
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
      ),
      trailing: PopupMenuButton<ThemeMode>(
        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        onSelected: (ThemeMode mode) {
          themeNotifier.setThemeMode(mode);
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<ThemeMode>(
            value: ThemeMode.light,
            child: Row(
              children: [
                Icon(Icons.light_mode, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Claro'),
                if (themeMode == ThemeMode.light)
                  Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
          PopupMenuItem<ThemeMode>(
            value: ThemeMode.dark,
            child: Row(
              children: [
                Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Oscuro'),
                if (themeMode == ThemeMode.dark)
                  Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
          PopupMenuItem<ThemeMode>(
            value: ThemeMode.system,
            child: Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text('Sistema'),
                if (themeMode == ThemeMode.system)
                  Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Tema claro activado';
      case ThemeMode.dark:
        return 'Tema oscuro activado';
      case ThemeMode.system:
        return 'Sigue la configuración del sistema';
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _userProfile['name']),
              onChanged: (value) => _userProfile['name'] = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _userProfile['email']),
              onChanged: (value) => _userProfile['email'] = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _userProfile['phone']),
              onChanged: (value) => _userProfile['phone'] = value,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _userProfile['location']),
              onChanged: (value) => _userProfile['location'] = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil actualizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }


  void _openPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Privacidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de Datos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Compartir Ubicación'),
              subtitle: const Text('Permitir compartir ubicación con veterinarias'),
              value: _userProfile['preferences']['share_location'] ?? false,
              onChanged: (value) {
                setState(() {
                  _userProfile['preferences']['share_location'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Análisis de Datos'),
              subtitle: const Text('Permitir análisis para mejorar la app'),
              value: _userProfile['preferences']['data_analytics'] ?? true,
              onChanged: (value) {
                setState(() {
                  _userProfile['preferences']['data_analytics'] = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _openHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda y Soporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recursos de Ayuda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: const Text('Contactar Soporte'),
              subtitle: const Text('Envía un mensaje al equipo de soporte'),
              onTap: () {
                Navigator.of(context).pop();
                _showContactSupportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Reportar Problema'),
              subtitle: const Text('Reporta un error o problema'),
              onTap: () {
                Navigator.of(context).pop();
                _showBugReportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de la App'),
              subtitle: const Text('Información de la aplicación'),
              onTap: () {
                Navigator.of(context).pop();
                _openAbout();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cuenta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer y se perderán todos tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cuenta eliminada (simulado)'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog() {
    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contactar Soporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Envía un mensaje al equipo de soporte:'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
                hintText: 'Describe tu problema o consulta...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mensaje enviado al soporte')),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    final TextEditingController bugController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe el problema que encontraste:'),
            const SizedBox(height: 16),
            TextField(
              controller: bugController,
              decoration: const InputDecoration(
                labelText: 'Descripción del problema',
                border: OutlineInputBorder(),
                hintText: 'Explica qué pasó y cómo reproducir el problema...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Problema reportado al equipo')),
              );
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

  void _openAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de Woofy'),
        content: const Text('Versión 1.0.0\n\nUna aplicación para el cuidado de tus mascotas.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildPreferenceSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  String _getVaccinationText(String status) {
    switch (status) {
      case 'up_to_date':
        return 'Vacunas al día';
      case 'in_progress':
        return 'En proceso';
      case 'overdue':
        return 'Vencidas';
      default:
        return 'Desconocido';
    }
  }

  Color _getVaccinationColor(String status) {
    switch (status) {
      case 'up_to_date':
        return const Color(0xFF4CAF50);
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'overdue':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF616161);
    }
  }

  String _formatMemberSince() {
    final memberSinceStr = _userStats['member_since'] as String?;
    if (memberSinceStr == null || memberSinceStr.isEmpty) {
      return '1 año';
    }
    final memberSince = DateTime.parse(memberSinceStr);
    final months = DateTime.now().difference(memberSince).inDays ~/ 30;
    return '$months meses';
  }

  void _updatePreference(String key, bool value) {
    setState(() {
      if (_userProfile['preferences'] == null) {
        _userProfile['preferences'] = {};
      }
      _userProfile['preferences'][key] = value;
    });
  }

  void _showAddPetDialog() {
    showDialog(
      context: context,
      builder: (context) => _PetFormDialog(
        onSave: (pet) {
          ref.read(petNotifierProvider.notifier).addPet(pet);
        },
      ),
    );
  }

  void _showEditPetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => _PetFormDialog(
        pet: pet,
        onSave: (updatedPet) {
          ref.read(petNotifierProvider.notifier).updatePet(updatedPet);
        },
      ),
    );
  }

  void _showDeletePetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text('¿Estás seguro de que quieres eliminar a ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(petNotifierProvider.notifier).deletePet(pet.id);
              context.pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPetDetailsModal(Pet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PetDetailsModal(pet: pet),
    );
  }
}

// Widget para el formulario de mascotas (reutilizado del HomeScreen)
class _PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Pet) onSave;

  const _PetFormDialog({
    this.pet,
    required this.onSave,
  });

  @override
  State<_PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<_PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  
  String _gender = 'male';
  String _vaccinationStatus = 'up_to_date';

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      _ageController.text = widget.pet!.age.toString();
      _weightController.text = widget.pet!.weight.toString();
      _colorController.text = widget.pet!.color;
      _medicalNotesController.text = widget.pet!.medicalNotes;
      _gender = widget.pet!.gender;
      _vaccinationStatus = widget.pet!.vaccinationStatus;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pet == null ? 'Agregar Mascota' : 'Editar Mascota'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Raza',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La raza es requerida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Edad (años)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La edad es requerida';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El peso es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Macho')),
                  DropdownMenuItem(value: 'female', child: Text('Hembra')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El color es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _vaccinationStatus,
                decoration: const InputDecoration(
                  labelText: 'Estado de Vacunación',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'up_to_date', child: Text('Al día')),
                  DropdownMenuItem(value: 'in_progress', child: Text('En proceso')),
                  DropdownMenuItem(value: 'overdue', child: Text('Vencidas')),
                ],
                onChanged: (value) {
                  setState(() {
                    _vaccinationStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalNotesController,
                decoration: const InputDecoration(
                  labelText: 'Notas Médicas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _savePet,
          child: Text(widget.pet == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        breed: _breedController.text,
        age: int.parse(_ageController.text),
        gender: _gender,
        weight: double.parse(_weightController.text),
        color: _colorController.text,
        medicalNotes: _medicalNotesController.text,
        vaccinationStatus: _vaccinationStatus,
        lastVetVisit: widget.pet?.lastVetVisit ?? DateTime.now(),
        createdAt: widget.pet?.createdAt ?? DateTime.now(),
      );
      
      widget.onSave(pet);
      context.pop();
    }
  }
}

// Widget para mostrar detalles de la mascota (reutilizado del HomeScreen)
class _PetDetailsModal extends StatelessWidget {
  final Pet pet;

  const _PetDetailsModal({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.pets,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      '${pet.breed} • ${pet.age} años',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Información General', [
                    _buildInfoItem('Raza', pet.breed),
                    _buildInfoItem('Edad', '${pet.age} años'),
                    _buildInfoItem('Género', pet.gender == 'male' ? 'Macho' : 'Hembra'),
                    _buildInfoItem('Peso', '${pet.weight} kg'),
                    _buildInfoItem('Color', pet.color),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Estado de Salud', [
                    _buildInfoItem('Vacunación', _getVaccinationText(pet.vaccinationStatus)),
                    _buildInfoItem('Última visita', _formatDate(pet.lastVetVisit)),
                    _buildInfoItem('Notas médicas', pet.medicalNotes),
                  ]),
                  const SizedBox(height: 20),
                  _buildAppointmentHistory(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF616161),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentHistory() {
    // Datos mock de historial de citas
    final appointments = [
      {
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'type': 'Vacuna Triple',
        'clinic': 'Clínica Veterinaria Central',
        'status': 'completed',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'type': 'Control General',
        'clinic': 'Hospital San Patricio',
        'status': 'completed',
      },
      {
        'date': DateTime.now().add(const Duration(days: 7)),
        'type': 'Revisión Anual',
        'clinic': 'Centro Médico Animal',
        'status': 'scheduled',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Citas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 12),
        ...appointments.map((appointment) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: appointment['status'] == 'scheduled' 
                ? const Color(0xFF1E88E5).withOpacity(0.3)
                : const Color(0xFF4CAF50).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                appointment['status'] == 'scheduled' 
                  ? Icons.schedule 
                  : Icons.check_circle,
                color: appointment['status'] == 'scheduled' 
                  ? const Color(0xFF1E88E5)
                  : const Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['type'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      appointment['clinic'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(appointment['date'] as DateTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF616161),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  String _getVaccinationText(String status) {
    switch (status) {
      case 'up_to_date':
        return 'Al día';
      case 'in_progress':
        return 'En proceso';
      case 'overdue':
        return 'Vencidas';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
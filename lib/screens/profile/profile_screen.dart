import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic> _userProfile = {};
  List<Map<String, dynamic>> _userPets = [];
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;

  // Animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Cargar perfil del usuario
        final profileResponse = await _supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .single();

        // Cargar mascotas del usuario
        final petsResponse = await _supabase
            .from('pets')
            .select('*')
            .eq('user_id', user.id);

        // Calcular estadísticas
        final stats = await _calculateUserStats(user.id);

        setState(() {
          _userProfile = profileResponse;
          _userPets = List<Map<String, dynamic>>.from(petsResponse);
          _userStats = stats;
        });
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
      setState(() {
        _userProfile = _getMockProfile();
        _userPets = _getMockPets();
        _userStats = _getMockStats();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<Map<String, dynamic>> _calculateUserStats(String userId) async {
    try {
      // Contar citas
      final appointmentsResponse = await _supabase
          .from('appointments')
          .select('id')
          .eq('user_id', userId);

      // Contar citas completadas
      final completedResponse = await _supabase
          .from('appointments')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed');

      // Contar recordatorios activos
      final remindersResponse = await _supabase
          .from('reminders')
          .select('id')
          .eq('user_id', userId)
          .eq('is_active', true);

      return {
        'total_appointments': appointmentsResponse.length,
        'completed_appointments': completedResponse.length,
        'active_reminders': remindersResponse.length,
        'member_since': DateTime.now()
            .subtract(const Duration(days: 365))
            .toIso8601String(),
      };
    } catch (e) {
      return _getMockStats();
    }
  }

  Map<String, dynamic> _getMockProfile() {
    return {
      'id': '1',
      'name': 'María González',
      'email': 'maria.gonzalez@email.com',
      'phone': '+1-555-0123',
      'avatar_url':
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
      'bio':
          'Amante de los animales y dueña responsable de 3 perritos adorables.',
      'location': 'Ciudad de México, México',
      'preferences': {
        'notifications': true,
        'email_updates': true,
        'push_notifications': true,
        'dark_mode': false,
        'language': 'es',
      },
      'created_at': DateTime.now()
          .subtract(const Duration(days: 365))
          .toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _getMockPets() {
    return [
      {
        'id': '1',
        'name': 'Max',
        'breed': 'Golden Retriever',
        'age': 3,
        'gender': 'male',
        'weight': 25.5,
        'color': 'Dorado',
        'avatar_url':
            'https://images.unsplash.com/photo-1552053831-71594a27632d?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
        'medical_notes': 'Alérgico al polen, necesita medicamento diario',
        'vaccination_status': 'up_to_date',
        'last_vet_visit': DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String(),
      },
      {
        'id': '2',
        'name': 'Luna',
        'breed': 'Labrador',
        'age': 2,
        'gender': 'female',
        'weight': 22.0,
        'color': 'Negro',
        'avatar_url':
            'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
        'medical_notes': 'Saludable, necesita ejercicio diario',
        'vaccination_status': 'up_to_date',
        'last_vet_visit': DateTime.now()
            .subtract(const Duration(days: 15))
            .toIso8601String(),
      },
      {
        'id': '3',
        'name': 'Rocky',
        'breed': 'Pastor Alemán',
        'age': 1,
        'gender': 'male',
        'weight': 18.0,
        'color': 'Marrón y Negro',
        'avatar_url':
            'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
        'medical_notes': 'Cachorro activo, en proceso de socialización',
        'vaccination_status': 'in_progress',
        'last_vet_visit': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
      },
    ];
  }

  Map<String, dynamic> _getMockStats() {
    return {
      'total_appointments': 24,
      'completed_appointments': 22,
      'active_reminders': 5,
      'member_since': DateTime.now()
          .subtract(const Duration(days: 365))
          .toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A1A), Color(0xFF121212)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1E88E5),
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
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
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                theme.cardTheme.shadowColor ??
                const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar y botón de editar
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
                backgroundImage: _userProfile['avatar_url'] != null
                    ? NetworkImage(_userProfile['avatar_url'])
                    : null,
                child: _userProfile['avatar_url'] == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF1E88E5),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _editProfile,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Nombre y email
          Text(
            _userProfile['name'] ?? 'Usuario',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile['email'] ?? '',
            style: const TextStyle(fontSize: 16, color: Color(0xFF616161)),
          ),
          const SizedBox(height: 8),
          // Bio
          if (_userProfile['bio'] != null && _userProfile['bio'].isNotEmpty)
            Text(
              _userProfile['bio'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
                fontStyle: FontStyle.italic,
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
              _buildInfoItem(
                Icons.calendar_today,
                _formatMemberSince(),
                'Miembro desde',
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
        Icon(icon, color: const Color(0xFF1E88E5), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF616161)),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                theme.cardTheme.shadowColor ??
                const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Citas Totales',
                  _userStats['total_appointments'].toString(),
                  Icons.event_note,
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Recordatorios',
                  _userStats['active_reminders'].toString(),
                  Icons.notifications,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Mascotas',
                  _userPets.length.toString(),
                  Icons.pets,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                theme.cardTheme.shadowColor ??
                const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Mascotas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              TextButton.icon(
                onPressed: _addNewPet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._userPets.map((pet) => _buildPetCard(pet)),
        ],
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Avatar de la mascota
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
            backgroundImage: pet['avatar_url'] != null
                ? NetworkImage(pet['avatar_url'])
                : null,
            child: pet['avatar_url'] == null
                ? const Icon(Icons.pets, size: 30, color: Color(0xFF1E88E5))
                : null,
          ),
          const SizedBox(width: 16),
          // Información de la mascota
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet['breed']} • ${pet['age']} años • ${pet['gender'] == 'male' ? 'Macho' : 'Hembra'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet['weight']} kg • ${pet['color']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616161),
                  ),
                ),
                const SizedBox(height: 8),
                // Estado de vacunación
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getVaccinationColor(
                      pet['vaccination_status'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getVaccinationColor(
                        pet['vaccination_status'],
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getVaccinationText(pet['vaccination_status']),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getVaccinationColor(pet['vaccination_status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botón de editar
          IconButton(
            onPressed: () => _editPet(pet),
            icon: const Icon(Icons.edit, color: Color(0xFF1E88E5), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                theme.cardTheme.shadowColor ??
                const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            Icons.notifications,
            'Notificaciones',
            'Gestionar alertas y recordatorios',
            () => _manageNotifications(),
          ),
          _buildSettingItem(
            Icons.security,
            'Privacidad',
            'Configurar privacidad y seguridad',
            () => _managePrivacy(),
          ),
          _buildSettingItem(
            Icons.help,
            'Ayuda y Soporte',
            'Centro de ayuda y contacto',
            () => _showHelp(),
          ),
          _buildSettingItem(
            Icons.info,
            'Acerca de',
            'Información de la aplicación',
            () => _showAbout(),
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
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                theme.cardTheme.shadowColor ??
                const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
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
          Consumer(
            builder: (context, ref, child) {
              final isDarkMode = ref.watch(isDarkModeProvider);
              final themeNotifier = ref.read(themeModeProvider.notifier);

              return _buildPreferenceSwitch(
                'Modo Oscuro',
                'Usar tema oscuro en la aplicación',
                isDarkMode,
                (value) => themeNotifier.toggleTheme(),
              );
            },
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
      leading: Icon(icon, color: const Color(0xFF1E88E5)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Color(0xFF616161),
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1E88E5),
    );
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

  String _formatMemberSince() {
    final memberSince = DateTime.parse(_userStats['member_since']);
    final months = DateTime.now().difference(memberSince).inDays ~/ 30;
    return '$months meses';
  }

  void _editProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Editar perfil'),
        backgroundColor: Color(0xFF1E88E5),
      ),
    );
    // TODO: Navegar a pantalla de editar perfil
  }

  void _addNewPet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Agregar nueva mascota'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    // TODO: Navegar a pantalla de agregar mascota
  }

  void _editPet(Map<String, dynamic> pet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando mascota: ${pet['name']}'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
    );
    // TODO: Navegar a pantalla de editar mascota
  }

  void _manageNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Gestionar notificaciones'),
        backgroundColor: Color(0xFF1E88E5),
      ),
    );
    // TODO: Navegar a configuración de notificaciones
  }

  void _managePrivacy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Configuración de privacidad'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
    );
    // TODO: Navegar a configuración de privacidad
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Centro de ayuda'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
    );
    // TODO: Navegar a centro de ayuda
  }

  void _showAbout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Información de la app'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
    );
    // TODO: Navegar a información de la app
  }

  void _updatePreference(String key, bool value) {
    setState(() {
      if (_userProfile['preferences'] == null) {
        _userProfile['preferences'] = {};
      }
      _userProfile['preferences'][key] = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Preferencia actualizada: $key = $value'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
    // TODO: Guardar preferencia en Supabase
  }
}

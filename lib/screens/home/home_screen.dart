import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String _userName = '';
  List<Map<String, dynamic>> _pets = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _nearbyClinics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Cargar perfil del usuario
        final profileResponse = await _supabase
            .from('profiles')
            .select('name')
            .eq('id', user.id)
            .single();

        setState(() {
          _userName = profileResponse['name'] ?? 'Usuario';
        });

        // Cargar mascotas del usuario
        final petsResponse = await _supabase
            .from('pets')
            .select('*')
            .eq('user_id', user.id)
            .limit(3);

        setState(() {
          _pets = List<Map<String, dynamic>>.from(petsResponse);
        });

        // Cargar eventos próximos (simulado por ahora)
        setState(() {
          _upcomingEvents = [
            {
              'title': 'Vacuna Triple',
              'pet': 'Max',
              'date': '15 de Enero',
              'time': '10:00 AM',
              'type': 'vaccine',
              'urgent': false,
            },
            {
              'title': 'Control de Peso',
              'pet': 'Luna',
              'date': '18 de Enero',
              'time': '2:00 PM',
              'type': 'checkup',
              'urgent': true,
            },
          ];
        });

        // Cargar clínicas cercanas (simulado por ahora)
        setState(() {
          _nearbyClinics = [
            {
              'name': 'Clínica Veterinaria Central',
              'distance': '0.8 km',
              'rating': 4.5,
              'open': true,
              'specialties': ['General', 'Cirugía'],
            },
            {
              'name': 'Hospital San Patricio',
              'distance': '1.2 km',
              'rating': 4.2,
              'open': false,
              'specialties': ['Emergencias', 'Cardiología'],
            },
          ];
        });
      }
    } catch (e) {
      print('Error cargando datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: ThemeUtils.getBackgroundDecoration(context, ref),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1E88E5),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildUpcomingEvents(),
                      const SizedBox(height: 24),
                      _buildNearbyClinics(),
                      const SizedBox(height: 24),
                      _buildAITips(),
                      const SizedBox(height: 100), // Espacio para bottom nav
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.pets, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, $_userName!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getTextPrimaryColor(context, ref),
                      ),
                    ),
                    Text(
                      '¿Cómo está tu perrito hoy?',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _supabase.auth.signOut();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.logout, color: Color(0xFF616161)),
              ),
            ],
          ),
          if (_pets.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tus mascotas:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
            const SizedBox(height: 8),
            ..._pets.map(
              (pet) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.pets, size: 16, color: Color(0xFF1E88E5)),
                    const SizedBox(width: 8),
                    Text(
                      pet['name'],
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'Nueva Mascota',
                subtitle: 'Registrar perrito',
                color: const Color(0xFF1E88E5),
                onTap: () {
                  // TODO: Navegar a agregar mascota
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Agregar mascota'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.calendar_today,
                title: 'Agendar Cita',
                subtitle: 'Con veterinario',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  // TODO: Navegar a agendar cita
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: Agendar cita')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.location_on,
                title: 'Veterinarias',
                subtitle: 'Cerca de ti',
                color: const Color(0xFFFF9800),
                onTap: () {
                  // TODO: Navegar a mapa
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Mapa de veterinarias'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.psychology,
                title: 'Asistente IA',
                subtitle: 'Consulta rápida',
                color: const Color(0xFF9C27B0),
                onTap: () {
                  // TODO: Navegar a chat IA
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: Asistente IA')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFB0B0B0)
                    : const Color(0xFF616161),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Próximos Eventos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navegar a calendario
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: Calendario completo'),
                  ),
                );
              },
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._upcomingEvents.map((event) => _buildEventCard(event)),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: event['urgent']
            ? Border.all(color: const Color(0xFFF44336), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: event['urgent']
                  ? const Color(0xFFF44336)
                  : const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              _getEventIcon(event['type']),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event['pet']} • ${event['date']} a las ${event['time']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),
          if (event['urgent'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Urgente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNearbyClinics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Veterinarias Cercanas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navegar a mapa
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente: Mapa completo')),
                );
              },
              child: const Text(
                'Ver mapa',
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._nearbyClinics.map((clinic) => _buildClinicCard(clinic)),
      ],
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: clinic['open']
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF616161),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.local_hospital, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: const Color(0xFF616161),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      clinic['distance'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 14, color: const Color(0xFFFFB74D)),
                    const SizedBox(width: 4),
                    Text(
                      clinic['rating'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  clinic['open'] ? 'Abierto ahora' : 'Cerrado',
                  style: TextStyle(
                    fontSize: 12,
                    color: clinic['open']
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navegar a detalles de clínica
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Detalles de clínica'),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF1E88E5),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Tip del Asistente IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '💡 Recuerda que los perros necesitan ejercicio diario. Una caminata de 30 minutos ayuda a mantener su salud física y mental.',
            style: TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navegar a chat IA
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente: Chat con IA'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Consultar IA',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'vaccine':
        return Icons.vaccines;
      case 'checkup':
        return Icons.medical_services;
      case 'grooming':
        return Icons.content_cut;
      default:
        return Icons.event;
    }
  }
}

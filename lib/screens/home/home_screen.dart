import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';
import '../../providers/pet_provider.dart';
import '../../providers/navigation_provider.dart';
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
    setState(() {
      _userName = 'Usuario';
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
        {
          'title': 'Cirugía de Castración',
          'pet': 'Rocky',
          'date': '22 de Enero',
          'time': '8:00 AM',
          'type': 'surgery',
          'urgent': false,
        },
      ];
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
        {
          'name': 'Centro Médico Animal',
          'distance': '2.1 km',
          'rating': 4.7,
          'open': true,
          'specialties': ['Dermatología', 'Oftalmología'],
        },
      ];
      _isLoading = false;
    });
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
                      _buildPetsSection(),
                      const SizedBox(height: 24),
                      _buildUpcomingEvents(),
                      const SizedBox(height: 24),
                      _buildNearbyClinics(),
                      const SizedBox(height: 24),
                      _buildAITips(),
                      const SizedBox(height: 100),
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
                  context.go(AppRouter.splash);
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
            color: ThemeUtils.getTextPrimaryColor(context, ref),
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
                onTap: () => _showAddPetDialog(),
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
                  ref.read(navigationNotifierProvider.notifier).changeTab(3);
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
                  ref.read(navigationNotifierProvider.notifier).changeTab(1);
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
                onTap: () => _showAIAssistantModal(),
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
          color: ThemeUtils.getCardColor(context, ref),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeUtils.getShadowColor(context, ref),
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
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
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
            Text(
              'Próximos Eventos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(navigationNotifierProvider.notifier).changeTab(2);
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
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        border: event['urgent']
            ? Border.all(color: const Color(0xFFF44336), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event['pet']} • ${event['date']} a las ${event['time']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
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
            Text(
              'Veterinarias Cercanas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(navigationNotifierProvider.notifier).changeTab(1);
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
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 14, color: const Color(0xFFFFB74D)),
                    const SizedBox(width: 4),
                    Text(
                      clinic['rating'].toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
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
            onPressed: () => _showClinicDetailsModal(),
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
                  onPressed: () => _showAITipsModal(),
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

  Widget _buildPetsSection() {
    final pets = ref.watch(petNotifierProvider);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Mascotas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeUtils.getTextPrimaryColor(context, ref),
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
                    color: ThemeUtils.getTextSecondaryColor(
                      context,
                      ref,
                    ).withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No tienes mascotas registradas',
                    style: TextStyle(
                      color: ThemeUtils.getTextSecondaryColor(context, ref),
                      fontSize: 16,
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
            ...pets.map((pet) => _buildSimplePetCard(pet)),
        ],
      ),
    );
  }

  Widget _buildSimplePetCard(Pet pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.pets,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
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
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
                Text(
                  '${pet.breed} • ${pet.age} años',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
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
              color: ThemeUtils.getTextSecondaryColor(context, ref),
              size: 20,
            ),
          ),
        ],
      ),
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

  void _showAddPetDialog() {
    print('Opening add pet dialog...');
    showDialog(
      context: context,
      builder: (context) => _PetFormDialog(
        onSave: (pet) {
          print('Saving pet: ${pet.name}');
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
      builder: (context) => _PetDetailsModal(pet: pet, ref: ref),
    );
  }

  void _showAITipsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AITipsModal(),
    );
  }

  void _showAIAssistantModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AIAssistantModal(),
    );
  }

  void _showClinicDetailsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClinicDetailsModal(),
    );
  }
}

class _PetFormDialog extends StatefulWidget {
  final Pet? pet;
  final Function(Pet) onSave;

  const _PetFormDialog({this.pet, required this.onSave});

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
                  DropdownMenuItem(
                    value: 'in_progress',
                    child: Text('En proceso'),
                  ),
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

class _PetDetailsModal extends StatelessWidget {
  final Pet pet;
  final WidgetRef ref;

  const _PetDetailsModal({required this.pet, required this.ref});

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
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getTextPrimaryColor(context, ref),
                      ),
                    ),
                    Text(
                      '${pet.breed} • ${pet.age} años',
                      style: TextStyle(
                        fontSize: 16,
                        color: ThemeUtils.getTextSecondaryColor(context, ref),
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
                    _buildInfoItem(
                      'Género',
                      pet.gender == 'male' ? 'Macho' : 'Hembra',
                    ),
                    _buildInfoItem('Peso', '${pet.weight} kg'),
                    _buildInfoItem('Color', pet.color),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Estado de Salud', [
                    _buildInfoItem(
                      'Vacunación',
                      _getVaccinationText(pet.vaccinationStatus),
                    ),
                    _buildInfoItem(
                      'Última visita',
                      _formatDate(pet.lastVetVisit),
                    ),
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
          child: Column(children: items),
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
              style: const TextStyle(color: Color(0xFF212121)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentHistory() {
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
        ...appointments.map(
          (appointment) => Container(
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
          ),
        ),
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

class _AITipsModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Consejos del Asistente IA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTipCard(
                    context,
                    'Ejercicio Diario',
                    'Los perros necesitan al menos 30 minutos de ejercicio diario. Esto incluye caminatas, juegos y actividades que estimulen su mente.',
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    context,
                    'Alimentación Saludable',
                    'Mantén horarios regulares de comida y evita darle comida humana. Consulta con tu veterinario sobre la dieta ideal para tu mascota.',
                    const Color(0xFFFF9800),
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    context,
                    'Vacunación',
                    'Mantén al día las vacunas de tu mascota. Esto previene enfermedades graves y protege su salud a largo plazo.',
                    const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    context,
                    'Higiene',
                    'Baña a tu perro cada 4-6 semanas y cepilla su pelaje regularmente. Esto mantiene su piel saludable y reduce el olor.',
                    const Color(0xFF9C27B0),
                  ),
                  const SizedBox(height: 16),
                  _buildTipCard(
                    context,
                    'Revisiones Veterinarias',
                    'Lleva a tu mascota al veterinario al menos una vez al año para revisiones de rutina y detección temprana de problemas.',
                    const Color(0xFFF44336),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIAssistantModal extends StatefulWidget {
  @override
  _AIAssistantModalState createState() => _AIAssistantModalState();
}

class _AIAssistantModalState extends State<_AIAssistantModal> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          '¡Hola! Soy tu asistente IA. ¿En qué puedo ayudarte con el cuidado de tu mascota?',
      'isUser': false,
      'timestamp': DateTime.now(),
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Asistente IA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(context, message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Map<String, dynamic> message,
  ) {
    final isUser = message['isUser'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.psychology,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message['text'] as String,
                style: TextStyle(
                  color: isUser
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });

    _messageController.clear();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'text':
                'Gracias por tu pregunta. Como asistente IA, te recomiendo consultar con un veterinario profesional para obtener el mejor consejo para tu mascota.',
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        });
      }
    });
  }
}

class _ClinicDetailsModal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Detalles de la Clínica',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClinicInfo(
                    context,
                    'Clínica Veterinaria Central',
                    'Av. Principal 123, Centro',
                    '4.8 ⭐ (156 reseñas)',
                    'Abierto ahora',
                    'Lun - Vie: 8:00 - 20:00\nSáb: 8:00 - 18:00\nDom: 9:00 - 16:00',
                    '+1 234 567 8900',
                  ),
                  const SizedBox(height: 20),
                  _buildServicesSection(context),
                  const SizedBox(height: 20),
                  _buildContactSection(context, ref),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicInfo(
    BuildContext context,
    String name,
    String address,
    String rating,
    String status,
    String hours,
    String phone,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                rating,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hours,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios Ofrecidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildServiceChip(context, 'Consulta General'),
            _buildServiceChip(context, 'Vacunación'),
            _buildServiceChip(context, 'Cirugía'),
            _buildServiceChip(context, 'Laboratorio'),
            _buildServiceChip(context, 'Radiología'),
            _buildServiceChip(context, 'Emergencias 24h'),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceChip(BuildContext context, String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        service,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Navegación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.pop();
              ref.read(navigationNotifierProvider.notifier).changeTab(1);
            },
            icon: const Icon(Icons.directions),
            label: const Text('Cómo llegar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';
import '../../providers/pet_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/ai_chat_provider.dart';
import '../../config/theme_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profileState = ref.read(profileProvider);
    if (profileState.profile == null) {
      await ref.read(profileProvider.notifier).loadProfile();
    }

    await ref.read(appointmentProvider.notifier).loadAppointments();
    await ref.read(reminderProvider.notifier).loadReminders();

    final profile = ref.read(profileProvider).profile;
    final user = ref.read(authProvider).user;

    setState(() {
      _userName =
          profile?.name ??
          user?.name ??
          (user?.email.split('@').first) ??
          'Usuario';
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
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildQuickActions(),
                      const SizedBox(height: 12),
                      _buildUpcomingEventsCompact(),
                      const SizedBox(height: 12),
                      _buildTopVeterinaries(),
                      const SizedBox(height: 12),
                      _buildAIAssistantCompact(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $_userName!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
                Text(
                  '¿Cómo está tu perrito hoy?',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go(AppRouter.splash);
              }
            },
            icon: const Icon(Icons.logout, size: 20),
            color: const Color(0xFF616161),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final pets = ref.watch(petNotifierProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.pets,
                title: 'Mis Mascotas',
                subtitle: pets.isEmpty ? 'Agregar' : '${pets.length}',
                color: const Color(0xFF1E88E5),
                onTap: () {
                  ref.read(navigationNotifierProvider.notifier).changeTab(1);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionCard(
                icon: Icons.calendar_today,
                title: 'Agendar Cita',
                subtitle: 'Veterinario',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  ref.read(navigationNotifierProvider.notifier).changeTab(4);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.location_on,
                title: 'Veterinarias',
                subtitle: 'Cerca de ti',
                color: const Color(0xFFFF9800),
                onTap: () {
                  ref.read(navigationNotifierProvider.notifier).changeTab(2);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionCard(
                icon: Icons.psychology,
                title: 'Asistente IA',
                subtitle: 'Consulta',
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ThemeUtils.getCardColor(context, ref),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ThemeUtils.getShadowColor(context, ref),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsCompact() {
    final upcomingAppointments = ref.watch(upcomingAppointmentsProvider);
    final todayReminders = ref.watch(todayRemindersProvider);
    final List<Map<String, dynamic>> combinedEvents = [];

    for (var apt in upcomingAppointments.take(2)) {
      combinedEvents.add({
        'title': apt.serviceType,
        'pet': apt.petName ?? 'Mascota',
        'date': _formatDate(apt.startsAt),
        'time': apt.appointmentTime,
        'type': 'appointment',
        'urgent': apt.isUrgent,
      });
    }

    if (combinedEvents.length < 2) {
      for (var reminder in todayReminders.take(2 - combinedEvents.length)) {
        combinedEvents.add({
          'title': reminder.title,
          'pet': reminder.petName ?? 'General',
          'date': _formatDate(reminder.reminderDate),
          'time': reminder.reminderTime,
          'type': 'reminder',
          'urgent': reminder.isUrgent,
        });
      }
    }

    if (combinedEvents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximos Eventos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getTextPrimaryColor(context, ref),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeUtils.getCardColor(context, ref),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No hay eventos próximos',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeUtils.getTextSecondaryColor(context, ref),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximos Eventos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(navigationNotifierProvider.notifier).changeTab(3);
              },
              child: Text(
                'Ver todo',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: combinedEvents
              .map(
                (event) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right:
                          combinedEvents.indexOf(event) ==
                              combinedEvents.length - 1
                          ? 0
                          : 8,
                    ),
                    child: _buildEventCardCompact(event),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEventCardCompact(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeUtils.getCardColor(context, ref),
        borderRadius: BorderRadius.circular(12),
        border: event['urgent']
            ? Border.all(color: const Color(0xFFF44336), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: ThemeUtils.getShadowColor(context, ref),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: event['urgent']
                  ? const Color(0xFFF44336)
                  : const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getEventIcon(event['type']),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event['title'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ThemeUtils.getTextPrimaryColor(context, ref),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.pets,
                size: 11,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  event['pet'],
                  style: TextStyle(
                    fontSize: 10,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 11,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  event['date'],
                  style: TextStyle(
                    fontSize: 10,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Hoy';
    } else if (dateOnly == tomorrow) {
      return 'Mañana';
    } else {
      const months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  Widget _buildTopVeterinaries() {
    final topVets = [
      {'name': 'Clínica Central', 'rating': 4.8, 'distance': '2.5 km'},
      {'name': 'Hospital Elite', 'rating': 4.9, 'distance': '3.2 km'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Veterinarias Destacadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(navigationNotifierProvider.notifier).changeTab(2);
              },
              child: Text(
                'Ver todas',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: topVets
              .map(
                (vet) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: topVets.indexOf(vet) == 0 ? 8 : 0,
                    ),
                    child: _buildVeterinaryCardCompact(vet),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildVeterinaryCardCompact(Map<String, dynamic> vet) {
    return GestureDetector(
      onTap: () {
        ref.read(navigationNotifierProvider.notifier).changeTab(2);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E88E5).withValues(alpha: 0.1),
              const Color(0xFF1565C0).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vet['name'] as String,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeUtils.getTextPrimaryColor(context, ref),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC107), size: 12),
                const SizedBox(width: 2),
                Text(
                  '${vet['rating']}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeUtils.getTextPrimaryColor(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: ThemeUtils.getTextSecondaryColor(context, ref),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  vet['distance'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemeUtils.getTextSecondaryColor(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantCompact() {
    return GestureDetector(
      onTap: () => _showAIAssistantModal(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Asistente IA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '¿Tienes alguna pregunta?',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.event_note;
      case 'reminder':
        return Icons.notifications_active;
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

  void _showAIAssistantModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AIAssistantModal(),
    );
  }
}

class _AIAssistantModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AIAssistantModal> createState() => _AIAssistantModalState();
}

class _AIAssistantModalState extends ConsumerState<_AIAssistantModal> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  Future<void> _initializeConversation() async {
    final currentConv = ref.read(aiChatProvider).currentConversation;

    if (currentConv == null) {
      await ref
          .read(aiChatProvider.notifier)
          .createConversation(title: 'Consulta sobre mascotas');
    }

    setState(() {
      _isInitialized = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiChatProvider);
    final currentConv = aiState.currentConversation;
    final messages = currentConv?.messages ?? [];
    final isSending = aiState.isSendingMessage;

    if (!_isInitialized) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asistente IA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Consulta sobre el cuidado de tus mascotas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
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
          ),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Hola! Soy tu asistente IA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¿En qué puedo ayudarte con el cuidado\nde tu mascota?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(context, message);
                    },
                  ),
          ),
          if (isSending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.psychology,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pensando...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !isSending,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: isSending ? null : _sendMessage,
                  backgroundColor: isSending
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.send,
                    color: isSending
                        ? Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3)
                        : Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, dynamic message) {
    final isUser = message.role == 'user';
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
              ).colorScheme.primary.withValues(alpha: 0.1),
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
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content,
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
              ).colorScheme.primary.withValues(alpha: 0.1),
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentConv = ref.read(aiChatProvider).currentConversation;
    if (currentConv == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    final success = await ref
        .read(aiChatProvider.notifier)
        .sendMessage(conversationId: currentConv.id, content: content);

    if (success && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar mensaje. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

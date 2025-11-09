import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  final Map<String, dynamic> _userProfile = {
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

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
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
                      _buildProfileHeader(),
                      _buildSettingsSection(),
                      _buildPreferencesSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
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
          Text(
            _userProfile['name'] ?? 'Usuario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getTextPrimaryColor(context, ref),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userProfile['email'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: ThemeUtils.getTextSecondaryColor(context, ref),
            ),
          ),
          const SizedBox(height: 8),
          if (_userProfile['bio'] != null && _userProfile['bio'].isNotEmpty)
            Text(
              _userProfile['bio'],
              style: TextStyle(
                fontSize: 14,
                color: ThemeUtils.getTextSecondaryColor(context, ref),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
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
            color: ThemeUtils.getTextPrimaryColor(context, ref),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: ThemeUtils.getTextSecondaryColor(context, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildPreferencesSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Text(
            'Preferencias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getTextPrimaryColor(context, ref),
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
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return ListTile(
      leading: Icon(
        themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Tema de la aplicación',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemeUtils.getTextPrimaryColor(context, ref),
        ),
      ),
      subtitle: Text(
        _getThemeDescription(themeMode),
        style: TextStyle(
          fontSize: 14,
          color: ThemeUtils.getTextSecondaryColor(context, ref),
        ),
      ),
      trailing: PopupMenuButton<ThemeMode>(
        icon: Icon(
          Icons.arrow_drop_down,
          color: ThemeUtils.getTextSecondaryColor(context, ref),
        ),
        onSelected: (ThemeMode mode) {
          themeNotifier.setTheme(mode);
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuItem<ThemeMode>(
            value: ThemeMode.light,
            child: Row(
              children: [
                Icon(
                  Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text('Claro'),
                if (themeMode == ThemeMode.light)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
          PopupMenuItem<ThemeMode>(
            value: ThemeMode.dark,
            child: Row(
              children: [
                Icon(
                  Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text('Oscuro'),
                if (themeMode == ThemeMode.dark)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
          PopupMenuItem<ThemeMode>(
            value: ThemeMode.system,
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Text('Sistema'),
                if (themeMode == ThemeMode.system)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
              subtitle: const Text(
                'Permitir compartir ubicación con veterinarias',
              ),
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
        content: const Text(
          'Versión 1.0.0\n\nUna aplicación para el cuidado de tus mascotas.',
        ),
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
          color: ThemeUtils.getTextPrimaryColor(context, ref),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: ThemeUtils.getTextSecondaryColor(context, ref),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: ThemeUtils.getTextSecondaryColor(context, ref),
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
          color: ThemeUtils.getTextPrimaryColor(context, ref),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: ThemeUtils.getTextSecondaryColor(context, ref),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _updatePreference(String key, bool value) {
    setState(() {
      if (_userProfile['preferences'] == null) {
        _userProfile['preferences'] = {};
      }
      _userProfile['preferences'][key] = value;
    });
  }
}

# 🐕 Woofy - Tu Asistente Digital para Mascotas

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/Riverpod-4A90E2?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod">
</div>

<div align="center">
  <h3>🌟 La aplicación móvil que revoluciona el cuidado de tus mascotas</h3>
  <p>Gestiona citas veterinarias, mantén un registro de vacunas, encuentra clínicas cercanas y mucho más</p>
</div>

---

## 📱 Características Principales

### 🏠 **Pantalla Principal**
- 📊 Dashboard con resumen de mascotas
- 📅 Próximas citas veterinarias
- 🎯 Acceso rápido a todas las funciones
- 🌙 Soporte para tema claro y oscuro

### 🐕 **Gestión de Mascotas**
- ➕ Agregar nuevas mascotas
- 📝 Registro completo de información
- 💉 Seguimiento de vacunas
- 📋 Historial médico detallado

### 📅 **Sistema de Citas**
- 🗓️ Calendario integrado
- ⏰ Recordatorios automáticos
- 📍 Localización de clínicas
- 🔄 Estados de citas (programada, confirmada, completada)

### 🗺️ **Mapa de Clínicas**
- 📍 Geolocalización de veterinarias
- ⭐ Sistema de calificaciones
- 🏥 Información de contacto
- 🔍 Filtros por especialidad

### 👤 **Perfil de Usuario**
- ⚙️ Configuraciones personalizadas
- 🌙 Toggle de tema oscuro/claro
- 📊 Estadísticas de mascotas
- 🔔 Gestión de notificaciones

---

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Flutter** | 3.x | Framework de desarrollo móvil |
| **Dart** | 3.x | Lenguaje de programación |
| **Riverpod** | 2.4.9 | Gestión de estado |
| **Supabase** | Latest | Backend y base de datos |
| **Go Router** | 12.x | Navegación |
| **SharedPreferences** | 2.2.2 | Almacenamiento local |

---

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (3.0 o superior)
- Dart SDK (3.0 o superior)
- Android Studio / VS Code
- Cuenta de Supabase

### Pasos de Instalación

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/woofyapp.git
   cd woofyapp
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura Supabase**
   - Crea un proyecto en [Supabase](https://supabase.com)
   - Copia la URL y API Key
   - Actualiza las credenciales en `lib/main.dart`

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

---

## 📁 Estructura del Proyecto

```
lib/
├── 📱 main.dart                    # Punto de entrada
├── ⚙️ config/                     # Configuraciones
│   ├── app_config.dart            # Colores y estilos
│   └── theme_utils.dart           # Utilidades de tema
├── 🔄 providers/                  # Gestión de estado
│   ├── theme_provider.dart       # Control de temas
│   └── pet_provider.dart         # Datos de mascotas
├── 📱 screens/                    # Pantallas de la app
│   ├── home/                     # Pantalla principal
│   ├── profile/                  # Perfil del usuario
│   ├── map/                      # Mapa de clínicas
│   ├── calendar/                 # Calendario
│   └── appointments/             # Gestión de citas
├── 🧭 router/                    # Navegación
│   └── app_router.dart          # Configuración de rutas
└── 🎨 theme/                     # Temas y estilos
    └── app_theme.dart            # Definición de temas
```

---

## 🎨 Sistema de Temas

Woofy incluye un sistema completo de temas que se adapta a las preferencias del usuario:

### 🌞 Tema Claro
- Fondo: Blanco y grises claros
- Texto: Negro y grises oscuros
- Acentos: Azul corporativo (#1E88E5)

### 🌙 Tema Oscuro
- Fondo: Negro y grises oscuros
- Texto: Blanco y grises claros
- Acentos: Azul corporativo (#1E88E5)

### 🔧 Implementación
```dart
// Cambio dinámico de tema
ref.watch(themeModeProvider)
ThemeUtils.getTextPrimaryColor(context, ref)
ThemeUtils.getCardColor(context, ref)
```

---

## 📱 Capturas de Pantalla

<div align="center">
  <img src="screenshots/home-light.png" alt="Pantalla Principal - Tema Claro" width="200">
  <img src="screenshots/home-dark.png" alt="Pantalla Principal - Tema Oscuro" width="200">
  <img src="screenshots/pets.png" alt="Gestión de Mascotas" width="200">
  <img src="screenshots/calendar.png" alt="Calendario" width="200">
</div>

---

## 🚀 Funcionalidades Avanzadas

### 🔄 Gestión de Estado con Riverpod
- Estado reactivo y eficiente
- Providers para datos globales
- Notificadores para cambios de estado

### 🎨 UI/UX Adaptativa
- Diseño responsivo
- Animaciones fluidas
- Iconografía consistente
- Tipografía optimizada

### 📱 Características Nativas
- Geolocalización
- Notificaciones push
- Almacenamiento local
- Sincronización en la nube

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si quieres mejorar Woofy:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Desarrollado por

**Tu Nombre** - [@tu-usuario](https://github.com/tu-usuario)

---

## 🙏 Agradecimientos

- Flutter Team por el increíble framework
- Supabase por el backend as a service
- Riverpod por la gestión de estado
- Comunidad Flutter por el apoyo constante

---

<div align="center">
  <h3>🐕 ¡Haz que el cuidado de tu mascota sea más fácil con Woofy!</h3>
  <p>⭐ Si te gusta el proyecto, ¡dale una estrella!</p>
</div>
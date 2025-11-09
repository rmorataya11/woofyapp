import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Bienvenido a Woofy',
      description:
          'Centraliza el cuidado de tu perrito en una sola app con guía responsable y acciones rápidas.',
      imagePath: 'assets/images/onboarding1.png',
      heroColor: const Color(0xFF1E88E5),
    ),
    OnboardingData(
      title: 'Asistente IA Inteligente',
      description:
          'Obtén diagnósticos preliminares y recomendaciones personalizadas para el bienestar de tu mascota.',
      imagePath: 'assets/images/onboarding2.png',
      heroColor: const Color(0xFF42A5F5),
    ),
    OnboardingData(
      title: 'Encuentra Veterinarias',
      description:
          'Localiza clínicas cercanas con precios, tiempos de espera y especialidades disponibles.',
      imagePath: 'assets/images/onboarding3.png',
      heroColor: const Color(0xFF1E88E5),
    ),
    OnboardingData(
      title: 'Calendario de Cuidados',
      description:
          'Organiza vacunas, desparasitación y controles médicos con recordatorios automáticos.',
      imagePath: 'assets/images/onboarding4.png',
      heroColor: const Color(0xFF42A5F5),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRouter.login);
    }
  }

  void _skipOnboarding() {
    context.go(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text(
                      'Omitir',
                      style: TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_onboardingData[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFF1E88E5)
                                : const Color(0xFFBDBDBD),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Comenzar'
                              : 'Siguiente',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: data.heroColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(125),
              border: Border.all(
                color: data.heroColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                _getIconForPage(_onboardingData.indexOf(data)),
                size: 120,
                color: data.heroColor,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF616161),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.pets;
      case 1:
        return Icons.psychology;
      case 2:
        return Icons.location_on;
      case 3:
        return Icons.calendar_today;
      default:
        return Icons.pets;
    }
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final Color heroColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.heroColor,
  });
}

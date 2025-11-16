import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openai_apps_sdk/openai_apps_sdk.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Card Providers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CreditCardCarouselPage(),
    );
  }
}

final _openAiAppsSdkBridge = OpenAiAppsSDKBridge();

class CreditCardProvider {
  final String name;
  final String logoUrl;
  final String cashback;
  final Color color;
  final Color accentColor;
  final List<String> benefits;
  final String url;

  CreditCardProvider({
    required this.name,
    required this.logoUrl,
    required this.cashback,
    required this.color,
    required this.accentColor,
    required this.benefits,
    required this.url,
  });
}

class CreditCardCarouselPage extends StatefulWidget {
  const CreditCardCarouselPage({super.key});

  @override
  State<CreditCardCarouselPage> createState() => _CreditCardCarouselPageState();
}

class _CreditCardCarouselPageState extends State<CreditCardCarouselPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  double _currentPage = 0;
  late AnimationController _animationController;

  final List<CreditCardProvider> providers = [
    CreditCardProvider(
      name: 'BROU',
      url: 'https://www.brou.com.uy/personas/inicio',
      logoUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpawo635e0N97fH0sXZ-uMT2xmpFZkglDgefHWhAZF13eBi7UK_8UdTruqYO878FbZSE4&usqp=CAU',
      benefits: [
        '10% de descuento en farmacias',
        'Seguro de asistencia en viajes',
        'Protección de compras durante 45 días',
        'Adelantos en efectivo 24/7',
        'Tarjeta Recompensa: 1% de cashback real (1 punto = \$1)',
      ],
      cashback: 'Puntos',
      color: const Color(0xff1360aa),
      accentColor: const Color(0xffffcd19),
    ),
    CreditCardProvider(
      name: 'Santander',
      url: 'https://www.santander.com.uy',
      logoUrl:
          'https://yt3.googleusercontent.com/ytc/AIdro_kZeDaK_LZjpnvoc0y0EakJi6a6HGYyjTxXQs_dxrGxWuk=s900-c-k-c0x00ffffff-no-rj',
      benefits: [
        'Hasta 25% de descuento con tarjetas Select y Platinum',
        '15% de descuento con tarjetas estándar en comercios adheridos',
        'Hasta 50% de descuento con tarjetas Infinite y Black en ciertos comercios',
      ],
      cashback: 'Puntos',
      color: const Color(0xffec1611),
      accentColor: const Color(0xffb0b8ba),
    ),
    CreditCardProvider(
      name: 'Itaú',
      url: 'https://www.itau.com.uy',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Itaú_Unibanco_logo_2023.svg/1200px-Itaú_Unibanco_logo_2023.svg.png',
      benefits: [
        'Programa Volar: acumulación de millas',
        'Programa LATAM Pass con acumulación de millas para vuelos LATAM',
        '25% de descuento en restaurantes y librerías ',
        'Comisión bonificada del 2% + IVA por compras en el exterior',
      ],
      cashback: 'Millas',
      color: const Color(0xffee7000),
      accentColor: const Color(0xffb0b8ba),
    ),
    CreditCardProvider(
      name: 'BBVA',
      url: 'https://www.bbva.com.uy',
      logoUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTYY9AzQjQMkWFxWUSuxARxl0_I7RG-SdsAaw&s',
      benefits: [
        'Canje de puntos por viajes, experiencias y compras',
        'Descuentos del 15-30% en más de 200 comercios',
        'Sin comisiones en el exterior con tarjetas Visa Infinite o Mastercard Black',
      ],
      cashback: 'Puntos',
      color: const Color(0xff071a95),
      accentColor: const Color(0xffb0b8ba),
    ),
    CreditCardProvider(
      name: 'Scotiabank',
      url: 'https://www.scotiabank.com.uy',
      logoUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTO07JLMiSQN076fJaGPYbRf8uugg8QyQLlGg&s',
      benefits: [
        'Acceso a Sala VIP del Aeropuerto de Carrasco',
        'Seguro de accidentes en viajes hasta USD 75,000-300,000',
        'Descuentos exclusivos en comercios adheridos',
        'Protección de compras contra robo o daño accidental',
      ],
      cashback: 'Puntos',
      color: const Color(0xfff01912),
      accentColor: const Color(0xffb0b8ba),
    ),
    CreditCardProvider(
      name: 'Oca',
      url: 'https://www.oca.com.uy',
      logoUrl:
          'https://yt3.googleusercontent.com/ytc/AIdro_mQaSEXRePooMwI9C277iIWTibrw4JJW5lBpz__dNrYIj0=s900-c-k-c0x00ffffff-no-rj',
      benefits: [
        'Compras en 10 cuotas en Uruguay y 3 cuotas en el exterior',
        'Cobertura de asistencia en viajes hasta USD 10,000',
        'Límite de crédito único entre tarjetas Mastercard y Visa',
        'Seguro sobre saldo que cubre deudas en caso de fallecimiento',
      ],
      cashback: 'Metros',
      color: const Color(0xFF006FCF),
      accentColor: const Color(0xFF00D4FF),
    ),
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.55);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _animationController,
                    child: const Text(
                      'Proveedores en Uruguay',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  return _buildCard(index);
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  providers.length,
                  _buildPageIndicator,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final provider = providers[index];
    final difference = index - _currentPage;
    final scale = math.max(0.8, 1 - difference.abs() * 0.2);
    final opacity = math.max(0.5, 1 - difference.abs() * 0.3);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: scale),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [provider.color, provider.color.withOpacity(0.8)],
            ),
            boxShadow: [
              BoxShadow(
                color: provider.color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -50,
                  top: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: provider.accentColor.withOpacity(0.2),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.launch, color: Colors.white),
                    onPressed: () {
                      // Open the url
                      _openAiAppsSdkBridge.openExternal(provider.url);
                    },
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Logo and Name
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        provider.logoUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.account_balance,
                                                size: 40,
                                                color: Colors.grey,
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    provider.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: provider.accentColor.withOpacity(
                                        0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          provider.cashback,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Right side - Benefits
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Beneficios',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...provider.benefits.asMap().entries.map((
                                    entry,
                                  ) {
                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: 1),
                                      duration: Duration(
                                        milliseconds: 400 + (entry.key * 100),
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(20 * (1 - value), 0),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: provider.accentColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                entry.value,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentPage.round();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

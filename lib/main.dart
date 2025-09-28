import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/security/security_manager.dart';
import 'core/utils/cache_config.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';
import 'shared/theme/app_theme.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/settings_provider.dart';
import 'shared/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await _initializeServices();

  runApp(const SwivelSecureApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize cache configuration
    await CacheConfig.initialize();

    // Initialize Firebase services
    await FirebaseService.instance.initialize();

    // Initialize security manager
    await SecurityManager.instance.initialize();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (e) {
    // Log initialization error
    debugPrint('Failed to initialize services: $e');
  }
}

class SwivelSecureApp extends StatelessWidget {
  const SwivelSecureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0), // Prevent text scaling
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

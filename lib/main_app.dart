import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/utils/cache_config.dart';
import 'core/enums/object_type_enum.dart';
import 'core/database/database_helper.dart';
import 'shared/services/firebase_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/biometric_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/oath_list/oath_list_screen.dart';
import 'features/otc_list/otc_list_screen.dart';
import 'features/category_list/category_list_screen.dart';
import 'features/extra_menu/extra_menu_screen.dart';
import 'features/auto_config/auto_config_screen.dart';
import 'features/permission/permission_welcome_screen.dart';

/// Main application widget converted from MainActivity.java
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  int _currentIndex = 2; // Default to home (index 2)
  bool _isLoading = false;
  String _firebaseToken = '';
  bool _autoConfig = false;
  
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppConfig.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Handle app lifecycle changes
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _isLoading = true);

      // Initialize Firebase
      await _firebaseService.initialize();
      
      // Create notification channels
      await _notificationService.createNotificationChannels();
      
      // Initialize database
      await _createDatabase();
      
      // Get Firebase token
      await _getFirebaseToken();
      
      // Initialize app configuration
      AppConfig.instance.initialize(progressListener: _showProgress);
      await AppConfig.createKeys();
      
      // Check if auto configuration is needed
      if (_shouldShowAutoConfig()) {
        _showAutoConfigScreen();
      } else {
        _showSplashScreen();
      }
      
    } catch (e) {
      debugPrint('Error initializing app: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createDatabase() async {
    try {
      await DatabaseHelper.instance.database;
      debugPrint('Database initialized successfully');
    } catch (e) {
      debugPrint('Error creating database: $e');
    }
  }

  Future<void> _getFirebaseToken() async {
    try {
      final token = await _firebaseService.getToken();
      if (token != null) {
        setState(() => _firebaseToken = token);
        debugPrint('Firebase token: $token');
      }
    } catch (e) {
      debugPrint('Error getting Firebase token: $e');
    }
  }

  bool _shouldShowAutoConfig() {
    // Check if this is an auto-config intent
    // In Flutter, this would be handled differently than Android intents
    return false; // Placeholder
  }

  void _showAutoConfigScreen() {
    setState(() => _autoConfig = true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AutoConfigScreen()),
    );
  }

  void _showSplashScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  void _onAppResumed() {
    AppConfig.instance.onMoveToForeground();
  }

  void _onAppPaused() {
    AppConfig.instance.onMoveToBackground();
  }

  void _showProgress() {
    setState(() => _isLoading = true);
    
    // Hide progress after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<bool> _onWillPop() async {
    final isRooted = CacheConfig.get('KEY_ROOTED', ObjectType.boolean) as bool? ?? false;
    
    if (isRooted) {
      return true; // Allow exit
    }
    
    if (_autoConfig) {
      return false; // Don't allow back during auto config
    }
    
    final hasPermission = CacheConfig.get('KEY_PERMISSION', ObjectType.boolean) as bool? ?? false;
    
    if (!hasPermission) {
      return true; // Allow exit if no permission
    }
    
    // Handle navigation stack
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return false;
    }
    
    return true; // Allow exit
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const OtcListScreen();
      case 1:
        return const OathListScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const ExtraMenuScreen();
      case 4:
        return const CategoryListScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _getCurrentScreen(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.security),
              label: 'OTC',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'OATH',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
          ],
        ),
      ),
    );
  }

  /// Call biometric authentication
  Future<void> callBiometrics() async {
    try {
      final isAvailable = await _biometricService.isAvailable();
      if (!isAvailable) {
        return;
      }

      final result = await _biometricService.authenticate(
        reason: 'Authenticate to access the application',
        title: 'Biometric Authentication',
        subtitle: 'Use your biometric credential to continue',
      );

      if (result) {
        debugPrint('Biometric authentication successful');
      } else {
        debugPrint('Biometric authentication failed');
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
    }
  }
}

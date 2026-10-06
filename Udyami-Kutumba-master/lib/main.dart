import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_providers.dart';
import 'core/utils/session_manager.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/main_screen.dart';
import 'features/posts/presentation/post_detail_screen.dart';
import 'package:provider/provider.dart';
import 'features/communications/viewmodels/communications_viewmodel.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  print('DEV DEBUG - main - main.dart - Initializing App');
  await SessionManager.init();
  await initTheme();
  print('DEV DEBUG - main - main.dart - App initialized, running app');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was closed
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('Error checking initial link: $e');
    }

    // Handle link when app is in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Error on deep link stream: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'post') {
      if (uri.pathSegments.length > 1) {
        final postId = uri.pathSegments[1];
        _navigateToPost(postId);
      }
    }
  }

  void _navigateToPost(String postId, [int attempts = 0]) {
    if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(postId: postId),
        ),
      );
    } else {
      if (attempts < 20) {
        Future.delayed(const Duration(milliseconds: 250), () {
          _navigateToPost(postId, attempts + 1);
        });
      } else {
        print('DEV DEBUG - _navigateToPost failed after 20 attempts');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentThemeMode, __) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CommunicationsViewModel()),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Udyami Kutumba',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light, // Forced Light Mode
            builder: (context, child) {
              final brightness = Theme.of(context).brightness;
              return Theme(
                data: Theme.of(context),
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: brightness == Brightness.light
                      ? SystemUiOverlayStyle.dark
                      : SystemUiOverlayStyle.light,
                  child: child!,
                ),
              );
            },
            home: SessionManager.isLoggedIn ? const MainScreen() : const LoginScreen(),
          ),
        );
      },
    );
  }
}
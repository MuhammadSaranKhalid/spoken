import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/auth/auth_screen.dart';
import 'package:myapp/features/call/home_screen.dart';
import 'package:myapp/features/call/in_call_screen.dart';
import 'package:myapp/features/auth/otp_screen.dart';
import 'package:myapp/features/settings/settings_screen.dart';
import 'package:myapp/features/splash/splash_screen.dart';
import 'package:myapp/core/state/call_state_notifier.dart';
import 'package:myapp/shared/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://srjfclplxoonrzczpfyz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyamZjbHBseG9vbnJ6Y3pwZnl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4Mjc3MTYsImV4cCI6MjA2NzQwMzcxNn0.kTMKC09m5xVJt662mggrqATeVqF8PpZW12joG9nqGBg',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CallStateNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final email = state.extra as String;
        return OTPScreen(email: email);
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/in-call/:channelName',
      builder: (context, state) {
        final channelName = state.pathParameters['channelName']!;
        return InCallScreen(channelName: channelName);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/otp';

    if (session == null) {
      // If not logged in, redirect to login page if not already on an auth route.
      return isAuthRoute ? null : '/login';
    } else {
      // If logged in, redirect to home if on splash, login, or otp.
      if (state.matchedLocation == '/' || isAuthRoute) {
        return '/home';
      }
    }
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Voice Chat App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

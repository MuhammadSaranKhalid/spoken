import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startCall(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 1. Request microphone permission
    final status = await Permission.microphone.request();

    if (!context.mounted) return; // Check if the widget is still in the tree

    // 2. Handle permission status
    if (status.isPermanentlyDenied) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Microphone permission is required to make calls. Please enable it in app settings.',
          ),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    } else if (!status.isGranted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required to make calls.'),
        ),
      );
      return;
    }

    // 3. Proceed with call if permission is granted
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Generate a unique channel name using user ID and timestamp
      final channelName =
          'call-${user.id.substring(0, 8)}-${DateTime.now().millisecondsSinceEpoch}';
      context.push('/in-call/$channelName');
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to start a call.'),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.record_voice_over),
        title: const Text(
          'Anonymous Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 2),
            const Text(
              'Connect Anonymously',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Press the button to start a conversation',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(flex: 1),
            SizedBox(
              height: 160,
              width: 160,
              child: ElevatedButton(
                onPressed: () => _startCall(context),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white, // Explicitly set for contrast
                  elevation: 8,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call, size: 56),
                    SizedBox(height: 8),
                    Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to connect',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                'Your identity is always private. Please be kind and respectful.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(179),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) return;
                // Go back to the login screen
                context.go('/login');
              },
              child: const Text('Sign Out'),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

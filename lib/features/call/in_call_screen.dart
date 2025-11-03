import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/core/models/call_state.dart';
import 'package:myapp/core/state/call_state_notifier.dart';

class InCallScreen extends StatefulWidget {
  final String channelName;

  const InCallScreen({super.key, required this.channelName});

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  late final AnimationController _soundWaveController;

  @override
  void initState() {
    super.initState();
    _soundWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    final callStateNotifier = context.read<CallStateNotifier>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callStateNotifier.joinChannel(widget.channelName);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundWaveController.dispose();
    context.read<CallStateNotifier>().leaveChannel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Ensure no multiple timers are running
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CallStateNotifier>(
      builder: (context, callStateNotifier, child) {
        final callState = callStateNotifier.callState;

        if (callState.isRemoteUserJoined &&
            (_timer == null || !_timer!.isActive)) {
          _startTimer();
        }

        if (!callState.isInCall && !callState.isConnecting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/home');
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'ANONYMOUS CHAT',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),
            centerTitle: true,
          ),
          body: _buildBody(context, theme, callStateNotifier),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    CallStateNotifier callStateNotifier,
  ) {
    final callState = callStateNotifier.callState;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Column(
        children: <Widget>[
          const Spacer(flex: 3),
          _buildUserInfo(theme, callState),
          const SizedBox(height: 24),
          if (callState.isRemoteUserJoined)
            _buildSoundWave(theme)
          else
            const SizedBox(height: 48),
          const Spacer(flex: 4),
          _buildToolbar(context, theme, callStateNotifier),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme, CallState callState) {
    return Column(
      children: [
        Text(
          _getStatusText(callState),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          callState.isRemoteUserJoined ? _formattedTime : 'Connecting...',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 48),
        const CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Anonymous User',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getStatusText(CallState callState) {
    if (callState.isRemoteUserJoined) return 'Connected';
    if (callState.isConnecting) return 'Finding a Match';
    return 'Waiting for User...';
  }

  Widget _buildSoundWave(ThemeData theme) {
    final barHeights = [16.0, 32.0, 48.0, 40.0, 24.0, 40.0, 48.0, 32.0, 16.0];

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(barHeights.length, (index) {
          return _AnimatedBar(
            controller: _soundWaveController,
            height: barHeights[index],
            delay: index * 0.1,
            color: Colors.white70,
          );
        }),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    ThemeData theme,
    CallStateNotifier callStateNotifier,
  ) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildToolbarButton(
            theme,
            callStateNotifier.callState.isMuted ? Icons.mic_off : Icons.mic,
            'Mute',
            () => callStateNotifier.toggleMute(),
            isActive: callStateNotifier.callState.isMuted,
          ),
          _buildEndCallButton(context, theme, callStateNotifier),
          _buildToolbarButton(
            theme,
            callStateNotifier.callState.isSpeakerOn
                ? Icons.volume_down
                : Icons.volume_up,
            'Speaker',
            () => callStateNotifier.toggleSpeaker(),
            isActive: callStateNotifier.callState.isSpeakerOn,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isActive = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 32),
          style: IconButton.styleFrom(
            backgroundColor: isActive ? Colors.white30 : Colors.white12,
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEndCallButton(
    BuildContext context,
    ThemeData theme,
    CallStateNotifier callStateNotifier,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.call_end, color: Colors.white, size: 36),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            padding: const EdgeInsets.all(20),
          ),
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final confirmed = await _showEndCallConfirmation(context);
            if (confirmed == true) {
              callStateNotifier.leaveChannel();
            }
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'End Call',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Future<bool?> _showEndCallConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call?'),
        content: const Text('Are you sure you want to end the current call?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('End Call'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController controller;
  final double height;
  final double delay;
  final Color color;

  const _AnimatedBar({
    required this.controller,
    required this.height,
    required this.delay,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleYTransition(
      scale: Tween(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
        ),
      ),
      child: Container(
        width: 4,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class ScaleYTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> scale;

  const ScaleYTransition({super.key, required this.scale, required this.child})
    : super(listenable: scale);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(scaleY: scale.value, child: child);
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final double width, height;
  final Widget child;

  const GlassmorphicContainer({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

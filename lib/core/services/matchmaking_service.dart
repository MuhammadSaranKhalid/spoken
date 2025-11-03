import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchmakingService {
  final SupabaseClient _client = Supabase.instance.client;
  StreamSubscription? _subscription;
  Timer? _timeoutTimer;

  Future<String> findMatch() async {
    final completer = Completer<String>();
    final currentUser = _client.auth.currentUser;

    if (currentUser == null) {
      throw Exception('User must be logged in to find a match.');
    }

    // Clean up previous subscription if any, and remove self from pool
    await cancelSearch();

    // Check if another user is already waiting
    final List<dynamic> waitingUsers = await _client
        .from('waiting_pool')
        .select()
        .neq('user_id', currentUser.id) // Don't match with self
        .eq('status', 'waiting') // Only match with users who are waiting
        .limit(1);

    if (waitingUsers.isNotEmpty) {
      // --- Match Found (Current user is the second to arrive) ---
      final opponent = waitingUsers.first;
      // Create a unique channel name to avoid collisions
      final channelName =
          'call_${currentUser.id.substring(0, 5)}_${opponent['user_id'].substring(0, 5)}_${DateTime.now().millisecondsSinceEpoch}';

      // Update the opponent's record to notify them of the match
      await _client
          .from('waiting_pool')
          .update({'status': 'matched', 'channel_name': channelName})
          .eq('user_id', opponent['user_id']);

      // The current user completes immediately with the channel name
      completer.complete(channelName);
    } else {
      // --- No Match Found (Current user is the first to arrive) ---
      // Add current user to the waiting pool
      await _client.from('waiting_pool').upsert({
        'user_id': currentUser.id,
        'status': 'waiting',
      });

      // Listen for updates on our own record
      _subscription = _client
          .from('waiting_pool')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', currentUser.id)
          .listen(
            (payload) {
              if (payload.isNotEmpty) {
                final myRecord = payload.first;
                final status = myRecord['status'];
                final channelName = myRecord['channel_name'];

                if (status == 'matched' && channelName != null) {
                  if (!completer.isCompleted) {
                    // Complete with the channel name provided by the other user
                    completer.complete(channelName);
                    // Clean up our record from the pool
                    _client
                        .from('waiting_pool')
                        .delete()
                        .eq('user_id', currentUser.id);
                    _subscription?.cancel();
                  }
                }
              }
            },
            onError: (error) {
              if (!completer.isCompleted) {
                completer.completeError('Failed to listen for matches: $error');
              }
            },
          );

      // Set a timeout for waiting
      _timeoutTimer = Timer(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          cancelSearch(); // Remove user from pool
          completer.completeError('Matchmaking timed out. Please try again.');
        }
      });
    }

    // General cleanup when the future completes for any reason
    completer.future.whenComplete(() {
      _timeoutTimer?.cancel();
      _subscription?.cancel();
    });

    return completer.future;
  }

  Future<void> cancelSearch() async {
    _timeoutTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    _timeoutTimer = null;
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      // Don't throw errors here, just try to clean up
      try {
        await _client
            .from('waiting_pool')
            .delete()
            .eq('user_id', currentUser.id);
      } catch (_) {
        // Ignore, we are just cleaning up
      }
    }
  }
}

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:myapp/core/models/call_state.dart';
import 'package:myapp/core/services/call_manager.dart';

class CallStateNotifier with ChangeNotifier {
  final CallManager _callManager;

  CallState _callState = const CallState();
  CallState get callState => _callState;

  CallStateNotifier({CallManager? callManager})
    : _callManager = callManager ?? CallManager() {
    _callManager.addEventHandler(null);
    // _callManager.addEventHandler(
    //   RtcEngineEventHandler(
    //     onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
    //       _callState = _callState.copyWith(
    //         isInCall: true,
    //         isConnecting: false,
    //         channelName: connection.channelId,
    //         localUid: connection.localUid,
    //       );
    //       notifyListeners();
    //     },
    //     onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
    //       _callState = _callState.copyWith(isRemoteUserJoined: true);
    //       notifyListeners();
    //     },
    //     onUserOffline:
    //         (
    //           RtcConnection connection,
    //           int remoteUid,
    //           UserOfflineReasonType reason,
    //         ) {
    //           _callState = _callState.copyWith(isRemoteUserJoined: false);
    //           notifyListeners();
    //         },
    //     onLeaveChannel: (RtcConnection connection, RtcStats stats) {
    //       _callState = const CallState();
    //       notifyListeners();
    //     },
    //     onError: (ErrorCodeType err, String msg) {
    //       _callState = _callState.copyWith(errorMessage: msg);
    //       notifyListeners();
    //     },
    //   ),
    // );
  }

  Future<void> joinChannel(String channelName) async {
    _callState = _callState.copyWith(isConnecting: true);
    notifyListeners();
    await _callManager.joinChannel(channelName);
  }

  Future<void> leaveChannel() async {
    await _callManager.leaveChannel();
    _callState = const CallState(); // Reset state after leaving
    notifyListeners();
  }

  Future<void> toggleMute() async {
    final isMuted = await _callManager.toggleMute();
    _callState = _callState.copyWith(isMuted: isMuted);
    notifyListeners();
  }

  Future<void> toggleSpeaker() async {
    final isSpeakerOn = await _callManager.toggleSpeaker();
    _callState = _callState.copyWith(isSpeakerOn: isSpeakerOn);
    notifyListeners();
  }
}

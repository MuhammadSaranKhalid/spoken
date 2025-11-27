import 'dart:async';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

class CallManager {
  // RtcEngine? _engine;
  // final String _appId =
  //     '6e5317356d3e49b88952b14345e5c464'; // Replace with your Agora App ID
  // final String _token =
  //     '007eJxTYPCb/5l7k8488XnPAn2T81N1bhyzE/8s1F9VdXO5xMfr7EcFBgMLM0sDc8s0U0sTU0szS8NUc0tLE0tDEwMLc0tTIzMLnBfnpDQEMjKk813LwAiFIL4IQ2FqXmJmXn4mAwMA4hEgdg==';

  bool _isMuted = false;
  bool _isSpeakerOn = true;

  // Future<void> _initializeAgora() async {
  //   if (_engine != null) return;

  //   _engine = createAgoraRtcEngine();
  //   await _engine!.initialize(RtcEngineContext(appId: _appId));

  //   await _engine!.setChannelProfile(
  //     ChannelProfileType.channelProfileCommunication,
  //   );
  //   await _engine!.enableAudio();
  //   await _engine!.setEnableSpeakerphone(_isSpeakerOn);
  // }

  void addEventHandler(dynamic handler) {
    // _engine?.registerEventHandler(handler);
  }

  Future<void> joinChannel(String channelName) async {
    // await _initializeAgora();
    // await _engine?.enableLocalAudio(true);
    // await _engine?.joinChannel(
    //   token: _token,
    //   channelId: channelName,
    //   uid: 0,
    //   options: const ChannelMediaOptions(
    //     channelProfile: ChannelProfileType.channelProfileCommunication,
    //     clientRoleType: ClientRoleType.clientRoleBroadcaster,
    //     publishMicrophoneTrack: true,
    //     autoSubscribeAudio: true,
    //   ),
    // );
  }

  Future<void> leaveChannel() async {
    // await _engine?.leaveChannel();
    // await _engine?.release();
    // _engine = null;
  }

  Future<bool> toggleMute() async {
    // if (_engine == null) return _isMuted;
    _isMuted = !_isMuted;
    // await _engine!.muteLocalAudioStream(_isMuted);
    debugPrint('🎤 Microphone ${_isMuted ? "muted" : "unmuted"}');
    return _isMuted;
  }

  Future<bool> toggleSpeaker() async {
    // if (_engine == null) return _isSpeakerOn;
    _isSpeakerOn = !_isSpeakerOn;
    // await _engine!.setEnableSpeakerphone(_isSpeakerOn);
    debugPrint('🔊 Speaker ${_isSpeakerOn ? "enabled" : "disabled"}');
    return _isSpeakerOn;
  }
}

import 'package:flutter/foundation.dart';

@immutable
class CallState {
  final bool isConnecting;
  final bool isInCall;
  final bool isRemoteUserJoined;
  final bool isMuted;
  final bool isSpeakerOn;
  final String? channelName;
  final int? localUid;
  final String? errorMessage;

  const CallState({
    this.isConnecting = false,
    this.isInCall = false,
    this.isRemoteUserJoined = false,
    this.isMuted = false,
    this.isSpeakerOn = true,
    this.channelName,
    this.localUid,
    this.errorMessage,
  });

  CallState copyWith({
    bool? isConnecting,
    bool? isInCall,
    bool? isRemoteUserJoined,
    bool? isMuted,
    bool? isSpeakerOn,
    String? channelName,
    int? localUid,
    String? errorMessage,
  }) {
    return CallState(
      isConnecting: isConnecting ?? this.isConnecting,
      isInCall: isInCall ?? this.isInCall,
      isRemoteUserJoined: isRemoteUserJoined ?? this.isRemoteUserJoined,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      channelName: channelName ?? this.channelName,
      localUid: localUid ?? this.localUid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

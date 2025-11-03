/// Agora Configuration
/// Store your Agora App ID and other configuration here
/// For production, use environment variables or secure storage
class AgoraConfig {
  // IMPORTANT: Replace with your actual Agora App ID
  static const String appId = '314633f82cfd4e85bfbc2b62f0d5a80b';

  // Token server URL (for production)
  // Example: https://your-token-server.com
  static const String tokenServerUrl = '';

  // For testing only - leave empty for production with token authentication
  static const String testToken =
      '007eJxTYPg7V7B+x7c/N8s9v2T1kY/7N/LdtvRz2e+3Zf578t1A4kcFBlNEI2MLU1MLg1TLZAtLS0szsKSkWZqkWZplaWqa+f8k/ckNgYwMOQuPMDIwAiFIL4MhxlsYAgAZgR+g';

  // Channel name for testing
  static const String testChannelName = 'test-channel';

  // Token expiration time (in seconds) - max 24 hours
  static const int tokenExpirationTime = 3600 * 24;

  // Audio settings
  static const int audioSampleRate = 48000;
  static const int audioBitrate = 48;

  // Call settings
  static const int maxCallDuration = 3600; // 1 hour in seconds

  // Validate configuration
  static bool get isConfigured =>
      appId != 'YOUR_AGORA_APP_ID' && appId.isNotEmpty;
}

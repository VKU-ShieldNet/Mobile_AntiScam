// lib/core/network/network_info.dart
// Purpose: Abstraction for checking network connectivity.
// How to use: Implement this using connectivity_plus or similar package and register in DI.

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// Example placeholder implementation (replace with real impl using Connectivity)
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

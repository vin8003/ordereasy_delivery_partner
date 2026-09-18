import 'package:flutter/material.dart';

import 'rider_profile.dart';

/// Read-only rider profile / settings stub.
///
/// Shows [profile] fields. The online flag is display-only (not a
/// toggle). [onLogout] is a callback stub — this screen never clears
/// auth itself.
class ProfileScreen extends StatelessWidget {
  /// Creates the settings stub.
  const ProfileScreen({
    super.key,
    required this.profile,
    this.onLogout,
  });

  /// Fields to display.
  final RiderProfile profile;

  /// Invoked when the rider taps Log out.
  ///
  /// Hosts should wire real session teardown here. This package does
  /// not call auth logout.
  final VoidCallback? onLogout;

  bool get _hasVehicle {
    final value = profile.vehicleNumber;
    return value != null && value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Name'),
            subtitle: Text(profile.name),
          ),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text(profile.phone),
          ),
          if (_hasVehicle)
            ListTile(
              title: const Text('Vehicle number'),
              subtitle: Text(profile.vehicleNumber!),
            ),
          ListTile(
            title: const Text('Status'),
            subtitle: Text(profile.isOnline ? 'Online' : 'Offline'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('profile-logout'),
              onPressed: onLogout,
              child: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}

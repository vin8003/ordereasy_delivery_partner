import 'package:flutter/material.dart';

import 'map_launcher_stub.dart';
import 'map_stop.dart';

/// Minimal placeholder that shows a stop's coordinates and an Open in maps action.
///
/// The callback receives the stub URL. This widget does not launch anything
/// and does not render a real map.
class MapStubPlaceholder extends StatelessWidget {
  /// Creates a coordinates placeholder for [stop].
  const MapStubPlaceholder({
    super.key,
    required this.stop,
    required this.onOpenInMaps,
    this.launcher = const MapLauncherStub(),
  });

  /// Stop to display.
  final MapStop stop;

  /// Invoked with the stub maps URL when the user taps Open in maps.
  final ValueChanged<String> onOpenInMaps;

  /// URL builder used when the action is pressed.
  final MapLauncherStub launcher;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(stop.label),
        Text('${stop.lat}, ${stop.lng}'),
        TextButton(
          onPressed: () => onOpenInMaps(launcher.urlFor(stop)),
          child: const Text('Open in maps'),
        ),
      ],
    );
  }
}

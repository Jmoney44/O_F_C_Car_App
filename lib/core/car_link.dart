import 'config.dart';

/// Builds and reads the text stored inside a car's QR code.
abstract final class CarLink {
  static final _idPattern = RegExp(r'^[A-Za-z0-9_-]{4,64}$');

  static String forCar(String carId) => '${AppConfig.carLinkBase}/$carId';

  /// Returns the car id held in [raw], or null when the scanned text is not
  /// an OFC car code. Accepts a full link (`https://…/car/<id>`) from any
  /// domain, or the bare id.
  static String? parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    if (_idPattern.hasMatch(text)) return text;

    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final index = segments.lastIndexOf('car');
    if (index == -1 || index + 1 >= segments.length) return null;
    final id = segments[index + 1];
    return _idPattern.hasMatch(id) ? id : null;
  }
}

/// Business settings in one place. Change these before releasing.
abstract final class AppConfig {
  static const appName = 'OFC Luxury';

  /// Shown in front of every price.
  static const currencySymbol = '\$';

  /// Every car QR code holds `<carLinkBase>/<carId>`.
  ///
  /// Point this at a domain you own (for example the Firebase Hosting domain
  /// of the project) so that scanning with an ordinary phone camera can also
  /// open the app. Codes printed with an old value keep working inside the
  /// in-app scanner because only the car id at the end is read.
  static const carLinkBase = 'https://ofcluxury.example/car';

  /// Showroom contact details used by the "Contact showroom" actions.
  static const showroomPhone = '+10000000000';
  static const showroomEmail = 'sales@ofcluxury.example';
  static const showroomAddress = 'OFC Luxury Showroom';
}

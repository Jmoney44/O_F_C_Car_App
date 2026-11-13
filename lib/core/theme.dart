import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const ink = Color(0xFF17181C);
  static const gold = Color(0xFFB8935A);
  static const success = Color(0xFF2E7D4F);
  static const warning = Color(0xFFB7791F);
  static const danger = Color(0xFFC53030);
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.gold,
        brightness: brightness,
      ).copyWith(
        primary: dark ? const Color(0xFFE2C28F) : AppColors.ink,
        onPrimary: dark ? AppColors.ink : Colors.white,
        secondary: dark ? const Color(0xFFD9B77E) : AppColors.gold,
        // Neutral surfaces so the gold stays an accent instead of tinting
        // every card and field.
        surface: dark ? const Color(0xFF121316) : Colors.white,
        surfaceContainerLowest: dark ? const Color(0xFF0D0E10) : Colors.white,
        surfaceContainerLow: dark
            ? const Color(0xFF1B1C20)
            : const Color(0xFFF5F5F7),
        surfaceContainer: dark
            ? const Color(0xFF1F2025)
            : const Color(0xFFF0F0F3),
        surfaceContainerHigh: dark
            ? const Color(0xFF26272D)
            : const Color(0xFFEAEAEE),
        surfaceContainerHighest: dark
            ? const Color(0xFF2E3036)
            : const Color(0xFFE4E4E9),
        secondaryContainer: dark
            ? const Color(0xFF3D3220)
            : const Color(0xFFF4EBDD),
        onSecondaryContainer: dark
            ? const Color(0xFFF1DFC0)
            : const Color(0xFF3A2C12),
        onSurfaceVariant: dark
            ? const Color(0xFFB4B6BF)
            : const Color(0xFF6A6C76),
        outline: dark ? const Color(0xFF8A8C96) : const Color(0xFF9A9CA6),
        outlineVariant: dark
            ? const Color(0xFF3A3C43)
            : const Color(0xFFDCDCE2),
      );

  final radius = BorderRadius.circular(14);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.secondaryContainer,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

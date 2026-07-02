import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ekstensi warna kustom untuk EWS Semeru agar mendukung Light & Dark mode.
class EWSColors extends ThemeExtension<EWSColors> {
  final Color bgDark;
  final Color bgMid;
  final Color bgLight;
  final Color bgSurface;
  final Color bgCard;

  final Color accent;
  final Color accentDim;
  final Color accentGlow;
  final Color secondary;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;

  final Color divider;
  final Color dividerLight;

  final Color statusNormal;
  final Color statusWaspada;
  final Color statusSiaga;
  final Color statusAwas;

  final Color glassBackground;
  final Color glassBorder;
  final Color glassHighlight;

  final bool isLight;

  const EWSColors({
    required this.bgDark,
    required this.bgMid,
    required this.bgLight,
    required this.bgSurface,
    required this.bgCard,
    required this.accent,
    required this.accentDim,
    required this.accentGlow,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.divider,
    required this.dividerLight,
    required this.statusNormal,
    required this.statusWaspada,
    required this.statusSiaga,
    required this.statusAwas,
    required this.glassBackground,
    required this.glassBorder,
    required this.glassHighlight,
    required this.isLight,
  });

  @override
  ThemeExtension<EWSColors> copyWith({
    Color? bgDark,
    Color? bgMid,
    Color? bgLight,
    Color? bgSurface,
    Color? bgCard,
    Color? accent,
    Color? accentDim,
    Color? accentGlow,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMuted,
    Color? divider,
    Color? dividerLight,
    Color? statusNormal,
    Color? statusWaspada,
    Color? statusSiaga,
    Color? statusAwas,
    Color? glassBackground,
    Color? glassBorder,
    Color? glassHighlight,
    bool? isLight,
  }) {
    return EWSColors(
      bgDark: bgDark ?? this.bgDark,
      bgMid: bgMid ?? this.bgMid,
      bgLight: bgLight ?? this.bgLight,
      bgSurface: bgSurface ?? this.bgSurface,
      bgCard: bgCard ?? this.bgCard,
      accent: accent ?? this.accent,
      accentDim: accentDim ?? this.accentDim,
      accentGlow: accentGlow ?? this.accentGlow,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMuted: textMuted ?? this.textMuted,
      divider: divider ?? this.divider,
      dividerLight: dividerLight ?? this.dividerLight,
      statusNormal: statusNormal ?? this.statusNormal,
      statusWaspada: statusWaspada ?? this.statusWaspada,
      statusSiaga: statusSiaga ?? this.statusSiaga,
      statusAwas: statusAwas ?? this.statusAwas,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      isLight: isLight ?? this.isLight,
    );
  }

  @override
  ThemeExtension<EWSColors> lerp(covariant ThemeExtension<EWSColors>? other, double t) {
    if (other is! EWSColors) return this;
    return EWSColors(
      bgDark: Color.lerp(bgDark, other.bgDark, t)!,
      bgMid: Color.lerp(bgMid, other.bgMid, t)!,
      bgLight: Color.lerp(bgLight, other.bgLight, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDim: Color.lerp(accentDim, other.accentDim, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      dividerLight: Color.lerp(dividerLight, other.dividerLight, t)!,
      statusNormal: Color.lerp(statusNormal, other.statusNormal, t)!,
      statusWaspada: Color.lerp(statusWaspada, other.statusWaspada, t)!,
      statusSiaga: Color.lerp(statusSiaga, other.statusSiaga, t)!,
      statusAwas: Color.lerp(statusAwas, other.statusAwas, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassHighlight: Color.lerp(glassHighlight, other.glassHighlight, t)!,
      isLight: t < 0.5 ? isLight : other.isLight,
    );
  }
}

/// Tema aplikasi EWS Gunung Semeru.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // LIGHT COLORS (Clean, High Contrast, Emergency Focused)
  // ---------------------------------------------------------------------------
  static const EWSColors _lightColors = EWSColors(
    bgDark: Color(0xFFF1F5F9), // Latar paling belakang
    bgMid: Color(0xFFF8FAFC),
    bgLight: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFFFFFFF), // Latar kartu solid
    bgCard: Color(0xFFFFFFFF),
    accent: Color(0xFF009688), // Teal agak gelap agar kontras di putih
    accentDim: Color(0xFF00796B),
    accentGlow: Color(0xFF00BFA5),
    secondary: Color(0xFF1976D2), // Biru material
    textPrimary: Color(0xFF0F172A), // Hitam gelap
    textSecondary: Color(0xFF334155), // Abu gelap
    textTertiary: Color(0xFF475569), // Abu medium
    textMuted: Color(0xFF64748B), // Abu terang tapi tetap terbaca
    divider: Color(0xFFE2E8F0),
    dividerLight: Color(0xFFF1F5F9),
    statusNormal: Color(0xFF2E7D32), // Hijau material (aman terbaca)
    statusWaspada: Color(0xFFF57C00), // Oranye tua
    statusSiaga: Color(0xFFD84315), // Oranye kemerahan
    statusAwas: Color(0xFFC62828), // Merah tua (sangat kontras)
    glassBackground: Color(0xFFFFFFFF), // Solid white untuk light mode
    glassBorder: Color(0xFFE2E8F0),
    glassHighlight: Color(0x00000000), // Transparan
    isLight: true,
  );

  // ---------------------------------------------------------------------------
  // DARK COLORS (Premium Cinematic Night Mode)
  // ---------------------------------------------------------------------------
  static const EWSColors _darkColors = EWSColors(
    bgDark: Color(0xFF080C14),
    bgMid: Color(0xFF0F1923),
    bgLight: Color(0xFF162030),
    bgSurface: Color(0xFF1A2535),
    bgCard: Color(0xFF1E2C3D),
    accent: Color(0xFF00D4AA),
    accentDim: Color(0xFF00A88A),
    accentGlow: Color(0xFF00D4AA),
    secondary: Color(0xFF4A9EFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFE2E8F0),
    textTertiary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF94A3B8),
    divider: Color(0xFF243A52),
    dividerLight: Color(0xFF334A66),
    statusNormal: Color(0xFF00E676),
    statusWaspada: Color(0xFFFFB74D),
    statusSiaga: Color(0xFFFF7043),
    statusAwas: Color(0xFFFF5252),
    glassBackground: Color(0x0FFFFFFF), // white.withValues(alpha: 0.06)
    glassBorder: Color(0x1EFFFFFF), // white.withValues(alpha: 0.12)
    glassHighlight: Color(0x19FFFFFF), // white.withValues(alpha: 0.10)
    isLight: false,
  );

  // ---------------------------------------------------------------------------
  // LIGHT THEME CONFIG
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final base = ThemeData(
      brightness: Brightness.light,
      primaryColor: _lightColors.accent,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        primary: _lightColors.accent,
        secondary: _lightColors.secondary,
        surface: _lightColors.bgCard,
        onSurface: _lightColors.textPrimary,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        _lightColors,
      ],
    );

    return _buildTheme(base, _lightColors);
  }

  // ---------------------------------------------------------------------------
  // DARK THEME CONFIG
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    final base = ThemeData(
      brightness: Brightness.dark,
      primaryColor: _darkColors.accent,
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: _darkColors.accent,
        secondary: _darkColors.secondary,
        surface: _darkColors.bgCard,
        onSurface: _darkColors.textPrimary,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        _darkColors,
      ],
    );

    return _buildTheme(base, _darkColors);
  }

  // ---------------------------------------------------------------------------
  // SHARED THEME BUILDER
  // ---------------------------------------------------------------------------
  static ThemeData _buildTheme(ThemeData base, EWSColors colors) {
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        titleTextStyle: GoogleFonts.inter(
          color: colors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
        actionsIconTheme: IconThemeData(color: colors.textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: colors.accent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.accent,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.accent, size: 24);
          }
          return IconThemeData(color: colors.textTertiary, size: 22);
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SPACING CONSTANTS
  // ---------------------------------------------------------------------------
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;

  static const double radiusS = 10;
  static const double radiusM = 16;
  static const double radiusL = 20;
  static const double radiusXL = 24;
}

// =============================================================================
// BUILD CONTEXT EXTENSIONS (Untuk kemudahan akses di UI)
// =============================================================================
extension AppThemeContextExtension on BuildContext {
  /// Mendapatkan akses ke custom colors
  EWSColors get ewsColors => Theme.of(this).extension<EWSColors>()!;

  /// Text Styles
  TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: ewsColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      );

  TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: ewsColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.3,
      );

  TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ewsColors.textPrimary,
        letterSpacing: -0.2,
      );

  TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ewsColors.textPrimary,
        height: 1.5,
      );

  TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ewsColors.textSecondary,
        height: 1.5,
      );

  TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ewsColors.textTertiary,
        letterSpacing: 0.5,
      );

  TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: ewsColors.textMuted,
        letterSpacing: 1.0,
      );

  TextStyle get sensorValue => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: ewsColors.textPrimary,
        letterSpacing: -0.5,
      );

  TextStyle get numericLarge => GoogleFonts.inter(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        color: ewsColors.textPrimary,
        letterSpacing: -1.0,
      );

  /// Helpers
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: ewsColors.isLight
            ? [ewsColors.bgDark, ewsColors.bgDark] // Solid di light mode
            : [ewsColors.bgDark, ewsColors.bgMid, ewsColors.bgLight],
        stops: ewsColors.isLight ? [0.0, 1.0] : [0.0, 0.5, 1.0],
      );

  BoxDecoration glassDecoration({
    double borderRadius = AppTheme.radiusM,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? ewsColors.glassBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? ewsColors.glassBorder,
        width: 1,
      ),
      boxShadow: ewsColors.isLight
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          : null, // Dark mode tidak pakai shadow di tiap card
    );
  }

  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: ewsColors.isLight ? 0.1 : 0.4),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  List<BoxShadow> glowShadow(Color color) {
    return ewsColors.isLight
        ? [] // No glow in light mode
        : [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 32,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 64,
              offset: const Offset(0, 4),
              spreadRadius: -8,
            ),
          ];
  }

  List<BoxShadow> get accentGlowShadow => ewsColors.isLight
      ? [
          BoxShadow(
            color: ewsColors.accent.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      : [
          BoxShadow(
            color: ewsColors.accent.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ];
}

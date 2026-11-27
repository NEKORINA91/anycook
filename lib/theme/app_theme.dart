import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// AnyCook "soft glow" palette — matches the AnyCook redesign canvas.
class AppColors {
  AppColors._();

  static const bg = Color(0xFFFCFAF7); // page background
  static const surface = Color(0xFFFFFFFF); // cards
  static const stone = Color(0xFFF4EFE9); // quiet fills, segmented controls
  static const line = Color(0xFFEEE8E1); // card borders
  static const lineStrong = Color(0xFFE7E1DA); // inputs, outline buttons
  static const ink = Color(0xFF1C1917); // main text, dark buttons
  static const muted = Color(0xFF6B635C); // secondary text

  static const accent = Color(0xFFC2410C); // buttons, links (passes contrast on white)
  static const accentBright = Color(0xFFF26B1D); // icon squares, highlights
  static const accentSoft = Color(0xFFFFF1E8); // selected chip fill
  static const accentInk = Color(0xFF9A3412); // text on accentSoft

  static const lilac = Color(0xFFEDE7FB);
  static const lilacInk = Color(0xFF4C3A99);
  static const lilacDeep = Color(0xFF2E2266);
  static const mint = Color(0xFFE6F4EA);
  static const peach = Color(0xFFFCE3CF);
  static const butter = Color(0xFFFBEFC8);

  // Match tiers
  static const greenBg = Color(0xFFE3F2E7);
  static const greenInk = Color(0xFF1E6B3A);
  static const amberBg = Color(0xFFFCEFD6);
  static const amberInk = Color(0xFF7A4F00);
  static const redBg = Color(0xFFFBE4E1);
  static const redInk = Color(0xFF9B2C24);
  static const star = Color(0xFFE0A21B);

  // Older names still used by a few screens (signup, forgot password…)
  static const cream = bg;
  static const sand = stone;
  static const terracotta = accent;
  static const terracottaDeep = accentInk;
  static const sage = greenInk;
  static const mustard = star;
  static const brick = redInk;
}

class AppTheme {
  AppTheme._();

  /// Display font (Inter Tight, light) for headlines and titles.
  static TextStyle display({
    double size = 22,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
  }) =>
      TextStyle(
        fontFamily: 'InterTight',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: size >= 32 ? -0.035 * size : -0.02 * size,
      );

  /// Small uppercase label ("PICKED FOR YOUR KITCHEN").
  static TextStyle eyebrow({Color color = AppColors.muted}) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: color,
      );

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: AppColors.bg,
    );

    final body = base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    const shared = SharedAxisPageTransitionsBuilder(
      transitionType: SharedAxisTransitionType.horizontal,
    );

    return base.copyWith(
      textTheme: body.copyWith(
        headlineLarge: display(size: 40, weight: FontWeight.w300),
        headlineMedium: display(size: 32, weight: FontWeight.w300),
        headlineSmall: display(size: 26),
        titleLarge: display(size: 20, weight: FontWeight.w500),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: shared,
          TargetPlatform.iOS: shared,
          TargetPlatform.windows: shared,
          TargetPlatform.macOS: shared,
          TargetPlatform.linux: shared,
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: display(size: 20, weight: FontWeight.w500),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 48),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          side: const BorderSide(color: AppColors.lineStrong),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.stone,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.accent : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.surface),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(fontFamily: 'Inter', color: AppColors.muted, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lineStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// True when the user asked the OS to reduce motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Staggered fade + slide entrance for a list of widgets.
List<Widget> staggerIn(
  BuildContext context,
  List<Widget> children, {
  Axis axis = Axis.vertical,
  Duration interval = const Duration(milliseconds: 60),
}) {
  if (reduceMotion(context)) return children;
  return children
      .animate(interval: interval)
      .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
      .move(
        begin: axis == Axis.vertical ? const Offset(0, 14) : const Offset(18, 0),
        end: Offset.zero,
        duration: 420.ms,
        curve: Curves.easeOutCubic,
      );
}

/// Gentle press-to-shrink + hover-lift wrapper for tappable cards.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const Pressable({super.key, required this.child, this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : (_hovered ? 1.015 : 1.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

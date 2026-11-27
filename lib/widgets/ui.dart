import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/screens/kitchen_setup_screen.dart';
import 'package:anycook/screens/login_screen.dart';
import 'package:anycook/screens/profile_screen.dart';
import 'package:anycook/screens/recipe_upload_screen.dart';
import 'package:anycook/screens/search_results_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Responsive helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Width at which we switch from the phone layout to the desktop layout.
const double kWideBreakpoint = 900;

bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kWideBreakpoint;

/// Horizontal page padding: roomier on desktop.
double pagePadding(BuildContext context) => isWide(context) ? 32 : 18;

/// Centers content and caps it at 1240px, like the canvas pages.
class PageWidth extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PageWidth({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: pagePadding(context)),
          child: child,
        ),
      ),
    );
  }
}

/// Two columns side by side when there's room, stacked otherwise.
class SplitLayout extends StatelessWidget {
  final Widget first;
  final Widget second;
  final int firstFlex;
  final int secondFlex;
  final double breakpoint;
  final double gap;
  final CrossAxisAlignment align;

  const SplitLayout({
    super.key,
    required this.first,
    required this.second,
    this.firstFlex = 1,
    this.secondFlex = 1,
    this.breakpoint = kWideBreakpoint,
    this.gap = 32,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth >= breakpoint) {
        return Row(
          crossAxisAlignment: align,
          children: [
            Expanded(flex: firstFlex, child: first),
            SizedBox(width: gap),
            Expanded(flex: secondFlex, child: second),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [first, SizedBox(height: gap * 0.75), second],
      );
    });
  }
}

/// Grid that fits as many columns as possible with at least [minItemWidth].
class AutoGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double gap;

  const AutoGrid({
    super.key,
    required this.children,
    this.minItemWidth = 260,
    this.gap = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = ((c.maxWidth + gap) / (minItemWidth + gap)).floor().clamp(1, 6);
      final itemWidth = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: itemWidth, child: child),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background glow (the soft peach / lilac / mint light from the reference)
// ─────────────────────────────────────────────────────────────────────────────

class GlowBackground extends StatelessWidget {
  final Widget child;
  final Color base;

  const GlowBackground({super.key, required this.child, this.base = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: base,
      child: Stack(
        children: [
          const Positioned.fill(child: _Glow(alignment: Alignment(0.6, -0.5), color: Color(0xFFF3E8FF))),
          const Positioned.fill(child: _Glow(alignment: Alignment(-0.8, 0.5), color: Color(0xFFFFE4D2))),
          const Positioned.fill(child: _Glow(alignment: Alignment(0.1, 1.0), color: Color(0xFFE6F4EA))),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  const _Glow({required this.alignment, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: 0.9,
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation: top bar on desktop, floating dark bar on phones
// ─────────────────────────────────────────────────────────────────────────────

enum NavTab { discover, search, upload, kitchen, profile, none }

/// Go to a main section. Discover is the root route; everything else is
/// pushed on top of it so the back button always returns home.
void goToTab(BuildContext context, NavTab tab) {
  final nav = Navigator.of(context);
  nav.popUntil((r) => r.isFirst);
  Widget? page;
  switch (tab) {
    case NavTab.search:
      page = const SearchResultsScreen();
    case NavTab.upload:
      page = const RecipeUploadScreen();
    case NavTab.kitchen:
      page = const KitchenSetupScreen();
    case NavTab.profile:
      page = const ProfileScreen();
    case NavTab.discover:
    case NavTab.none:
      page = null;
  }
  final target = page;
  if (target != null) {
    nav.push(MaterialPageRoute(builder: (_) => target));
  }
}

/// Page scaffold every main screen uses: nav, scrolling body, footer space.
class AppShell extends StatelessWidget {
  final NavTab current;
  final Widget body;
  final bool glow;
  final Widget? overlay;

  const AppShell({
    super.key,
    required this.current,
    required this.body,
    this.glow = false,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TopNav(current: current),
        body,
        SizedBox(height: wide ? 48 : 120), // room for the phone nav bar
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: glow ? GlowBackground(child: content) : content,
            ),
          ),
          if (!wide)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(top: false, child: BottomNavBar(current: current)),
            ),
          ?overlay,
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 1.6,
          height: size * 1.6,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(size * 0.5),
          ),
          child: Icon(Icons.soup_kitchen_outlined, color: Colors.white, size: size * 0.95),
        ),
        SizedBox(width: size * 0.5),
        Text('AnyCook', style: AppTheme.display(size: size, weight: FontWeight.w600)),
      ],
    );
  }
}

class TopNav extends StatelessWidget {
  final NavTab current;
  const TopNav({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final wide = isWide(context);

    Widget link(String label, NavTab tab) {
      final active = current == tab;
      return TextButton(
        onPressed: () => goToTab(context, tab),
        style: TextButton.styleFrom(
          foregroundColor: active ? AppColors.accent : AppColors.ink,
          textStyle: TextStyle(fontSize: 14, fontWeight: active ? FontWeight.w600 : FontWeight.w400),
        ),
        child: Text(label),
      );
    }

    return PageWidth(
      padding: EdgeInsets.symmetric(horizontal: pagePadding(context), vertical: 14),
      child: Row(
        children: [
          Pressable(onTap: () => goToTab(context, NavTab.discover), child: const Logo()),
          if (wide) ...[
            const SizedBox(width: 24),
            link('Discover', NavTab.discover),
            link('Search', NavTab.search),
            link('My kitchen', NavTab.kitchen),
            link('Upload recipe', NavTab.upload),
          ],
          const Spacer(),
          if (appState.isLoggedIn)
            Pressable(
              onTap: () => goToTab(context, NavTab.profile),
              child: Avatar(name: appState.username, size: 40),
            )
          else if (wide) ...[
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              ),
              child: const Text('Sign in'),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: () => goToTab(context, NavTab.kitchen),
              child: const Text('Start cooking'),
            ),
          ] else
            Pressable(
              onTap: () => goToTab(context, NavTab.profile),
              child: const Avatar(name: 'Guest', size: 40),
            ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final NavTab current;
  const BottomNavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, NavTab tab) {
      final active = current == tab;
      return Semantics(
        button: true,
        label: label,
        selected: active,
        child: Pressable(
          onTap: () => goToTab(context, tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? AppColors.accentBright : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: active ? Colors.white : const Color(0xFFD6CEC5), size: 22),
          ),
        ),
      );
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(Icons.home_outlined, 'Home', NavTab.discover),
          item(Icons.search_rounded, 'Search', NavTab.search),
          item(Icons.add_rounded, 'Upload recipe', NavTab.upload),
          item(Icons.kitchen_outlined, 'My kitchen', NavTab.kitchen),
          item(Icons.person_outline_rounded, 'Profile', NavTab.profile),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small building blocks
// ─────────────────────────────────────────────────────────────────────────────

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final bool dark;

  const Avatar({super.key, required this.name, this.size = 40, this.dark = false});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? AppColors.ink : AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: AppTheme.display(
          size: size * 0.36,
          weight: FontWeight.w600,
          color: dark ? Colors.white : AppColors.accent,
        ),
      ),
    );
  }
}

/// "● RECIPES THAT FIT YOUR KITCHEN"
class Eyebrow extends StatelessWidget {
  final String text;
  final bool dot;
  final Color color;

  const Eyebrow(this.text, {super.key, this.dot = false, this.color = AppColors.muted});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.accentBright, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(text.toUpperCase(), style: AppTheme.eyebrow(color: color))),
      ],
    );
  }
}

/// White rounded card with a hairline border.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: child,
    );
  }
}

/// Small rounded label ("All ingredients", "Needs an oven").
class Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color ink;
  final double fontSize;

  const Tag({super.key, required this.label, required this.bg, required this.ink, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: ink)),
    );
  }
}

/// Green / amber / red pantry-match badge.
class TierBadge extends StatelessWidget {
  final Recipe recipe;
  final List<String> pantry;
  final bool short;

  const TierBadge({super.key, required this.recipe, required this.pantry, this.short = false});

  @override
  Widget build(BuildContext context) {
    final missing = missingFor(recipe, pantry).length;
    if (missing == 0) {
      return Tag(label: short ? 'All in' : 'All ingredients', bg: AppColors.greenBg, ink: AppColors.greenInk);
    }
    final red = missing > 2;
    return Tag(
      label: 'Missing $missing',
      bg: red ? AppColors.redBg : AppColors.amberBg,
      ink: red ? AppColors.redInk : AppColors.amberInk,
    );
  }
}

/// Case-insensitive version of Recipe.missingIngredients, so "eggs" in a
/// recipe matches "Eggs" in the pantry.
List<String> missingFor(Recipe recipe, List<String> pantry) {
  final have = pantry.map((p) => p.toLowerCase().trim()).toSet();
  return recipe.requiredIngredients.where((i) => !have.contains(i.toLowerCase().trim())).toList();
}

/// Pill used for filters ("All", "Under 5 min"…). Dark when selected.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterPill({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.ink : AppColors.lineStrong),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: selected ? Colors.white : AppColors.ink),
        ),
      ),
    );
  }
}

/// Metric / Imperial style two-way switch.
class SegmentedPill extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  const SegmentedPill({super.key, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.stone, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: i == selected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i == selected ? FontWeight.w600 : FontWeight.w400,
                    color: i == selected ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Coloured placeholder "photo" for recipes that don't have real images yet.
class FoodArt extends StatelessWidget {
  final String seed;
  final double height;
  final double radius;
  final double iconSize;
  final Widget? badge;

  const FoodArt({
    super.key,
    required this.seed,
    this.height = 180,
    this.radius = 16,
    this.iconSize = 56,
    this.badge,
  });

  static const _palettes = [
    [AppColors.peach, AppColors.accent],
    [AppColors.butter, Color(0xFF8A5A00)],
    [AppColors.lilac, AppColors.lilacInk],
    [AppColors.mint, AppColors.greenInk],
  ];
  static const _icons = [
    Icons.ramen_dining_outlined,
    Icons.rice_bowl_outlined,
    Icons.bakery_dining_outlined,
    Icons.lunch_dining_outlined,
    Icons.soup_kitchen_outlined,
    Icons.egg_alt_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final h = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    final p = _palettes[h % _palettes.length];
    return Container(
      height: height,
      decoration: BoxDecoration(color: p[0], borderRadius: BorderRadius.circular(radius)),
      child: Stack(
        children: [
          Center(child: Icon(_icons[h % _icons.length], color: p[1], size: iconSize)),
          if (badge != null) Positioned(top: 12, left: 12, child: badge!),
        ],
      ),
    );
  }
}

/// Section header: eyebrow + big light title + optional trailing widget.
class SectionHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, this.eyebrow, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 8)],
            Text(title, style: AppTheme.display(size: wide ? 40 : 26, weight: FontWeight.w400)),
          ],
        ),
        ?trailing,
      ],
    );
  }
}

/// Big light page title used at the top of inner pages.
class PageTitle extends StatelessWidget {
  final String text;
  final String? eyebrow;
  const PageTitle(this.text, {super.key, this.eyebrow});

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 10)],
        Text(
          text,
          style: AppTheme.display(size: wide ? 56 : 36, weight: FontWeight.w300, height: 1.05),
        ),
      ],
    );
  }
}

void showSoon(BuildContext context, String what) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$what is coming soon')));
}

// ─────────────────────────────────────────────────────────────────────────────
// GlowCard: soft glow at rest, brighter glow on hover, and an orange bar that
// fills along the bottom when tapped, before moving to the next page.
// ─────────────────────────────────────────────────────────────────────────────

class GlowCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final Color color;
  final Color? borderColor;
  final Color glow;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  const GlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.radius = 24,
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.glow = AppColors.accentBright,
    this.padding = EdgeInsets.zero,
    this.semanticLabel,
  });

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard> with SingleTickerProviderStateMixin {
  late final AnimationController _bar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  bool _hovered = false;
  bool _pressed = false;
  bool _busy = false;

  @override
  void dispose() {
    _bar.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    final onTap = widget.onTap;
    if (onTap == null || _busy) return;
    if (reduceMotion(context)) {
      onTap();
      return;
    }
    _busy = true;
    await _bar.forward(from: 0);
    if (!mounted) return;
    onTap();
    // Quietly reset once the next page has slid in over us.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _bar.value = 0;
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    final lit = _hovered && tappable;
    final scale = _pressed ? 0.98 : (lit ? 1.015 : 1.0);
    final r = BorderRadius.circular(widget.radius);

    return Semantics(
      button: tappable,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: tappable ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: tappable ? () => setState(() => _pressed = false) : null,
          onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
          onTap: tappable ? _handleTap : null,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: r,
                border: widget.borderColor == null
                    ? null
                    : Border.all(
                        color: lit ? widget.glow.withValues(alpha: 0.45) : widget.borderColor!,
                      ),
                boxShadow: [
                  // The coloured glow around the card.
                  BoxShadow(
                    color: widget.glow.withValues(alpha: lit ? 0.26 : 0.10),
                    blurRadius: lit ? 40 : 28,
                    spreadRadius: lit ? 2 : 0,
                    offset: Offset(0, lit ? 14 : 10),
                  ),
                  // A soft neutral shadow so it still reads as "floating".
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: r,
                child: Stack(
                  children: [
                    Padding(padding: widget.padding, child: widget.child),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 4,
                      child: AnimatedBuilder(
                        animation: _bar,
                        builder: (context, _) => _bar.value == 0
                            ? const SizedBox.shrink()
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: Curves.easeOutCubic.transform(_bar.value),
                                  heightFactor: 1,
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.accentBright, AppColors.accent],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

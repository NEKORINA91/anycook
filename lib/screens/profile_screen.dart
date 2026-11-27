import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/screens/change_password_screen.dart';
import 'package:anycook/screens/login_screen.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/recipe_card.dart';
import 'package:anycook/widgets/ui.dart';

/// Profile + settings in one page: rank progress, rank ladder, your recipes,
/// measurement units, hide-unmakeable toggle, bio/location, password, log out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _bioController = TextEditingController(text: appState.bio);
    _locationController = TextEditingController(text: appState.location);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    context.read<AppState>().updateProfile(
          bio: _bioController.text,
          location: _locationController.text,
        );
  }

  void _toLogin({bool logOut = false}) {
    if (logOut) context.read<AppState>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final wide = isWide(context);

    final score = s.chefScore;
    final rank = chefRankFromScore(score);
    final floor = currentRankThreshold(score);
    final next = nextRankThreshold(score);
    final progress = rank == ChefRank.headChef ? 1.0 : ((score - floor) / (next - floor)).clamp(0.0, 1.0).toDouble();
    final nextRank = switch (rank) {
      ChefRank.tasteTester => ChefRank.homeCook,
      ChefRank.homeCook => ChefRank.sousChef,
      ChefRank.sousChef => ChefRank.headChef,
      ChefRank.headChef => null,
    };

    // ── Hero ───────────────────────────────────────────────────────────────
    final hero = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: GlowBackground(
        base: const Color(0xFFFBF5EE),
        child: Padding(
          padding: EdgeInsets.all(wide ? 32 : 22),
          child: SplitLayout(
            align: CrossAxisAlignment.center,
            breakpoint: 760,
            gap: 28,
            first: Row(
              children: [
                Avatar(name: s.username, size: wide ? 96 : 72, dark: true),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.display(size: wide ? 44 : 32, weight: FontWeight.w300)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Tag(label: s.isLoggedIn ? rank.displayName : 'Guest', bg: AppColors.ink, ink: Colors.white, fontSize: 13),
                          if (s.location.isNotEmpty)
                            Tag(label: s.location, bg: AppColors.surface, ink: AppColors.ink, fontSize: 13),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            second: s.isLoggedIn
                ? SectionCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nextRank == null ? '$score points' : '$score / $next points',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              nextRank == null ? 'Top rank reached' : 'Next: ${nextRank.displayName}',
                              style: const TextStyle(fontSize: 13, color: AppColors.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: AppColors.stone,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Earn 50 points for every recipe you share.',
                            style: TextStyle(fontSize: 13, color: AppColors.muted)),
                      ],
                    ),
                  )
                : SectionCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Sign in to save your kitchen, share recipes and earn chef ranks.',
                            style: TextStyle(fontSize: 14, height: 1.5)),
                        const SizedBox(height: 14),
                        FilledButton(onPressed: _toLogin, child: const Text('Sign in')),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );

    // ── Rank ladder ──────────────────────────────────────────────────────────
    String pointsFor(ChefRank r) => switch (r) {
          ChefRank.tasteTester => '0 points',
          ChefRank.homeCook => '100 points',
          ChefRank.sousChef => '500 points',
          ChefRank.headChef => '2,000 points',
        };
    final ladder = AutoGrid(
      minItemWidth: wide ? 200 : 150,
      gap: 12,
      children: [
        for (final r in ChefRank.values)
          _RankTile(
            name: r.displayName,
            points: s.isLoggedIn && r == rank ? '${pointsFor(r)} · you are here' : pointsFor(r),
            current: s.isLoggedIn && r == rank,
            done: s.isLoggedIn && r.index < rank.index,
          ),
      ],
    );

    // ── My recipes ───────────────────────────────────────────────────────────
    final myRecipes = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('My recipes', style: AppTheme.display(size: 28))),
            TextButton(onPressed: () => goToTab(context, NavTab.upload), child: const Text('+ Upload')),
          ],
        ),
        const SizedBox(height: 16),
        AutoGrid(
          minItemWidth: wide ? 220 : 160,
          gap: 16,
          children: [
            for (final r in s.userRecipes) RecipeCard(recipe: r, imageHeight: 140),
            Pressable(
              onTap: () => goToTab(context, NavTab.upload),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD6CEC5), width: 1.5),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.accent, size: 30),
                    SizedBox(height: 8),
                    Text('Share your next recipe',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );

    // ── Settings ─────────────────────────────────────────────────────────────
    Widget row(String label, {Widget? trailing, VoidCallback? onTap, Color color = AppColors.ink}) => InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: color))),
                trailing ?? Icon(Icons.chevron_right_rounded, color: color == AppColors.ink ? AppColors.muted : color),
              ],
            ),
          ),
        );

    final settings = SectionCard(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row(
              'Measurements',
              trailing: SegmentedPill(
                options: const ['Metric', 'Imperial'],
                selected: s.measurementUnit == MeasurementUnit.metric ? 0 : 1,
                onChanged: (i) => s.setMeasurementUnit(i == 0 ? MeasurementUnit.metric : MeasurementUnit.imperial),
              ),
            ),
            const Divider(),
            row(
              "Hide recipes I can't make",
              trailing: Switch(value: s.hideUnmakeableRecipes, onChanged: s.setHideUnmakeableRecipes),
            ),
            const Divider(),
            row('My kitchen and pantry', onTap: () => goToTab(context, NavTab.kitchen)),
            if (s.isLoggedIn) ...[
              const Divider(),
              const SizedBox(height: 14),
              TextField(
                controller: _bioController,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) => _saveProfile(),
                decoration: const InputDecoration(labelText: 'Bio', hintText: 'Night-shift cook, microwave wizard'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                onChanged: (_) => _saveProfile(),
                decoration: const InputDecoration(labelText: 'Location (optional)'),
              ),
              const SizedBox(height: 6),
              row('Change password', onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  )),
              const Divider(),
              row('Log out', color: AppColors.redInk, onTap: () => _toLogin(logOut: true)),
            ] else ...[
              const Divider(),
              row('Sign in', color: AppColors.accent, onTap: _toLogin),
            ],
          ],
        ),
      ),
    );

    return AppShell(
      current: NavTab.profile,
      body: PageWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggerIn(context, [
            SizedBox(height: wide ? 16 : 4),
            hero,
            const SizedBox(height: 24),
            ladder,
            SizedBox(height: wide ? 40 : 28),
            SplitLayout(firstFlex: 2, secondFlex: 1, gap: 28, first: myRecipes, second: settings),
          ]),
        ),
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  final String name;
  final String points;
  final bool current;
  final bool done;

  const _RankTile({required this.name, required this.points, required this.current, required this.done});

  @override
  Widget build(BuildContext context) {
    final fg = current ? Colors.white : AppColors.ink;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: current ? AppColors.accent : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: current ? AppColors.accent : AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(points, style: TextStyle(fontSize: 12, color: current ? Colors.white : AppColors.muted)),
              ),
              if (done) const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.greenInk),
            ],
          ),
          const SizedBox(height: 6),
          Text(name, style: AppTheme.display(size: 22, color: fg)),
        ],
      ),
    );
  }
}

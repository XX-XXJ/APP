import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/stats/stats_screen.dart';
import 'ui/screens/achievements/achievements_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'providers/settings_provider.dart';
import 'core/theme/app_colors.dart';

class CheckInApp extends ConsumerStatefulWidget {
  const CheckInApp({super.key});

  @override
  ConsumerState<CheckInApp> createState() => _CheckInAppState();
}

class _CheckInAppState extends ConsumerState<CheckInApp> {
  int _currentIndex = 0;
  bool _showSplash = true;

  final _screens = const [
    HomeScreen(),
    StatsScreen(),
    AchievementsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final settings = ref.watch(settingsProvider);
    AppColors.setDarkMode(settings.darkMode);

    return MaterialApp(
      title: '打卡记录',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('zh', 'CN'),
      home: _showSplash
          ? SplashScreen(
              onComplete: () => setState(() => _showSplash = false),
            )
          : settings.hasCompletedOnboarding
              ? _buildMainApp()
              : OnboardingScreen(
                  onComplete: () => setState(() {}),
                ),
    );
  }

  Widget _buildMainApp() {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                    0, Icons.home_rounded, Icons.home_outlined, '首页'),
                _buildNavItem(1, Icons.bar_chart_rounded,
                    Icons.bar_chart_outlined, '统计'),
                _buildNavItem(2, Icons.emoji_events_rounded,
                    Icons.emoji_events_outlined, '成就'),
                _buildNavItem(3, Icons.settings_rounded,
                    Icons.settings_outlined, '设置'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

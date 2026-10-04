import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<_NavBarItemData> _items = [
    _NavBarItemData(
      label: 'Anasayfa',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_outlined,
    ),
    _NavBarItemData(
      label: 'Keşfet',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_outlined,
    ),
    _NavBarItemData(
      label: 'Çalış',
      icon: Icons.play_circle_outline_rounded,
      selectedIcon: Icons.play_circle_outline_rounded,
    ),
    _NavBarItemData(
      label: 'İlerleme',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_outlined,
    ),
    _NavBarItemData(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final bool isTablet = mediaQuery.size.shortestSide >= 600;

    // Tablet ve büyük ekranlarda oransal kompakt bar genişliği;
    // Telefonda ise yatay çevrildiğinde (landscape) gereksiz genişlemeyip portre modundaki kompakt boyutunu korur.
    final double barWidth;

    if (isTablet) {
      if (screenWidth >= 900) {
        // Büyük tablet / Desktop / Web: Ekranın ~%36'sı kadar kompakt pill
        barWidth = (screenWidth * 0.36).clamp(420.0, 520.0);
      } else {
        // Orta boy tablet / Foldable: Ekranın ~%56'sı kadar kompakt pill
        barWidth = (screenWidth * 0.56).clamp(380.0, 480.0);
      }
    } else if (isLandscape) {
      // Telefon yan çevrildiğinde: Ekranın tamamına yayılmasını ve aralara boşluk açılmasını engeller,
      // portre genişliğini (~320-380dp) koruyarak kompakt kalır.
      barWidth = (mediaQuery.size.shortestSide - 32.0).clamp(280.0, 380.0);
    } else {
      // Standart telefon dikey (Portrait) ekranı: Kenarlardan 16dp marjin ile yüzen bar
      barWidth = (screenWidth - 32.0).clamp(280.0, 440.0);
    }

    final double barHeight = (isLandscape && !isTablet) ? 58.0 : 66.0;
    final double bottomPadding = (isLandscape && !isTablet) ? 8.0 : 12.0;

    // Glassmorphism zemin renkleri
    final List<Color> gradientColors = isDark
        ? [
            const Color(0xFF262033).withValues(alpha: 0.78),
            const Color(0xFF14121A).withValues(alpha: 0.72),
          ]
        : [
            Colors.white.withValues(alpha: 0.82),
            Colors.white.withValues(alpha: 0.65),
          ];

    // İnce cam yansıma çizgisi (Specular border)
    final Color glassBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.75);

    // Aktif & Pasif tonlar
    final Color activeColor = isDark
        ? AppColors.primaryPolishLight
        : AppColors.primaryPolish;

    final Color inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.70);

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: bottomPadding),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: barWidth,
            height: barHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradientColors,
                    ),
                    border: Border.all(
                      color: glassBorderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      // Derin ambiyans gölgesi
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
                        blurRadius: 28,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                      // Yumuşak renkli hafif ışıma (Glow)
                      BoxShadow(
                        color: activeColor.withValues(alpha: isDark ? 0.10 : 0.05),
                        blurRadius: 18,
                        spreadRadius: -2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = index == currentIndex;

                      return Expanded(
                        child: _NavBarItem(
                          item: item,
                          isSelected: isSelected,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          isTablet: isTablet,
                          isLandscape: isLandscape,
                          onTap: () => onTabSelected(index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavBarItemData item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final bool isTablet;
  final bool isLandscape;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.isTablet,
    required this.isLandscape,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: (isLandscape && !isTablet) ? 2 : 4,
            horizontal: 2,
          ),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: (isLandscape && !isTablet) ? 21 : 23,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isTablet ? 11.5 : ((isLandscape && !isTablet) ? 10.0 : 10.5),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: isSelected ? 0.1 : 0,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItemData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavBarItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

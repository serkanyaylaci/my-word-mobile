import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

/// 1. Sürükle ve Bırak (Draggable & Pan Gesture)
/// 2. Kenara Yapışma (Edge Snapping / Magnetic Docking):
///    - Yatay (X): Ekran orta çizgisine göre sol yarıdaysa sol kenara, sağ yarıdaysa sağ kenara yaylanarak (CurvedAnimation) yapışır.
///    - Dikey (Y): Kullanıcının bıraktığı yükseklik kesinlikle korunur; sadece yatayda en yakın duvara yaslanır.
/// 3. Güvenli Alan Sınırları:
///    - Üst: Telefonun şarj / durum çubuğunun (Status Bar) 16 px altında kalır.
///    - Alt: Alt navigasyon barının (AppBottomNavBar) hemen 10 px üstüne kadar inebilir.
/// 4. Hız ve Fırlatma İvmesi: Sağa fırlatılırsa sağ duvara, sola fırlatılırsa sol duvara uçar.
/// * Herhangi bir sayfa açmaz, işlevsizdir.
class FloatingDraggableButton extends StatefulWidget {
  const FloatingDraggableButton({super.key});

  @override
  State<FloatingDraggableButton> createState() => _FloatingDraggableButtonState();
}

class _FloatingDraggableButtonState extends State<FloatingDraggableButton>
    with SingleTickerProviderStateMixin {
  Offset? _position;
  static const double _buttonSize = 56.0;
  static const double _edgeMargin = 16.0;
  static const double _gapAboveNavBar = 10.0;

  bool _isDragging = false;

  late final AnimationController _snapController;
  Animation<Offset>? _snapAnimation;

  double _safeClamp(double value, double min, double max) {
    if (min > max) return min;
    return value.clamp(min, max);
  }

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapController.addListener(() {
      if (_snapAnimation != null) {
        setState(() {
          _position = _snapAnimation!.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    if (size.width <= 0 || size.height <= 0) return;

    if (_position == null) {
      final mediaQuery = MediaQuery.of(context);
      final bounds = _getBounds(size, mediaQuery.padding);

      // Başlangıç: Sağ alt kenar, tam nav barın hemen 10 px üstü
      _position = Offset(bounds.rightDockX, bounds.bottomDockY);
    }
  }

  // Ekran Çerçevesi İçindeki Kesin Sınırlar
  ({
    double leftDockX,
    double rightDockX,
    double topDockY,
    double bottomDockY,
  }) _getBounds(Size size, EdgeInsets padding) {
    final screenW = math.max(size.width, 120.0);
    final screenH = math.max(size.height, 240.0);

    // Yatay sınırlar: Ekran çerçevesi içinde 16 px margin
    final leftDockX = _edgeMargin;
    final rightDockX = math.max(leftDockX, screenW - _buttonSize - _edgeMargin);

    // Dikey üst sınır: Durum çubuğu (Status Bar / Şarj / Saat) altına 16 px pay
    final topDockY = padding.top + _edgeMargin;

    // Dikey alt sınır: AppBottomNavBar'ın HEMEN ÜSTÜ (10 px pay)
    final double navBarTopY;
    if (padding.bottom >= 70.0) {
      navBarTopY = screenH - padding.bottom;
    } else {
      navBarTopY = screenH - math.max(padding.bottom, 12.0) - 66.0;
    }

    final bottomDockY = math.max(
      topDockY,
      navBarTopY - _buttonSize - _gapAboveNavBar,
    );

    return (
      leftDockX: leftDockX,
      rightDockX: rightDockX,
      topDockY: topDockY,
      bottomDockY: bottomDockY,
    );
  }

  void _animateToPosition(Offset targetPosition, {Curve curve = Curves.easeOutBack}) {
    if (_position == null) return;
    if ((_position! - targetPosition).distance < 1.0) return;

    if (_snapController.isAnimating) {
      _snapController.stop();
    }

    _snapAnimation = Tween<Offset>(
      begin: _position!,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: curve,
    ));

    _snapController.forward(from: 0.0);
  }

  // 2. Kenara Yapışma (Edge Snapping / Magnetic Docking)
  void _handlePanEnd(Size size, EdgeInsets padding, Velocity velocity) {
    if (_position == null) return;

    final bounds = _getBounds(size, padding);
    final curX = _safeClamp(_position!.dx, bounds.leftDockX, bounds.rightDockX);
    final curY = _safeClamp(_position!.dy, bounds.topDockY, bounds.bottomDockY);

    final vx = velocity.pixelsPerSecond.dx;

    // Yatay Eksen (X):
    // Kullanıcı hızlı savurduysa ivme yönündeki kenara uçar.
    // Değilse ekranın orta çizgisine bakılır:
    // Pencerenin merkezi sol yarıdaysa sol kenara, sağ yarıdaysa sağ kenara mıknatıs gibi yapışır.
    double targetX;
    if (vx.abs() > 280) {
      targetX = vx > 0 ? bounds.rightDockX : bounds.leftDockX;
    } else {
      final centerX = curX + (_buttonSize / 2);
      if (centerX < size.width / 2) {
        targetX = bounds.leftDockX;
      } else {
        targetX = bounds.rightDockX;
      }
    }

    // Dikey Eksen (Y):
    // Kullanıcının bıraktığı yükseklik KORUNUR; sadece yatayda en yakın duvara yaslanır.
    // Güvenli alan sınırları (şarj kısmı ve nav bar üstü) dahilinde tutulur.
    final targetY = _safeClamp(curY, bounds.topDockY, bounds.bottomDockY);

    HapticFeedback.selectionClick();
    _animateToPosition(Offset(targetX, targetY), curve: Curves.easeOutBack);
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    if (size.width <= 0 || size.height <= 0) return const SizedBox.shrink();

    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bounds = _getBounds(size, mediaQuery.padding);

    final currentX = _safeClamp(_position!.dx, bounds.leftDockX, bounds.rightDockX);
    final currentY = _safeClamp(_position!.dy, bounds.topDockY, bounds.bottomDockY);

    return Positioned(
      left: currentX,
      top: currentY,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Sayfa açmaz (işlevsizdir)
          HapticFeedback.selectionClick();
        },
        onPanStart: (_) {
          if (_snapController.isAnimating) {
            _snapController.stop();
          }
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          final newX = _safeClamp(_position!.dx + details.delta.dx, bounds.leftDockX, bounds.rightDockX);
          final newY = _safeClamp(_position!.dy + details.delta.dy, bounds.topDockY, bounds.bottomDockY);

          setState(() {
            _position = Offset(newX, newY);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
          _handlePanEnd(size, mediaQuery.padding, details.velocity);
        },
        onPanCancel: () {
          setState(() {
            _isDragging = false;
          });
          _handlePanEnd(size, mediaQuery.padding, Velocity.zero);
        },
        child: AnimatedScale(
          scale: _isDragging ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            width: _buttonSize,
            height: _buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.primaryPolishLight,
                        AppColors.primaryPolish,
                      ]
                    : [
                        AppColors.primaryPolish,
                        const Color(0xFF7C3AED),
                      ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.45),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
                  blurRadius: _isDragging ? 20 : 12,
                  spreadRadius: _isDragging ? 3 : 1,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.primaryPolish.withValues(alpha: isDark ? 0.30 : 0.35),
                  blurRadius: 16,
                  spreadRadius: -2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

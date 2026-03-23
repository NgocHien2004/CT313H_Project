import 'package:flutter/material.dart';

class Responsive {
  final BuildContext _context;
  Responsive(this._context);

  double get screenWidth => MediaQuery.of(_context).size.width;
  double get screenHeight => MediaQuery.of(_context).size.height;
  bool get isLandscape =>
      MediaQuery.of(_context).orientation == Orientation.landscape;
  bool get isPortrait => !isLandscape;
  bool get isPhone => screenWidth < 600;
  bool get isTablet => screenWidth >= 600;

  double sp(double size) {
    final base = isTablet ? 768.0 : 375.0;
    return size * (screenWidth / base).clamp(0.8, 1.4);
  }

  double get horizontalPadding => isTablet ? 24.0 : 16.0;
  double get verticalPadding => isTablet ? 20.0 : 12.0;
  double get itemSpacing => isTablet ? 12.0 : 8.0;

  int get dishGridColumns {
    if (isTablet && isLandscape) return 4;
    if (isTablet) return 3;
    if (isLandscape) return 3;
    return 2;
  }

  double get dishCardHeight {
    if (isTablet && isLandscape) return 260.0;
    if (isTablet) return 280.0;
    if (isLandscape) return 240.0;
    return 290.0;
  }

  int get statsGridColumns {
    if (isTablet) return 4;
    if (isLandscape) return 4;
    return 2;
  }

  double get iconSize => isTablet ? 22.0 : 18.0;
  double get borderRadius => isTablet ? 10.0 : 8.0;
  double get formMaxWidth => isTablet ? 600.0 : double.infinity;
  double get appBarHeight => isTablet ? 64.0 : 56.0;

  double get bottomSheetHeight {
    if (isTablet) return screenHeight * 0.85;
    if (isLandscape) return screenHeight * 0.97;
    return screenHeight * 0.92;
  }

  BoxConstraints get dialogConstraints => isTablet
      ? BoxConstraints(maxWidth: 560, maxHeight: screenHeight * 0.9)
      : const BoxConstraints();
}

extension ResponsiveExtension on BuildContext {
  Responsive get r => Responsive(this);
}

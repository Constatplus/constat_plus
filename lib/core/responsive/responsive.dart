import 'package:flutter/material.dart';

/// Centralise toute la logique responsive de l'application Constat+.
///
/// Utilisation :
///
/// ```dart
/// if (Responsive.isMobile(context)) {
///   // Interface mobile
/// }
///
/// final padding = Responsive.pagePadding(context);
/// final columns = Responsive.gridColumns(context);
/// ```
class Responsive {
  Responsive._();

  // ---------------------------------------------------------------------------
  // Breakpoints
  // ---------------------------------------------------------------------------

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  // ---------------------------------------------------------------------------
  // Animations
  // ---------------------------------------------------------------------------

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 400);

  // ---------------------------------------------------------------------------
  // Dimensions de l'écran
  // ---------------------------------------------------------------------------

  static Size screenSize(BuildContext context) {
    return MediaQuery.sizeOf(context);
  }

  static double width(BuildContext context) {
    return screenSize(context).width;
  }

  static double height(BuildContext context) {
    return screenSize(context).height;
  }

  static Orientation orientation(BuildContext context) {
    return MediaQuery.orientationOf(context);
  }

  static bool isPortrait(BuildContext context) {
    return orientation(context) == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return orientation(context) == Orientation.landscape;
  }

  // ---------------------------------------------------------------------------
  // Types d'écran
  // ---------------------------------------------------------------------------

  static bool isMobile(BuildContext context) {
    return width(context) < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final screenWidth = width(context);
    return screenWidth >= mobileBreakpoint &&
        screenWidth < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return width(context) >= tabletBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return width(context) >= largeDesktopBreakpoint;
  }

  static DeviceType deviceType(BuildContext context) {
    if (isMobile(context)) {
      return DeviceType.mobile;
    }

    if (isTablet(context)) {
      return DeviceType.tablet;
    }

    return DeviceType.desktop;
  }

  // ---------------------------------------------------------------------------
  // Valeur adaptative générique
  // ---------------------------------------------------------------------------

  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }

    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }

    if (isTablet(context)) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  // ---------------------------------------------------------------------------
  // Espacements
  // ---------------------------------------------------------------------------

  static double spacingXs(BuildContext context) {
    return value(
      context: context,
      mobile: 4,
      tablet: 6,
      desktop: 8,
    );
  }

  static double spacingSm(BuildContext context) {
    return value(
      context: context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );
  }

  static double spacingMd(BuildContext context) {
    return value(
      context: context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );
  }

  static double spacingLg(BuildContext context) {
    return value(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );
  }

  static double spacingXl(BuildContext context) {
    return value(
      context: context,
      mobile: 24,
      tablet: 32,
      desktop: 48,
    );
  }

  static double spacingXxl(BuildContext context) {
    return value(
      context: context,
      mobile: 32,
      tablet: 48,
      desktop: 64,
    );
  }

  // ---------------------------------------------------------------------------
  // Marges et padding
  // ---------------------------------------------------------------------------

  static double horizontalPadding(BuildContext context) {
    return value(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
      largeDesktop: 48,
    );
  }

  static double verticalPadding(BuildContext context) {
    return value(
      context: context,
      mobile: 16,
      tablet: 24,
      desktop: 32,
      largeDesktop: 40,
    );
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
      vertical: verticalPadding(context),
    );
  }

  static EdgeInsets horizontalPagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding(context),
    );
  }

  static EdgeInsets sectionPadding(BuildContext context) {
    return EdgeInsets.all(
      value(
        context: context,
        mobile: 16,
        tablet: 20,
        desktop: 24,
      ),
    );
  }

  static EdgeInsets cardPadding(BuildContext context) {
    return EdgeInsets.all(
      value(
        context: context,
        mobile: 14,
        tablet: 18,
        desktop: 22,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Largeurs maximales
  // ---------------------------------------------------------------------------

  static double maxContentWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 920,
      desktop: 1200,
      largeDesktop: 1320,
    );
  }

  static double maxFormWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 720,
      desktop: 820,
    );
  }

  static double maxDialogWidth(BuildContext context) {
    return value(
      context: context,
      mobile: width(context) - 32,
      tablet: 560,
      desktop: 640,
    );
  }

  static double sideMenuWidth(BuildContext context) {
    return value(
      context: context,
      mobile: 0,
      tablet: 220,
      desktop: 260,
      largeDesktop: 280,
    );
  }

  // ---------------------------------------------------------------------------
  // Typographie
  // ---------------------------------------------------------------------------

  static double displaySize(BuildContext context) {
    return value(
      context: context,
      mobile: 28,
      tablet: 34,
      desktop: 40,
      largeDesktop: 44,
    );
  }

  static double titleSize(BuildContext context) {
    return value(
      context: context,
      mobile: 22,
      tablet: 26,
      desktop: 30,
      largeDesktop: 32,
    );
  }

  static double subtitleSize(BuildContext context) {
    return value(
      context: context,
      mobile: 17,
      tablet: 19,
      desktop: 21,
    );
  }

  static double bodySize(BuildContext context) {
    return value(
      context: context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );
  }

  static double smallTextSize(BuildContext context) {
    return value(
      context: context,
      mobile: 12,
      tablet: 13,
      desktop: 14,
    );
  }

  static double buttonTextSize(BuildContext context) {
    return value(
      context: context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );
  }

  // ---------------------------------------------------------------------------
  // Icônes
  // ---------------------------------------------------------------------------

  static double iconSize(BuildContext context) {
    return value(
      context: context,
      mobile: 22,
      tablet: 24,
      desktop: 26,
    );
  }

  static double largeIconSize(BuildContext context) {
    return value(
      context: context,
      mobile: 32,
      tablet: 40,
      desktop: 48,
    );
  }

  static double heroIconSize(BuildContext context) {
    return value(
      context: context,
      mobile: 56,
      tablet: 72,
      desktop: 88,
    );
  }

  // ---------------------------------------------------------------------------
  // Boutons
  // ---------------------------------------------------------------------------

  static double buttonHeight(BuildContext context) {
    return value(
      context: context,
      mobile: 50,
      tablet: 52,
      desktop: 54,
    );
  }

  static double compactButtonHeight(BuildContext context) {
    return value(
      context: context,
      mobile: 42,
      tablet: 44,
      desktop: 46,
    );
  }

  static double buttonWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 280,
      desktop: 320,
    );
  }

  static Size minimumTouchTarget(BuildContext context) {
    final size = value(
      context: context,
      mobile: 48.0,
      tablet: 48.0,
      desktop: 44.0,
    );

    return Size(size, size);
  }

  // ---------------------------------------------------------------------------
  // Cartes et rayons
  // ---------------------------------------------------------------------------

  static double cardRadius(BuildContext context) {
    return value(
      context: context,
      mobile: 14,
      tablet: 16,
      desktop: 18,
    );
  }

  static double dialogRadius(BuildContext context) {
    return value(
      context: context,
      mobile: 18,
      tablet: 20,
      desktop: 24,
    );
  }

  static double buttonRadius(BuildContext context) {
    return value(
      context: context,
      mobile: 12,
      tablet: 12,
      desktop: 14,
    );
  }

  // ---------------------------------------------------------------------------
  // Grilles
  // ---------------------------------------------------------------------------

  static int gridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int largeDesktop = 4,
  }) {
    return value(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  static double gridSpacing(BuildContext context) {
    return value(
      context: context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );
  }

  static double gridChildAspectRatio(BuildContext context) {
    return value(
      context: context,
      mobile: 1.45,
      tablet: 1.35,
      desktop: 1.30,
    );
  }

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

  static double heroImageHeight(BuildContext context) {
    final screenHeight = height(context);

    return value(
      context: context,
      mobile: (screenHeight * 0.26).clamp(180.0, 260.0),
      tablet: (screenHeight * 0.34).clamp(240.0, 360.0),
      desktop: (screenHeight * 0.48).clamp(320.0, 520.0),
    );
  }

  static double thumbnailSize(BuildContext context) {
    return value(
      context: context,
      mobile: 72,
      tablet: 88,
      desktop: 104,
    );
  }

  // ---------------------------------------------------------------------------
  // Contraintes pratiques
  // ---------------------------------------------------------------------------

  static BoxConstraints contentConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: maxContentWidth(context),
    );
  }

  static BoxConstraints formConstraints(BuildContext context) {
    return BoxConstraints(
      maxWidth: maxFormWidth(context),
    );
  }

  static SliverGridDelegate responsiveGridDelegate(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    int largeDesktopColumns = 4,
    double? childAspectRatio,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: gridColumns(
        context,
        mobile: mobileColumns,
        tablet: tabletColumns,
        desktop: desktopColumns,
        largeDesktop: largeDesktopColumns,
      ),
      crossAxisSpacing: gridSpacing(context),
      mainAxisSpacing: gridSpacing(context),
      childAspectRatio:
          childAspectRatio ?? gridChildAspectRatio(context),
    );
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extensions pratiques pour alléger le code des écrans.
///
/// Exemple :
///
/// ```dart
/// if (context.isMobile) {}
/// final padding = context.pagePadding;
/// ```
extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);

  bool get isTablet => Responsive.isTablet(this);

  bool get isDesktop => Responsive.isDesktop(this);

  bool get isLargeDesktop => Responsive.isLargeDesktop(this);

  DeviceType get deviceType => Responsive.deviceType(this);

  double get screenWidth => Responsive.width(this);

  double get screenHeight => Responsive.height(this);

  EdgeInsets get pagePadding => Responsive.pagePadding(this);

  double get responsiveTitleSize => Responsive.titleSize(this);

  double get responsiveBodySize => Responsive.bodySize(this);

  double get responsiveIconSize => Responsive.iconSize(this);
}

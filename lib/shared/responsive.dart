import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Common responsive sizes for consistency
  static double get smallText => 12.sp;
  static double get mediumText => 16.sp;
  static double get largeText => 20.sp;
  static double get titleText => 24.sp;
  static double get headerText => 32.sp;

  static double get smallPadding => 8.w;
  static double get mediumPadding => 16.w;
  static double get largePadding => 24.w;

  static double get smallRadius => 8.r;
  static double get mediumRadius => 12.r;
  static double get largeRadius => 20.r;

  static double get buttonHeight => 50.h;
  static double get smallButtonHeight => 40.h;

  static double get iconSmall => 18.sp;
  static double get iconMedium => 24.sp;
  static double get iconLarge => 32.sp;

  // Responsive spacing
  static SizedBox verticalSmall = SizedBox(height: 8.h);
  static SizedBox verticalMedium = SizedBox(height: 16.h);
  static SizedBox verticalLarge = SizedBox(height: 24.h);
  static SizedBox verticalXLarge = SizedBox(height: 32.h);

  static SizedBox horizontalSmall = SizedBox(width: 8.w);
  static SizedBox horizontalMedium = SizedBox(width: 16.w);
  static SizedBox horizontalLarge = SizedBox(width: 24.w);

  // Screen size checks
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 900;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
}

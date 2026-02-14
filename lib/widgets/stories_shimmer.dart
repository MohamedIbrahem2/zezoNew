import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class ImageShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ImageShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
      ),
    );
  }
}
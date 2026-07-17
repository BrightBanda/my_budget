import 'package:flutter/material.dart';

/// Sweeps a light highlight across its child's opaque pixels — the classic loading
/// shimmer. Wrap a group of [SkeletonBox]es in one so they all animate together.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF1B1E4A),
                Color(0xFF34397F),
                Color(0xFF1B1E4A),
              ],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradient(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Slides the gradient from off-screen left to off-screen right as [t] goes 0 -> 1.
class _SlidingGradient extends GradientTransform {
  final double t;

  const _SlidingGradient(this.t);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues((t * 2 - 1) * bounds.width, 0, 0);
  }
}

/// A single opaque placeholder block. The [Shimmer] above paints the moving
/// highlight over it.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E4A),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

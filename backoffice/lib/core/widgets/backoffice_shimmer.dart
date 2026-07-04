import 'package:flutter/material.dart';

/// Lightweight shimmer without external deps.
/// Good enough for loading placeholders in BackOffice screens.
class BackofficeShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const BackofficeShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<BackofficeShimmer> createState() => _BackofficeShimmerState();
}

class _BackofficeShimmerState extends State<BackofficeShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0, 0),
                end: Alignment(1.0, 0),
                colors: [
                  const Color(0xFFEAEAEA),
                  const Color(0xFFF6F6F6),
                  const Color(0xFFEAEAEA),
                ],
                stops: const [0.2, 0.5, 0.8],
                transform: _SlidingGradientTransform(slide: _c.value),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slide;
  const _SlidingGradientTransform({required this.slide});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    // Move gradient from left to right.
    return Matrix4.translationValues(bounds.width * (slide - 0.5), 0, 0);
  }
}

/// Common placeholder for list/card rows.
class BackofficeShimmerRow extends StatelessWidget {
  final bool dense;
  const BackofficeShimmerRow({super.key, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final h = dense ? 12.0 : 14.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          BackofficeShimmer(
              width: 40, height: 40, borderRadius: BorderRadius.circular(10)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackofficeShimmer(
                    width: double.infinity,
                    height: h,
                    borderRadius: BorderRadius.circular(999)),
                const SizedBox(height: 8),
                BackofficeShimmer(
                    width: double.infinity,
                    height: h,
                    borderRadius: BorderRadius.circular(999)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          BackofficeShimmer(
              width: 36, height: 36, borderRadius: BorderRadius.circular(10)),
        ],
      ),
    );
  }
}

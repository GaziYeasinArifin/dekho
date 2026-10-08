import 'dart:math';
import 'package:flutter/material.dart';
import '../data/india_districts.dart';
import '../theme.dart';

/// Interactive district map for one state. Districts are drawn in the
/// state's own 0..1000 space. Tap a district to toggle visited.
/// Tiny districts get a nearest-centroid fallback so they stay tappable.
class DistrictMap extends StatefulWidget {
  final List<DistrictShape> districts;
  final Set<int> visited; // LGD codes
  final ValueChanged<int>? onToggle;
  final bool interactive;
  final DekhoMapTheme? theme;

  const DistrictMap({
    super.key,
    required this.districts,
    required this.visited,
    this.onToggle,
    this.interactive = true,
    this.theme,
  });

  DekhoMapTheme get effectiveTheme => theme ?? dekhoMapThemes[0];

  @override
  State<DistrictMap> createState() => _DistrictMapState();
}

class _DistrictMapState extends State<DistrictMap> {
  int? _hover;

  Map<int, Path> get _paths {
    return {
      for (final d in widget.districts) d.lgd: _buildPath(d),
    };
  }

  static Path _buildPath(DistrictShape d) {
    final p = Path();
    for (final poly in d.polys) {
      for (var i = 0; i < poly.length; i++) {
        final pt = Offset(poly[i][0].toDouble(), poly[i][1].toDouble());
        if (i == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      p.close();
    }
    return p;
  }

  /// Centroid-ish anchor (bbox center of the largest ring) per district,
  /// used as a fallback hit target for tiny districts.
  Map<int, Offset> get _anchors {
    final out = <int, Offset>{};
    for (final d in widget.districts) {
      List<List<int>>? big;
      var bigArea = -1.0;
      for (final poly in d.polys) {
        final xs = [for (final q in poly) q[0]];
        final ys = [for (final q in poly) q[1]];
        final area = (xs.reduce(max) - xs.reduce(min)).toDouble() *
            (ys.reduce(max) - ys.reduce(min));
        if (area > bigArea) {
          bigArea = area;
          big = poly;
        }
      }
      if (big != null) {
        final xs = [for (final q in big) q[0]];
        final ys = [for (final q in big) q[1]];
        out[d.lgd] = Offset(
          (xs.reduce(min) + xs.reduce(max)) / 2,
          (ys.reduce(min) + ys.reduce(max)) / 2,
        );
      }
    }
    return out;
  }

  /// Map a local position to 1000-space coordinates.
  Offset _toMapSpace(Offset local, Size size) {
    final scale = min(size.width, size.height) / 1000;
    final dx = (size.width - 1000 * scale) / 2;
    final dy = (size.height - 1000 * scale) / 2;
    return Offset((local.dx - dx) / scale, (local.dy - dy) / scale);
  }

  int? _hitTest(Offset local, Size size) {
    final m = _toMapSpace(local, size);
    final paths = _paths;
    // exact hit first (iterate reversed so small on-top shapes win ties)
    for (final d in widget.districts.reversed) {
      if (paths[d.lgd]!.contains(m)) return d.lgd;
    }
    // fallback: nearest anchor within a generous radius, for tiny districts
    const tinyHit = 45.0;
    var bestLgd = -1;
    var bestDist = tinyHit;
    for (final e in _anchors.entries) {
      final dist = (e.value - m).distance;
      if (dist < bestDist) {
        bestDist = dist;
        bestLgd = e.key;
      }
    }
    return bestLgd == -1 ? null : bestLgd;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return MouseRegion(
          onHover: widget.interactive
              ? (e) {
                  final hit = _hitTest(e.localPosition, size);
                  if (hit != _hover) setState(() => _hover = hit);
                }
              : null,
          onExit: (_) => setState(() => _hover = null),
          cursor: widget.interactive
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          child: GestureDetector(
            onTapUp: widget.interactive
                ? (d) {
                    final hit = _hitTest(d.localPosition, size);
                    if (hit != null) widget.onToggle?.call(hit);
                  }
                : null,
            child: CustomPaint(
              size: size,
              painter: _DistrictMapPainter(
                districts: widget.districts,
                paths: _paths,
                visited: widget.visited,
                hover: _hover,
                theme: widget.effectiveTheme,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DistrictMapPainter extends CustomPainter {
  final List<DistrictShape> districts;
  final Map<int, Path> paths;
  final Set<int> visited;
  final int? hover;
  final DekhoMapTheme theme;

  _DistrictMapPainter({
    required this.districts,
    required this.paths,
    required this.visited,
    required this.hover,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = min(size.width, size.height) / 1000;
    final dx = (size.width - 1000 * scale) / 2;
    final dy = (size.height - 1000 * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final fillVisited = Paint()
      ..color = theme.visited
      ..style = PaintingStyle.fill;
    final fillIdle = Paint()
      ..color = theme.unvisited
      ..style = PaintingStyle.fill;
    final fillHover = Paint()
      ..color = theme.accent.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = DekhoColors.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 / scale;
    final strokeInk = Paint()
      ..color = DekhoColors.ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / scale;

    for (final d in districts) {
      if (visited.contains(d.lgd)) continue;
      canvas.drawPath(paths[d.lgd]!, fillIdle);
    }
    if (hover != null && paths.containsKey(hover)) {
      canvas.drawPath(paths[hover]!, fillHover);
    }
    for (final d in districts) {
      if (!visited.contains(d.lgd)) continue;
      canvas.drawPath(paths[d.lgd]!, fillVisited);
    }
    for (final d in districts) {
      canvas.drawPath(paths[d.lgd]!, stroke);
      canvas.drawPath(paths[d.lgd]!, strokeInk);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DistrictMapPainter old) =>
      old.visited != visited ||
      old.hover != hover ||
      old.districts != districts ||
      old.theme != theme;
}

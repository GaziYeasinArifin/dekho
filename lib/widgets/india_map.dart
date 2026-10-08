import 'dart:math';
import 'package:flutter/material.dart';
import '../data/india_map.dart';
import '../theme.dart';

/// Interactive India map. Tap a state to toggle visited.
/// Tiny states/UTs get an invisible generous hit-circle so they're tappable.
class IndiaMap extends StatefulWidget {
  final Set<String> visited;
  final ValueChanged<String>? onToggle;
  final bool interactive;

  const IndiaMap({
    super.key,
    required this.visited,
    this.onToggle,
    this.interactive = true,
  });

  @override
  State<IndiaMap> createState() => _IndiaMapState();
}

class _IndiaMapState extends State<IndiaMap> {
  String? _hover;

  static final Map<String, Path> _paths = {
    for (final s in indiaStates) s.name: _buildPath(s),
  };

  static Path _buildPath(StateShape s) {
    final p = Path();
    for (final poly in s.polys) {
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

  /// Map a local position to 1000-space coordinates.
  Offset _toMapSpace(Offset local, Size size) {
    final scale = min(size.width, size.height) / 1000;
    final dx = (size.width - 1000 * scale) / 2;
    final dy = (size.height - 1000 * scale) / 2;
    return Offset((local.dx - dx) / scale, (local.dy - dy) / scale);
  }

  String? _hitTest(Offset local, Size size) {
    final m = _toMapSpace(local, size);
    // generous hit radius in map units for tiny states
    const tinyHit = 34.0;
    for (final s in indiaStates.reversed) {
      final path = _paths[s.name]!;
      if (path.contains(m)) return s.name;
      final a = Offset(s.labelX.toDouble(), s.labelY.toDouble());
      if ((a - m).distance < tinyHit) {
        // only use anchor-hit if the state's drawn area is actually tiny
        final b = path.getBounds();
        if (b.width < 60 && b.height < 60) return s.name;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            Size(constraints.maxWidth, constraints.maxHeight);
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
              painter: _IndiaMapPainter(
                visited: widget.visited,
                hover: _hover,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IndiaMapPainter extends CustomPainter {
  final Set<String> visited;
  final String? hover;

  _IndiaMapPainter({required this.visited, this.hover});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = min(size.width, size.height) / 1000;
    final dx = (size.width - 1000 * scale) / 2;
    final dy = (size.height - 1000 * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final fillVisited = Paint()
      ..color = DekhoColors.marigold
      ..style = PaintingStyle.fill;
    final fillIdle = Paint()
      ..color = DekhoColors.sand
      ..style = PaintingStyle.fill;
    final fillHover = Paint()
      ..color = DekhoColors.teal.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = DekhoColors.paper
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 / scale;
    final strokeInk = Paint()
      ..color = DekhoColors.ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / scale;

    // pass 1: idle states
    for (final s in indiaStates) {
      if (visited.contains(s.name)) continue;
      final p = _IndiaMapState._paths[s.name]!;
      canvas.drawPath(p, fillIdle);
    }
    // hover highlight
    if (hover != null) {
      final p = _IndiaMapState._paths[hover]!;
      canvas.drawPath(p, fillHover);
    }
    // pass 2: visited states on top
    for (final s in indiaStates) {
      if (!visited.contains(s.name)) continue;
      final p = _IndiaMapState._paths[s.name]!;
      canvas.drawPath(p, fillVisited);
    }
    // pass 3: borders
    for (final s in indiaStates) {
      canvas.drawPath(_IndiaMapState._paths[s.name]!, stroke);
      canvas.drawPath(_IndiaMapState._paths[s.name]!, strokeInk);
    }
    // pass 4: dot markers for tiny states so they're visible
    final dotPaint = Paint()..color = DekhoColors.inkSoft;
    final dotVisited = Paint()..color = DekhoColors.marigoldDeep;
    for (final s in indiaStates) {
      final b = _IndiaMapState._paths[s.name]!.getBounds();
      if (b.width < 14 && b.height < 14) {
        canvas.drawCircle(
          Offset(s.labelX.toDouble(), s.labelY.toDouble()),
          7 / scale * 2.2,
          visited.contains(s.name) ? dotVisited : dotPaint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IndiaMapPainter old) =>
      old.visited != visited || old.hover != hover;
}

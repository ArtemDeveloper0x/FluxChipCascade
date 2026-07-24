import 'dart:ui';
import 'package:flame/components.dart';
import '../flux_game.dart';

/// Tiles the current location's background art across the visible world,
/// following the camera. Uses a square center-crop of the wide source image
/// so the pattern repeats cleanly in both directions.
class BackgroundLayer extends PositionComponent with HasGameReference<FluxGame> {
  BackgroundLayer() : super(priority: -10, position: Vector2.zero());

  static const double tileSize = 720;
  static const Rect cropRect = Rect.fromLTWH(456, 0, 672, 672);

  @override
  void render(Canvas canvas) {
    final img = game.sprites.bgImage(game.level.bgIndex);
    final visible = game.camera.visibleWorldRect;
    final startX = (visible.left / tileSize).floor() * tileSize;
    final startY = (visible.top / tileSize).floor() * tileSize;
    final paint = Paint()..filterQuality = FilterQuality.medium;
    for (double y = startY; y < visible.bottom + tileSize; y += tileSize) {
      for (double x = startX; x < visible.right + tileSize; x += tileSize) {
        canvas.drawImageRect(
          img,
          cropRect,
          Rect.fromLTWH(x, y, tileSize, tileSize),
          paint,
        );
      }
    }
    final vignette = Paint()
      ..shader = Gradient.radial(
        visible.center,
        visible.longestSide * 0.55,
        [
          const Color(0x00000000),
          const Color(0xFF03040B).withValues(alpha: 0.75),
        ],
      );
    canvas.drawRect(visible, vignette);
  }
}

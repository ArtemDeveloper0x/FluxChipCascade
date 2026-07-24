import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';

/// A "floating" joystick that appears right where the player puts their
/// thumb down, instead of being pinned to a fixed corner of the screen.
/// This feels much more natural on a phone since the player never has to
/// stretch their thumb back to a fixed spot.
class FloatingJoystick extends PositionComponent
    with DragCallbacks {
  FloatingJoystick({this.maxRadius = 62, this.knobRadius = 26, this.deadZone = 0.08});

  final double maxRadius;
  final double knobRadius;
  final double deadZone;

  /// Normalized (-1..1 per axis) direction the player wants to move in.
  Vector2 relativeDelta = Vector2.zero();

  Vector2? _center;
  Vector2? _knob;
  double _fade = 0;

  bool get isActive => _center != null;

  final Paint _bgPaint = Paint()..color = const Color(0x2A2C3B77);
  final Paint _ringPaint = Paint()
    ..color = const Color(0x663DE8FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4;
  final Paint _knobPaint = Paint()..color = const Color(0xAA3DE8FF);
  final Paint _knobGlow = Paint()
    ..color = const Color(0x553DE8FF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _fade += (isActive ? 1 : -1) * dt * 6;
    _fade = _fade.clamp(0, 1);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _center = event.localPosition.clone();
    _knob = event.localPosition.clone();
    relativeDelta = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_center == null) return;
    final target = _knob! + event.localDelta;
    final offset = target - _center!;
    final dist = offset.length;
    _knob = dist > maxRadius ? _center! + offset.normalized() * maxRadius : target;
    final norm = (_knob! - _center!) / maxRadius;
    relativeDelta = norm.length < deadZone ? Vector2.zero() : norm;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _reset();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _reset();
  }

  void _reset() {
    _center = null;
    _knob = null;
    relativeDelta = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_fade <= 0.01 || _center == null || _knob == null) return;
    final alpha = _fade;
    canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
    final c = _center!.toOffset();
    final k = _knob!.toOffset();
    canvas.drawCircle(c, maxRadius, _bgPaint);
    canvas.drawCircle(c, maxRadius, _ringPaint);
    canvas.drawCircle(k, knobRadius + 6, _knobGlow);
    canvas.drawCircle(k, knobRadius, _knobPaint);
    canvas.restore();
  }
}

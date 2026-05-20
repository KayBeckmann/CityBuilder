import 'package:city_builder/core/overlay_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:city_builder/game/sprite_registry.dart';
import 'package:city_builder/game/tile_map_component.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CityGame extends FlameGame
    with ScrollDetector, ScaleDetector, DragCallbacks, TapCallbacks {
  CityGame({void Function(WorldPosition pos)? onTileTap})
      : _onTileTap = onTileTap;

  void Function(WorldPosition pos)? _onTileTap;

  /// Override tap callback after construction (set by GameScreen).
  set onTileTapOverride(void Function(WorldPosition pos)? fn) {
    _onTileTap = fn;
  }

  TileMapComponent? _tileMapComponent;

  static const double _minZoom = 0.25;
  static const double _maxZoom = 4.0;
  double _startZoom = 1.0;

  // Drag-detection: if moved more than threshold → pan, not tap
  Vector2? _tapDownPosition;
  static const double _tapThreshold = 8.0;

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    SpriteRegistry.I.schedulePreload();

    if (kDebugMode) {
      camera.viewport.add(
        FpsTextComponent(
          position: Vector2(10, 10),
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      );
    }
  }

  void updateOverlay(OverlayType overlay, Map<WorldPosition, double> values) {
    _tileMapComponent?.updateOverlay(overlay, values);
  }

  void loadMap(TileMap tileMap) {
    _tileMapComponent?.removeFromParent();
    final component = TileMapComponent(tileMap: tileMap);
    _tileMapComponent = component;
    world.add(component);

    camera.viewfinder.zoom = 1.0;
    camera.viewfinder.position = Vector2(
      tileMap.width * 32 / 2,
      tileMap.height * 32 / 2,
    );
  }

  // ── Scroll / Scale ────────────────────────────────────────────────────────

  @override
  void onScroll(PointerScrollInfo info) {
    final zoom = camera.viewfinder.zoom;
    final delta = info.scrollDelta.global.y * -0.001 * zoom;
    camera.viewfinder.zoom = (zoom + delta).clamp(_minZoom, _maxZoom);
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final newZoom = (_startZoom * info.scale.global.y).clamp(_minZoom, _maxZoom);
    camera.viewfinder.zoom = newZoom;
  }

  // ── Drag (pan) ────────────────────────────────────────────────────────────

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _tapDownPosition = event.localPosition.clone();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    camera.viewfinder.position -= event.localDelta / camera.viewfinder.zoom;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _tapDownPosition = null;
  }

  // ── Tap (place tool) ─────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    _tapDownPosition = event.localPosition.clone();
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_onTileTap == null) return;
    final down = _tapDownPosition;
    if (down != null) {
      final delta = (event.localPosition - down).length;
      if (delta > _tapThreshold) return; // was a drag
    }
    final worldPos = camera.viewfinder.parentToLocal(event.localPosition);
    final tilePos = screenToWorld(worldPos);
    if (_tileMapComponent != null && tileMap.contains(tilePos)) {
      _onTileTap!(tilePos);
    }
  }

  TileMap get tileMap => _tileMapComponent!.tileMap;
}

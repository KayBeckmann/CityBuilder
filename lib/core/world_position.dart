import 'package:flame/components.dart';

const double kTileSize = 32.0;

typedef WorldPosition = ({int col, int row});

extension WorldPositionExt on WorldPosition {
  Vector2 toScreen() => Vector2(col * kTileSize, row * kTileSize);

  bool isValid(int mapWidth, int mapHeight) =>
      col >= 0 && row >= 0 && col < mapWidth && row < mapHeight;
}

WorldPosition screenToWorld(Vector2 screen) => (
      col: (screen.x / kTileSize).floor(),
      row: (screen.y / kTileSize).floor(),
    );

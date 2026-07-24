import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import '../core/constants.dart';
import 'data/enemy_data.dart';

/// Precomputed source rects for every sprite sheet shipped in `assets/`.
/// All sheets share the canvas size 1584x672 unless noted otherwise.
class SheetGrid {
  static List<Rect> grid({
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
    double startX = 0,
    double startY = 0,
  }) {
    final rects = <Rect>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        rects.add(Rect.fromLTWH(
          startX + c * cellW,
          startY + r * cellH,
          cellW,
          cellH,
        ));
      }
    }
    return rects;
  }
}

Sprite _spriteFrom(Image img, Rect r) => Sprite(
      img,
      srcPosition: r.topLeft.toVector2(),
      srcSize: r.size.toVector2(),
    );

/// Loads all sheets into Flame's [Images] cache and exposes ready-to-draw
/// [Sprite] helpers for every game entity.
class GameSprites {
  GameSprites(this.images);

  final Images images;

  late Image enemiesImg;
  late Image miniBossesImg;
  late Image mainSpheresImg;
  late Image neutralSpheresImg;
  late Image crystalsImg;
  late Image upgradesImg;
  late Image destructionImg;
  late Image eventEffectsImg;
  late Image orbitEffectsImg;
  late Image movementTracesImg;
  late Image decorativeImg;
  final Map<int, Image> _bgImages = {};

  static const List<Rect> mainSphereRects = [
    Rect.fromLTWH(58, 64, 215, 218),
    Rect.fromLTWH(367, 63, 218, 221),
    Rect.fromLTWH(677, 62, 224, 223),
    Rect.fromLTWH(992, 62, 223, 224),
    Rect.fromLTWH(1302, 61, 224, 227),
    Rect.fromLTWH(49, 371, 229, 223),
    Rect.fromLTWH(363, 372, 224, 223),
    Rect.fromLTWH(681, 376, 214, 217),
    Rect.fromLTWH(989, 371, 229, 222),
    Rect.fromLTWH(1306, 373, 216, 219),
  ];

  static final List<Rect> neutralSphereRects =
      SheetGrid.grid(cols: 7, rows: 3, cellW: 226, cellH: 204);

  static final List<Rect> crystalRects =
      SheetGrid.grid(cols: 9, rows: 3, cellW: 176, cellH: 224);

  static final List<Rect> upgradeIconRects =
      SheetGrid.grid(cols: 4, rows: 2, cellW: 396, cellH: 336);

  static final List<Rect> destructionRects =
      SheetGrid.grid(cols: 8, rows: 4, cellW: 198, cellH: 168);

  static final List<Rect> eventEffectRects =
      SheetGrid.grid(cols: 6, rows: 3, cellW: 264, cellH: 224);

  static final List<Rect> orbitEffectRects =
      SheetGrid.grid(cols: 6, rows: 3, cellW: 264, cellH: 224);

  static final List<Rect> decorativeRects =
      SheetGrid.grid(cols: 6, rows: 3, cellW: 264, cellH: 224);

  /// Enemy grid: 10 columns (visual tier / recolor) x 3 rows (silhouette).
  static Rect enemyRect(int row, int col) =>
      Rect.fromLTWH(col * 158.4, row * 224.0, 158.4, 224.0);

  Future<void> preload() async {
    images.prefix = 'assets/';
    enemiesImg = await images.load('enemyes_asset.webp');
    miniBossesImg = await images.load('mini_bosses_asset.webp');
    mainSpheresImg = await images.load('main_spheres_asset.webp');
    neutralSpheresImg = await images.load('Neutral_energy_spheres_asset.webp');
    crystalsImg = await images.load('Energy_Crystals_Currency_asset.webp');
    upgradesImg = await images.load('Special_Orbit_Upgrades_asset.webp');
    destructionImg = await images.load('Effects_of_destruction_asset.webp');
    eventEffectsImg = await images.load('Effects_of_random_events_asset.webp');
    orbitEffectsImg = await images.load('Energy_effects_of_the_orbit_asset.webp');
    movementTracesImg = await images.load('Traces_of_movement_asset.webp');
    decorativeImg = await images.load('decorative_elements_effects_asset.webp');
    for (int i = 0; i < 10; i++) {
      final path = Assets.bgLocation(i).replaceFirst('assets/', '');
      _bgImages[i] = await images.load(path);
    }
  }

  Image bgImage(int tier) => _bgImages[tier.clamp(0, 9)]!;

  Sprite mainSphere(int index) =>
      _spriteFrom(mainSpheresImg, mainSphereRects[index % mainSphereRects.length]);

  Sprite neutralSphere(int index) => _spriteFrom(
      neutralSpheresImg, neutralSphereRects[index % neutralSphereRects.length]);

  Sprite crystal(int index) =>
      _spriteFrom(crystalsImg, crystalRects[index % crystalRects.length]);

  Sprite upgradeIcon(int index) =>
      _spriteFrom(upgradesImg, upgradeIconRects[index % upgradeIconRects.length]);

  Sprite destructionFx(int index) =>
      _spriteFrom(destructionImg, destructionRects[index % destructionRects.length]);

  Sprite eventEffect(int column, {int row = 0}) => _spriteFrom(eventEffectsImg,
      eventEffectRects[(row * 6 + column) % eventEffectRects.length]);

  Sprite orbitEffect(int index) =>
      _spriteFrom(orbitEffectsImg, orbitEffectRects[index % orbitEffectRects.length]);

  Sprite decorative(int index) =>
      _spriteFrom(decorativeImg, decorativeRects[index % decorativeRects.length]);

  Sprite enemySprite(EnemyType type, int tier) {
    final row = kEnemyDefs[type]!.spriteRow;
    return _spriteFrom(enemiesImg, enemyRect(row, tier.clamp(0, 9)));
  }

  Sprite miniBoss(MiniBossType type) =>
      _spriteFrom(miniBossesImg, kMiniBossDefs[type]!.srcRect);
}

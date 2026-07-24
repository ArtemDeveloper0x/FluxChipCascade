import 'package:flutter_test/flutter_test.dart';
import 'package:flux_chip_cascade/game/data/level_data.dart';

void main() {
  test('exactly 40 levels are generated, easy to hard', () {
    expect(kLevels.length, 40);
    expect(kLevels.first.level, 1);
    expect(kLevels.last.level, 40);

    // Difficulty must never decrease as levels progress.
    for (int i = 1; i < kLevels.length; i++) {
      expect(kLevels[i].enemyHpMult, greaterThanOrEqualTo(kLevels[i - 1].enemyHpMult));
      expect(kLevels[i].enemyDamageMult, greaterThanOrEqualTo(kLevels[i - 1].enemyDamageMult));
    }

    // Every 8th level should be a location finale (area boss fight).
    expect(kLevels[7].isLocationFinale, isTrue);
    expect(kLevels[39].isLocationFinale, isTrue);

    // Location + background tiers stay within their expected bounds.
    for (final level in kLevels) {
      expect(level.locationIndex, inInclusiveRange(0, 4));
      expect(level.bgIndex, inInclusiveRange(0, 9));
    }
  });

  test('levelConfigFor clamps to valid range', () {
    expect(levelConfigFor(1).level, 1);
    expect(levelConfigFor(40).level, 40);
    expect(levelConfigFor(999).level, 40);
    expect(levelConfigFor(-5).level, 1);
  });
}

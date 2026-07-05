import 'package:flutter/material.dart';

class ScholasticThemeExtension extends ThemeExtension<ScholasticThemeExtension> {
  final BoxShadow? cardShadow;
  final Color? abacusFrameBorderColor;
  final LinearGradient? welcomeGradient;

  const ScholasticThemeExtension({
    required this.cardShadow,
    required this.abacusFrameBorderColor,
    required this.welcomeGradient,
  });

  @override
  ScholasticThemeExtension copyWith({
    BoxShadow? cardShadow,
    Color? abacusFrameBorderColor,
    LinearGradient? welcomeGradient,
  }) {
    return ScholasticThemeExtension(
      cardShadow: cardShadow ?? this.cardShadow,
      abacusFrameBorderColor: abacusFrameBorderColor ?? this.abacusFrameBorderColor,
      welcomeGradient: welcomeGradient ?? this.welcomeGradient,
    );
  }

  @override
  ScholasticThemeExtension lerp(ThemeExtension<ScholasticThemeExtension>? other, double t) {
    if (other is! ScholasticThemeExtension) return this;
    return ScholasticThemeExtension(
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t),
      abacusFrameBorderColor: Color.lerp(abacusFrameBorderColor, other.abacusFrameBorderColor, t),
      welcomeGradient: LinearGradient.lerp(welcomeGradient, other.welcomeGradient, t),
    );
  }

  // Helper getters to simplify light theme overrides
  static ScholasticThemeExtension get light {
    return const ScholasticThemeExtension(
      cardShadow: BoxShadow(
        color: Color(0x0C262624),
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
      abacusFrameBorderColor: Color(0xFF8D5B4C),
      welcomeGradient: LinearGradient(
        colors: [Color(0xFFFAF2E6), Color(0xFFF3E7D3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  // Helper getters to simplify dark theme overrides
  static ScholasticThemeExtension get dark {
    return const ScholasticThemeExtension(
      cardShadow: BoxShadow(
        color: Color(0x33000000),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
      abacusFrameBorderColor: Color(0xFF4A342C),
      welcomeGradient: LinearGradient(
        colors: [Color(0xFF2C1E1A), Color(0xFF1D1512)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

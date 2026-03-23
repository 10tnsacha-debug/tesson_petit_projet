import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:provider/provider.dart';

class ProductTab2 extends StatelessWidget {
  const ProductTab2({super.key});

  static const double _horizontalPadding = 29.0;
  static const double _rightPadding = 27.0;
  static const double _rightColumnWidth = 102.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    final _NutritionDisplayItem? fatItem = _buildItem(
      label: 'Matières grasses / lipides',
      nutriment: product.nutritionFacts?.fat,
      level: product.nutrientLevels?.fat,
    );

    final _NutritionDisplayItem? saturatedFatItem = _buildItem(
      label: 'Acides gras saturés',
      nutriment: product.nutritionFacts?.saturatedFat,
      level: product.nutrientLevels?.saturatedFat,
    );

    final _NutritionDisplayItem? sugarItem = _buildItem(
      label: 'Sucres',
      nutriment: product.nutritionFacts?.sugar,
      level: product.nutrientLevels?.sugars,
    );

    final _NutritionDisplayItem? saltItem = _buildItem(
      label: 'Sel',
      nutriment: product.nutritionFacts?.salt,
      level: product.nutrientLevels?.salt,
    );

    final List<_NutritionDisplayItem> items = <_NutritionDisplayItem>[
      if (fatItem != null) fatItem,
      if (saturatedFatItem != null) saturatedFatItem,
      if (sugarItem != null) sugarItem,
      if (saltItem != null) saltItem,
    ];

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée nutritionnelle disponible',
          style: TextStyle(
            fontFamily: 'Avenir',
            fontSize: 15,
            color: Color(0xFF6A6A6A),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 18, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 23, right: 17),
            child: SizedBox(
              width: 335,
              child: Text(
                'Repères nutritionnels pour 100g',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6A6A6A),
                  height: 23 / 17,
                ),
              ),
            ),
          ),
          const SizedBox(height: 47),
          ...List<Widget>.generate(items.length, (int index) {
            final _NutritionDisplayItem item = items[index];

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: _horizontalPadding,
                    right: _rightPadding,
                  ),
                  child: _NutritionRow(
                    item: item,
                    rightColumnWidth: _rightColumnWidth,
                  ),
                ),
                if (index != items.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(
                      left: _horizontalPadding,
                      right: _rightPadding,
                      top: 14,
                      bottom: 18,
                    ),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE9E9F4),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  _NutritionDisplayItem? _buildItem({
    required String label,
    required Nutriment? nutriment,
    required String? level,
  }) {
    if (nutriment == null && (level == null || level.isEmpty)) {
      return null;
    }

    final String formattedValue = _formatPer100g(nutriment);
    final _NutritionLevelDisplay nutritionLevel = _mapLevel(level);

    return _NutritionDisplayItem(
      label: label,
      value: formattedValue,
      levelText: nutritionLevel.text,
      levelColor: nutritionLevel.color,
    );
  }

  String _formatPer100g(Nutriment? nutriment) {
    if (nutriment == null || nutriment.per100g == null) {
      return '-';
    }

    final dynamic value = nutriment.per100g;
    final String unit = nutriment.unit;

    if (value is int) {
      return '$value$unit';
    }

    if (value is double) {
      String text = value.toStringAsFixed(1).replaceAll('.', ',');
      if (text.endsWith(',0')) {
        text = text.substring(0, text.length - 2);
      }
      return '$text$unit';
    }

    return '$value$unit';
  }

  _NutritionLevelDisplay _mapLevel(String? rawLevel) {
    switch ((rawLevel ?? '').toLowerCase()) {
      case 'low':
        return const _NutritionLevelDisplay(
          text: 'Faible quantité',
          color: Color(0xFF639941),
        );
      case 'moderate':
        return const _NutritionLevelDisplay(
          text: 'Quantité modérée',
          color: Color(0xFF997B3F),
        );
      case 'high':
        return const _NutritionLevelDisplay(
          text: 'Quantité élevée',
          color: Color(0xFF99403F),
        );
      default:
        return const _NutritionLevelDisplay(
          text: '-',
          color: Color(0xFF6A6A6A),
        );
    }
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({required this.item, required this.rightColumnWidth});

  final _NutritionDisplayItem item;
  final double rightColumnWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 59.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF080040),
                  height: 20 / 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: rightColumnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: item.levelColor,
                    height: 20 / 15,
                  ),
                ),
                Text(
                  item.levelText,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: item.levelColor,
                    height: 20 / 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionDisplayItem {
  const _NutritionDisplayItem({
    required this.label,
    required this.value,
    required this.levelText,
    required this.levelColor,
  });

  final String label;
  final String value;
  final String levelText;
  final Color levelColor;
}

class _NutritionLevelDisplay {
  const _NutritionLevelDisplay({required this.text, required this.color});

  final String text;
  final Color color;
}

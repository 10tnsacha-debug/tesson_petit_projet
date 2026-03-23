import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:provider/provider.dart';

class ProductTab1 extends StatelessWidget {
  const ProductTab1({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    final List<_PropertyRowData> ingredientRows = product.ingredients == null
        ? <_PropertyRowData>[]
        : product.ingredients!
              .map(_PropertyRowData.fromIngredientText)
              .toList(growable: false);

    final List<String> allergenRows = product.allergens ?? <String>[];
    final List<String> additiveRows =
        product.additives?.keys.toList() ?? <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SectionBlock(
            title: 'Ingrédients',
            child: ingredientRows.isEmpty
                ? const _SingleValueRow(text: 'Aucune')
                : Column(
                    children: List<Widget>.generate(ingredientRows.length, (
                      int index,
                    ) {
                      final _PropertyRowData row = ingredientRows[index];
                      return _PropertyRow(
                        leftText: row.left,
                        rightText: row.right,
                        showDivider: index != ingredientRows.length - 1,
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 20),
          _SectionBlock(
            title: 'Substances allergènes',
            child: allergenRows.isEmpty
                ? const _SingleValueRow(text: 'Aucune')
                : Column(
                    children: List<Widget>.generate(allergenRows.length, (
                      int index,
                    ) {
                      return _SingleValueRow(
                        text: allergenRows[index],
                        showDivider: index != allergenRows.length - 1,
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 20),
          _SectionBlock(
            title: 'Additifs',
            child: additiveRows.isEmpty
                ? const _SingleValueRow(text: 'Aucune')
                : Column(
                    children: List<Widget>.generate(additiveRows.length, (
                      int index,
                    ) {
                      return _SingleValueRow(
                        text: additiveRows[index],
                        showDivider: index != additiveRows.length - 1,
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 40,
          color: const Color(0xFFF6F6F8),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Avenir',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF080040),
              height: 1.2,
            ),
          ),
        ),
        Container(width: double.infinity, color: Colors.white, child: child),
      ],
    );
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.leftText,
    required this.rightText,
    this.showDivider = true,
  });

  final String leftText;
  final String rightText;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(29, 14, 27, 14),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 110,
                child: Text(
                  leftText,
                  style: const TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF080040),
                    height: 1.33,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  rightText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A6A6A),
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
          if (showDivider)
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            ),
        ],
      ),
    );
  }
}

class _SingleValueRow extends StatelessWidget {
  const _SingleValueRow({required this.text, this.showDivider = false});

  final String text;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(29, 16, 27, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Avenir',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF080040),
              height: 1.33,
            ),
          ),
          if (showDivider)
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            ),
        ],
      ),
    );
  }
}

class _PropertyRowData {
  const _PropertyRowData({required this.left, required this.right});

  final String left;
  final String right;

  factory _PropertyRowData.fromIngredientText(String rawText) {
    final String text = rawText.trim();

    // Cas visuel attendu :
    // "Légumes (petits pois 41%, carottes 22%)"
    final RegExp parenthesisPattern = RegExp(r'^(.*?)\s*\((.*?)\)\s*$');
    final Match? match = parenthesisPattern.firstMatch(text);

    if (match != null) {
      return _PropertyRowData(
        left: match.group(1)?.trim() ?? text,
        right: match.group(2)?.trim() ?? '',
      );
    }

    // Cas du type "Garniture : salade, oignon grelot"
    final int colonIndex = text.indexOf(':');
    if (colonIndex != -1) {
      return _PropertyRowData(
        left: text.substring(0, colonIndex).trim(),
        right: text.substring(colonIndex + 1).trim(),
      );
    }

    return _PropertyRowData(left: text, right: '');
  }
}

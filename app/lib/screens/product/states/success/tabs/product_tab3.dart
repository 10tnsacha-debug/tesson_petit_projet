import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductTab3 extends StatelessWidget {
  const ProductTab3({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    if (product.nutritionFacts == null) {
      return const Center(
        child: Text(
          'Aucune donnée nutritionnelle disponible',
          style: TextStyle(fontSize: 15, color: Color(0xFF6A6A6A)),
        ),
      );
    }

    final NutritionFacts facts = product.nutritionFacts!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        color: Colors.white,
        child: Table(
          border: const TableBorder(
            horizontalInside: BorderSide(color: Color(0xFFF0F0F0), width: 1),
            verticalInside: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(2.8),
            1: FlexColumnWidth(1.6),
            2: FlexColumnWidth(1.5),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            _buildHeaderRow(),
            ..._buildRows(context, facts),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      children: <Widget>[
        _HeaderCell(text: ''),
        _HeaderCell(text: 'Pour 100g'),
        _HeaderCell(text: 'Par part'),
      ],
    );
  }

  List<TableRow> _buildRows(BuildContext context, NutritionFacts facts) {
    final NumberFormat numberFormat = NumberFormat.decimalPatternDigits(
      locale: Localizations.localeOf(context).toString(),
      decimalDigits: 1,
    );

    return <TableRow>[
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'Énergie',
        nutriment: facts.energy,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'Matières grasses',
        nutriment: facts.fat,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'dont Acides gras saturés',
        nutriment: facts.saturatedFat,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'Glucides',
        nutriment: facts.carbohydrate,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'dont Sucres',
        nutriment: facts.sugar,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'Fibres alimentaires',
        nutriment: facts.fiber,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'Protéines',
        nutriment: facts.proteins,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'Sel',
        nutriment: facts.salt,
      ),
      _buildDataRow(
        numberFormat: numberFormat,
        label: 'Sodium',
        nutriment: facts.sodium,
      ),
    ];
  }

  TableRow _buildDataRow({
    required NumberFormat numberFormat,
    required String label,
    required Nutriment? nutriment,
  }) {
    return TableRow(
      children: <Widget>[
        _LabelCell(text: label),
        _ValueCell(
          text: _formatField(numberFormat, nutriment?.per100g, nutriment?.unit),
        ),
        _ValueCell(
          text: _formatField(
            numberFormat,
            nutriment?.perServing,
            nutriment?.unit,
          ),
        ),
      ],
    );
  }

  String _formatField(NumberFormat numberFormat, dynamic value, String? unit) {
    if (value == null) {
      return '?';
    }

    final String safeUnit = unit ?? '';

    if (value is int) {
      return '$value $safeUnit'.trim();
    }

    if (value is double) {
      String text = numberFormat.format(value);
      if (text.endsWith(',0')) {
        text = text.substring(0, text.length - 2);
      }
      return '$text $safeUnit'.trim();
    }

    return '$value ${safeUnit.trim()}'.trim();
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 67,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF080040),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _LabelCell extends StatelessWidget {
  const _LabelCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Avenir',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF080040),
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF080040),
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

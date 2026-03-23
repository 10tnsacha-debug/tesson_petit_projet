import 'dart:math';

import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/model/product_recall.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/product_recall_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProductPageHeader extends StatelessWidget {
  const ProductPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: const <Widget>[ProductImageHeader(), ProductNameHeader()],
    );
  }
}

class ProductImageHeader extends StatelessWidget {
  const ProductImageHeader({super.key});

  static const double kImageHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _ProductHeaderDelegate(
        maxHeight: kImageHeight,
        minHeight: MediaQuery.viewPaddingOf(context).top,
      ),
    );
  }
}

class _ProductHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ProductHeaderDelegate({required this.maxHeight, required this.minHeight})
    : assert(maxHeight >= minHeight),
      assert(minHeight >= 0.0);

  final double maxHeight;
  final double minHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final Product product = context.read<Product>();
    final double progress = (shrinkOffset / (maxHeight - minHeight)).clamp(
      0.0,
      1.0,
    );

    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0.0,
          start: 0.0,
          end: 0.0,
          height: maxHeight - shrinkOffset,
          child: Image.network(
            product.picture ?? '',
            width: double.infinity,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.srcATop,
            errorBuilder: (_, __, ___) => Container(color: Colors.white),
          ),
        ),
        PositionedDirectional(
          top: max(maxHeight - shrinkOffset - 16.0, 0.0),
          start: 0.0,
          end: 0.0,
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadiusDirectional.vertical(
                top: Radius.circular(16.0 * (1 - progress)),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1 * (1.0 - progress)),
                  blurRadius: 10.0,
                  offset: const Offset(0.0, -2.0),
                ),
              ],
            ),
            child: const SizedBox(width: double.infinity, height: 16.0),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _ProductHeaderDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
}

class ProductNameHeader extends StatelessWidget {
  const ProductNameHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();
    final ProductFetcherSuccess success =
        context.read<ProductFetcher>().state as ProductFetcherSuccess;
    final ProductRecall? recall = success.recall;

    return SliverPinnedHeader(
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 20.0,
            end: 20.0,
            bottom: 10.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(product.name ?? '-', style: context.theme.title1),
              const SizedBox(height: 3.0),
              Text(
                product.brands?.join(', ') ?? '-',
                style: context.theme.title2,
              ),
              const SizedBox(height: 8.0),
              if (recall != null) _RecallBanner(recall: recall),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecallBanner extends StatelessWidget {
  const _RecallBanner({required this.recall});

  final ProductRecall recall;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 43.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProductRecallScreen(recallId: recall.id),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0x5CFF0000),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: const Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Ce produit fait l’objet d’un rappel produit",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFA60000),
                      fontFamily: 'Avenir',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward, color: Color(0xFFA60000), size: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

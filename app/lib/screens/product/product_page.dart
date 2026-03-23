import 'package:flutter/material.dart';
import 'package:formation_flutter/api/auth_api.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/states/empty/product_page_empty.dart';
import 'package:formation_flutter/screens/product/states/error/product_page_error.dart';
import 'package:formation_flutter/screens/product/states/success/product_page_body.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.barcode})
    : assert(barcode.length > 0);

  final String barcode;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool _isFavorite = false;
  String? _favoriteId;
  bool _isFavoriteLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    try {
      final result = await pb
          .collection('favorites')
          .getList(
            filter:
                'user = "${pb.authStore.model.id}" && barcode = "${widget.barcode}"',
          );

      if (!mounted) return;

      if (result.items.isNotEmpty) {
        setState(() {
          _isFavorite = true;
          _favoriteId = result.items.first.id;
        });
      }
    } catch (e) {
      debugPrint('Erreur vérification favori: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isFavoriteLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      if (_isFavorite && _favoriteId != null) {
        await pb.collection('favorites').delete(_favoriteId!);

        if (!mounted) return;
        setState(() {
          _isFavorite = false;
          _favoriteId = null;
        });
      } else {
        final Product product = await OpenFoodFactsAPI().getProduct(
          widget.barcode,
        );

        final String productName = product.name?.trim().isNotEmpty == true
            ? product.name!.trim()
            : 'Produit inconnu';

        final String brand =
            product.brands != null && product.brands!.isNotEmpty
            ? product.brands!.first
            : '';

        final String productImage = product.picture ?? '';
        final String nutriscore = _nutriScoreToLetter(product.nutriScore);

        final RecordModel record = await pb
            .collection('favorites')
            .create(
              body: <String, dynamic>{
                'user': pb.authStore.model.id,
                'barcode': widget.barcode,
                'product_name': productName,
                'product_image': productImage,
                'brand': brand,
                'nutriscore': nutriscore,
              },
            );

        if (!mounted) return;
        setState(() {
          _isFavorite = true;
          _favoriteId = record.id;
        });
      }
    } catch (e) {
      debugPrint('Erreur favoris: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de mettre à jour les favoris : $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isFavoriteLoading = false;
      });
    }
  }

  String _nutriScoreToLetter(ProductNutriScore? score) {
    switch (score) {
      case ProductNutriScore.A:
        return 'A';
      case ProductNutriScore.B:
        return 'B';
      case ProductNutriScore.C:
        return 'C';
      case ProductNutriScore.D:
        return 'D';
      case ProductNutriScore.E:
        return 'E';
      case ProductNutriScore.unknown:
      case null:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);

    return ChangeNotifierProvider<ProductFetcher>(
      create: (_) => ProductFetcher(barcode: widget.barcode),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Consumer<ProductFetcher>(
              builder: (BuildContext context, ProductFetcher notifier, _) {
                return switch (notifier.state) {
                  ProductFetcherLoading() => const ProductPageEmpty(),
                  ProductFetcherError(error: var err) => ProductPageError(
                    error: err,
                  ),
                  ProductFetcherSuccess() => ProductPageBody(),
                };
              },
            ),
            PositionedDirectional(
              top: 0.0,
              start: 0.0,
              child: _HeaderIcon(
                icon: Icons.arrow_back,
                tooltip: materialLocalizations.backButtonTooltip,
                onPressed: Navigator.of(context).pop,
              ),
            ),
            PositionedDirectional(
              top: 0.0,
              end: 0.0,
              child: _HeaderIcon(
                icon: _isFavorite ? Icons.star : Icons.star_border,
                tooltip: 'Favori',
                onPressed: _toggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.tooltip, this.onPressed})
    : assert(tooltip.length > 0);

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onPressed ?? () {},
              customBorder: const CircleBorder(),
              child: Ink(
                padding: const EdgeInsetsDirectional.all(12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.0),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: const Offset(0.0, 0.0),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

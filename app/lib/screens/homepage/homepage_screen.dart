import 'package:flutter/material.dart';
import 'package:formation_flutter/api/auth_api.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:formation_flutter/screens/homepage/scanner_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<RecordModel> _history = <RecordModel>[];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final result = await pb
          .collection('history')
          .getList(
            filter: 'user = "${pb.authStore.model.id}"',
            sort: '-consulted_at',
          );

      if (!mounted) return;

      setState(() {
        _history = result.items;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erreur chargement historique : $e';
      });
    }
  }

  Future<void> _onScanButtonPressed(BuildContext context) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final String? barcode = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(builder: (_) => const ScannerScreen()),
      );

      if (!mounted) return;

      if (barcode == null || barcode.isEmpty) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final Product product = await OpenFoodFactsAPI().getProduct(barcode);

      final String productName = product.name?.trim().isNotEmpty == true
          ? product.name!.trim()
          : 'Produit inconnu';

      final String brand = product.brands != null && product.brands!.isNotEmpty
          ? product.brands!.first
          : '';

      final String productImage = product.picture ?? '';

      final String nutriscore = _nutriScoreToLetter(product.nutriScore);

      await pb
          .collection('history')
          .create(
            body: <String, dynamic>{
              'user': pb.authStore.model.id,
              'barcode': barcode,
              'consulted_at': DateTime.now().toIso8601String(),
              'product_name': productName,
              'product_image': productImage,
              'brand': brand,
              'nutriscore': nutriscore,
            },
          );

      await _loadHistory();

      if (!mounted) return;
      context.push('/product', extra: barcode);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Une erreur est survenue : $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
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

  Color _nutriScoreColor(String nutriscore) {
    switch (nutriscore.toUpperCase()) {
      case 'A':
        return const Color(0xFF038141);
      case 'B':
        return const Color(0xFF85BB2F);
      case 'C':
        return const Color(0xFFF2C300);
      case 'D':
        return const Color(0xFFF08A00);
      case 'E':
        return const Color(0xFFE94E1B);
      default:
        return Colors.grey;
    }
  }

  void _onFavoritesPressed(BuildContext context) {
    context.push('/favorites');
  }

  void _onLogoutPressed(BuildContext context) {
    pb.authStore.clear();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(localizations.my_scans_screen_title),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            onPressed: _isLoading ? null : () => _onScanButtonPressed(context),
            icon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: const Icon(AppIcons.barcode, color: Color(0xFF080040)),
            ),
          ),
          IconButton(
            onPressed: () => _onFavoritesPressed(context),
            icon: const Icon(Icons.star, color: Color(0xFF080040)),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 15.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => _onLogoutPressed(context),
              child: Container(
                width: 23,
                height: 23,
                decoration: BoxDecoration(
                  color: const Color(0xFF080040),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          _history.isEmpty
              ? HomePageEmpty(
                  onScan: _isLoading
                      ? null
                      : () => _onScanButtonPressed(context),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: _history.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (BuildContext context, int index) {
                    final RecordModel item = _history[index];

                    final String barcode = (item.data['barcode'] ?? '')
                        .toString();
                    final String productName = (item.data['product_name'] ?? '')
                        .toString();
                    final String brand = (item.data['brand'] ?? '').toString();
                    final String nutriscore = (item.data['nutriscore'] ?? '')
                        .toString();
                    final String imageUrl = (item.data['product_image'] ?? '')
                        .toString();

                    return _HistoryCard(
                      productName: productName,
                      brand: brand,
                      nutriscore: nutriscore,
                      imageUrl: imageUrl,
                      nutriscoreColor: _nutriScoreColor(nutriscore),
                      onTap: () {
                        context.push('/product', extra: barcode);
                      },
                    );
                  },
                ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.productName,
    required this.brand,
    required this.nutriscore,
    required this.imageUrl,
    required this.nutriscoreColor,
    required this.onTap,
  });

  final String productName;
  final String brand;
  final String nutriscore;
  final String imageUrl;
  final Color nutriscoreColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 8,
            right: 0,
            top: 7,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.08),
                      blurRadius: 18,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 142, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        productName.isNotEmpty
                            ? productName
                            : 'Produit inconnu',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Avenir',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF080040),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Avenir',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6A6A6A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: nutriscoreColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              nutriscore.isNotEmpty
                                  ? 'Nutriscore : $nutriscore'
                                  : 'Nutriscore : -',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Avenir',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _HistoryImage(imageUrl: imageUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryImage extends StatelessWidget {
  const _HistoryImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 113,
        height: 113,
        color: const Color(0xFFEAEAEA),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      );
    }

    return Image.network(
      imageUrl,
      width: 113,
      height: 113,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          width: 113,
          height: 113,
          color: const Color(0xFFEAEAEA),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          width: 113,
          height: 113,
          color: const Color(0xFFEAEAEA),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}

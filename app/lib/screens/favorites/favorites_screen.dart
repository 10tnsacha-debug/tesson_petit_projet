import 'package:flutter/material.dart';
import 'package:formation_flutter/api/auth_api.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<RecordModel> _favorites = <RecordModel>[];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await pb
          .collection('favorites')
          .getList(
            filter: 'user = "${pb.authStore.model.id}"',
            sort: '-created',
          );

      final List<RecordModel> deduplicated = <RecordModel>[];
      final Set<String> seenBarcodes = <String>{};

      for (final RecordModel item in result.items) {
        final String barcode = (item.data['barcode'] ?? '').toString();
        if (barcode.isEmpty) continue;

        if (!seenBarcodes.contains(barcode)) {
          seenBarcodes.add(barcode);
          deduplicated.add(item);
        }
      }

      if (!mounted) return;
      setState(() {
        _favorites = deduplicated;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur chargement favoris : $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(title: const Text('Mes favoris')),
      body: Stack(
        children: <Widget>[
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_favorites.isEmpty)
            const Center(
              child: Text(
                'Vous n’avez pas encore de favoris.',
                textAlign: TextAlign.center,
              ),
            )
          else
            RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _favorites.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (BuildContext context, int index) {
                  final RecordModel item = _favorites[index];

                  final String barcode = (item.data['barcode'] ?? '')
                      .toString();
                  final String productName = (item.data['product_name'] ?? '')
                      .toString();
                  final String brand = (item.data['brand'] ?? '').toString();
                  final String nutriscore = (item.data['nutriscore'] ?? '')
                      .toString();
                  final String imageUrl = (item.data['product_image'] ?? '')
                      .toString();

                  return _FavoriteCard(
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
            ),
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

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
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
                child: _FavoriteImage(imageUrl: imageUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteImage extends StatelessWidget {
  const _FavoriteImage({required this.imageUrl});

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

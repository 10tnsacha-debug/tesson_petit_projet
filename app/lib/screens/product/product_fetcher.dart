import 'package:flutter/material.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/api/product_recall_pb_api.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/model/product_recall.dart';

class ProductFetcher extends ChangeNotifier {
  ProductFetcher({required String barcode})
    : _barcode = barcode,
      _state = ProductFetcherLoading() {
    loadProduct();
  }

  final String _barcode;
  final ProductRecallPbApi _productRecallPbApi = const ProductRecallPbApi();

  ProductFetcherState _state;

  Future<void> loadProduct() async {
    _state = ProductFetcherLoading();
    notifyListeners();

    try {
      final Product product = await OpenFoodFactsAPI().getProduct(_barcode);
      final ProductRecall? recall = await _productRecallPbApi
          .getActiveRecallByBarcode(_barcode);

      _state = ProductFetcherSuccess(product: product, recall: recall);
    } catch (error) {
      _state = ProductFetcherError(error);
    } finally {
      notifyListeners();
    }
  }

  ProductFetcherState get state => _state;
}

sealed class ProductFetcherState {}

class ProductFetcherLoading extends ProductFetcherState {}

class ProductFetcherSuccess extends ProductFetcherState {
  ProductFetcherSuccess({required this.product, required this.recall});

  final Product product;
  final ProductRecall? recall;
}

class ProductFetcherError extends ProductFetcherState {
  ProductFetcherError(this.error);

  final dynamic error;
}

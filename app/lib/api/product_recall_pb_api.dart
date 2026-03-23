import 'package:formation_flutter/api/auth_api.dart';
import 'package:formation_flutter/model/product_recall.dart';
import 'package:pocketbase/pocketbase.dart';

class ProductRecallPbApi {
  const ProductRecallPbApi();

  Future<ProductRecall?> getActiveRecallByBarcode(String barcode) async {
    try {
      final ResultList<RecordModel> result = await pb
          .collection('product_recalls')
          .getList(
            page: 1,
            perPage: 1,
            filter: 'barcode = "$barcode" && is_active = true',
            sort: '-recall_date,-created',
          );

      if (result.items.isEmpty) {
        return null;
      }

      return ProductRecall.fromJson(result.items.first.toJson());
    } catch (_) {
      return null;
    }
  }

  Future<ProductRecall?> getRecallById(String id) async {
    try {
      final RecordModel record = await pb
          .collection('product_recalls')
          .getOne(id);
      return ProductRecall.fromJson(record.toJson());
    } catch (_) {
      return null;
    }
  }
}

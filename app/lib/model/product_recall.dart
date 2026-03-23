class ProductRecall {
  final String id;
  final String barcode;
  final String? productName;
  final String? brand;
  final String? imageUrl;
  final String? recallTitle;
  final String? recallReason;
  final String? riskDescription;
  final String? geographicArea;
  final String? distributionChannels;
  final DateTime? recallDate;
  final DateTime? marketingStartDate;
  final DateTime? marketingEndDate;
  final String? sourceUrl;
  final bool isActive;
  final String? additionalInformation;
  final String? consumerGuidance;
  final String? pdfUrl;

  const ProductRecall({
    required this.id,
    required this.barcode,
    this.productName,
    this.brand,
    this.imageUrl,
    this.recallTitle,
    this.recallReason,
    this.riskDescription,
    this.geographicArea,
    this.distributionChannels,
    this.recallDate,
    this.marketingStartDate,
    this.marketingEndDate,
    this.sourceUrl,
    required this.isActive,
    this.additionalInformation,
    this.consumerGuidance,
    this.pdfUrl,
  });

  factory ProductRecall.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().isEmpty) {
        return null;
      }
      return DateTime.tryParse(value.toString());
    }

    return ProductRecall(
      id: json['id']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      productName: json['product_name']?.toString(),
      brand: json['brand']?.toString(),
      imageUrl: json['image_url']?.toString(),
      recallTitle: json['recall_title']?.toString(),
      recallReason: json['recall_reason']?.toString(),
      riskDescription: json['risk_description']?.toString(),
      geographicArea: json['geographic_area']?.toString(),
      distributionChannels: json['distribution_channels']?.toString(),
      recallDate: parseDate(json['recall_date']),
      marketingStartDate: parseDate(json['marketing_start_date']),
      marketingEndDate: parseDate(json['marketing_end_date']),
      sourceUrl: json['source_url']?.toString(),
      isActive:
          json['is_active'] == true || json['is_active']?.toString() == 'true',
      additionalInformation: json['additional_information']?.toString(),
      consumerGuidance: json['consumer_guidance']?.toString(),
      pdfUrl: json['pdf_url']?.toString(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:formation_flutter/api/product_recall_pb_api.dart';
import 'package:formation_flutter/model/product_recall.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductRecallScreen extends StatefulWidget {
  const ProductRecallScreen({super.key, required this.recallId});

  final String recallId;

  @override
  State<ProductRecallScreen> createState() => _ProductRecallScreenState();
}

class _ProductRecallScreenState extends State<ProductRecallScreen> {
  final ProductRecallPbApi _api = const ProductRecallPbApi();

  bool _isLoading = true;
  String? _errorMessage;
  ProductRecall? _recall;

  @override
  void initState() {
    super.initState();
    _loadRecall();
  }

  Future<void> _loadRecall() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ProductRecall? recall = await _api.getRecallById(widget.recallId);

      if (!mounted) return;

      if (recall == null) {
        setState(() {
          _errorMessage = 'Rappel introuvable.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _recall = recall;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur lors du chargement du rappel.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  String? _buildMarketingDates(ProductRecall recall) {
    if (recall.marketingStartDate == null && recall.marketingEndDate == null) {
      return null;
    }

    final String start = _formatDate(recall.marketingStartDate);
    final String end = _formatDate(recall.marketingEndDate);

    if (start.isNotEmpty && end.isNotEmpty) {
      return 'Du $start au $end';
    }
    if (start.isNotEmpty) {
      return 'À partir du $start';
    }
    if (end.isNotEmpty) {
      return 'Jusqu’au $end';
    }

    return null;
  }

  void _shareRecall(ProductRecall recall) {
    final String text = (recall.pdfUrl ?? recall.sourceUrl ?? '').trim();
    if (text.isEmpty) return;

    final RenderBox box = context.findRenderObject() as RenderBox;

    Share.share(
      text,
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _openPdf(ProductRecall recall) async {
    final String url = (recall.pdfUrl ?? '').trim();
    if (url.isEmpty) {
      return;
    }

    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final ProductRecall? recall = _recall;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(78.0),
        child: AppBar(
          toolbarHeight: 78.0,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: const Padding(
            padding: EdgeInsetsDirectional.only(start: 30.0),
            child: Text(
              'Rappel produit',
              style: TextStyle(
                fontFamily: 'Avenir',
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                color: Color(0xFF080040),
              ),
            ),
          ),
          actions: <Widget>[
            if (recall != null && (recall.pdfUrl ?? '').trim().isNotEmpty)
              IconButton(
                onPressed: () => _openPdf(recall),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                color: const Color(0xFF080040),
                iconSize: 26.0,
              ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 20.0),
              child: IconButton(
                onPressed: recall == null ? null : () => _shareRecall(recall),
                icon: const Icon(Icons.reply),
                color: const Color(0xFF080040),
                iconSize: 28.0,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            )
          : recall == null
          ? const Center(child: Text('Aucun rappel trouvé.'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 10.0),

                  if ((recall.imageUrl ?? '').trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 103.0,
                        end: 84.0,
                      ),
                      child: SizedBox(
                        width: 188.0,
                        height: 181.0,
                        child: Image.network(
                          recall.imageUrl!.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8.0),

                  _RecallSection(
                    title: 'Dates de commercialisation',
                    content: _buildMarketingDates(recall),
                    contentHeight: 58.0,
                  ),

                  _RecallSection(
                    title: 'Distributeurs',
                    content: recall.distributionChannels,
                    contentHeight: 92.0,
                  ),

                  _RecallSection(
                    title: 'Zone géographique',
                    content: recall.geographicArea,
                    contentHeight: 33.0,
                  ),

                  _RecallSection(
                    title: 'Motif du rappel',
                    content: recall.recallReason,
                    contentHeight: 112.0,
                  ),

                  _RecallSection(
                    title: 'Risques encourus',
                    content: recall.riskDescription,
                    contentHeight: 33.0,
                  ),

                  _RecallSection(
                    title: 'Informations complémentaires',
                    content: recall.additionalInformation,
                    contentHeight: 80.0,
                  ),

                  _RecallSection(
                    title: 'Conduite à tenir',
                    content: recall.consumerGuidance,
                    contentHeight: 80.0,
                  ),

                  const SizedBox(height: 24.0),
                ],
              ),
            ),
    );
  }
}

class _RecallSection extends StatelessWidget {
  const _RecallSection({
    required this.title,
    required this.content,
    required this.contentHeight,
  });

  final String title;
  final String? content;
  final double contentHeight;

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 40.0,
          color: const Color(0xFFF6F6F8),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF080040),
              fontFamily: 'Avenir',
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: contentHeight),
          color: Colors.white,
          padding: const EdgeInsetsDirectional.only(
            start: 20.0,
            end: 20.0,
            top: 15.0,
            bottom: 15.0,
          ),
          alignment: Alignment.center,
          child: Text(
            content!.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6A6A6A),
              fontFamily: 'Avenir',
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

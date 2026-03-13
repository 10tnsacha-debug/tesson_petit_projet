import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RappelPage extends StatelessWidget {
  const RappelPage({super.key, required this.payload});

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final String? photo = _asString(payload['photo']);
    final String? pdfUrl = _asString(payload['pdfUrl']);

    final String? dateDebut = _asString(payload['dateDebut']);
    final String? dateFin = _asString(payload['dateFin']);
    final String? distributeurs = _asString(payload['distributeurs']);
    final String? zone = _asString(payload['zone']);
    final String? motif = _asString(payload['motif']);
    final String? risques = _asString(payload['risques']);
    final String? infos = _asString(payload['infos']);
    final String? conduite = _asString(payload['conduite']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappel produit'),
        actions: [
          if (pdfUrl != null)
            IconButton(
              onPressed: () async {
                final uri = Uri.parse(pdfUrl);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Ouvrir la fiche PDF',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (photo != null)
            Center(child: Image.network(photo, height: 260, fit: BoxFit.cover)),
          _Section(
            title: 'Dates de commercialisation',
            content: (dateDebut != null && dateFin != null)
                ? 'Du $dateDebut au $dateFin'
                : null,
          ),
          _Section(title: 'Distributeurs', content: distributeurs),
          _Section(title: 'Zone géographique concernée', content: zone),
          _Section(title: 'Motif du rappel', content: motif),
          _Section(title: 'Risques encourus', content: risques),
          _Section(title: 'Informations complémentaires', content: infos),
          _Section(title: 'Conduite à tenir', content: conduite),
        ],
      ),
    );
  }

  String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.content});

  final String title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    if (content == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            content!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

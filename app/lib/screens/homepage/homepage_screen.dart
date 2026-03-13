import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pb = PocketBase('http://127.0.0.1:8090');

    pb.collection('rappels').getOne('htzvshvsa1s1puf').then((record) {
      final gtin = record.get<String>('gtin');
      print(gtin);
    });
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.my_scans_screen_title),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            onPressed: () => _onScanButtonPressed(context),
            icon: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(AppIcons.barcode),
            ),
          ),
        ],
      ),
      body: HomePageEmpty(onScan: () => _onScanButtonPressed(context)),
    );
  }

  void _onScanButtonPressed(BuildContext context) {
    context.push('/product', extra: '5000159484695');
  }
}

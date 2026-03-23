import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';

class HomePageEmpty extends StatelessWidget {
  const HomePageEmpty({super.key, this.onScan});

  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Spacer(flex: 20),
            SvgPicture.asset(AppVectorialImages.illEmpty, fit: BoxFit.contain),
            const Spacer(flex: 10),
            Expanded(
              flex: 20,
              child: Column(
                children: <Widget>[
                  Text(
                    localizations.my_scans_screen_description,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 5),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blue,
                        backgroundColor: AppColors.yellow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22.0)),
                        ),
                      ),
                      onPressed: onScan,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              localizations.my_scans_screen_button
                                  .toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          const Icon(Icons.arrow_forward_outlined),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 20),
          ],
        ),
      ),
    );
  }
}

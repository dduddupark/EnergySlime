import 'package:flutter/material.dart';
import 'app_localizations.dart';

String getLocalizedItemName(BuildContext context, String itemId) {
  final l10n = AppLocalizations.of(context)!;
  switch (itemId) {
    case 'hat_red': return l10n.hat_red;
    case 'hat_crown': return l10n.hat_crown;
    case 'hat_straw': return l10n.hat_straw;
    case 'hat_wizard': return l10n.hat_wizard;
    case 'hat_party': return l10n.hat_party;
    case 'face_glasses': return l10n.face_glasses;
    case 'face_mustache': return l10n.face_mustache;
    case 'face_blush': return l10n.face_blush;
    case 'face_mask': return l10n.face_mask;
    case 'bg_forest': return l10n.bg_forest;
    case 'bg_space': return l10n.bg_space;
    case 'bg_beach': return l10n.bg_beach;
    case 'bg_city': return l10n.bg_city;
    case 'bg_snow': return l10n.bg_snow;
    default: return itemId;
  }
}

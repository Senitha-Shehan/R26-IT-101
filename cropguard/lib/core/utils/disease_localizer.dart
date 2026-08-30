import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Maps ML model class names (unchanged) to localized display names.
/// The backend always receives the original English class identifier.
class DiseaseLocalizer {
  static final Map<String, String Function(AppLocalizations)> _map = {
    'Bacterial Leaf Blight': (l) => l.diseaseNameBacterialLeafBlight,
    'Brown Spot': (l) => l.diseaseNameBrownSpot,
    'Healthy Rice Leaf': (l) => l.diseaseNameHealthyRiceLeaf,
    'Leaf Blast': (l) => l.diseaseNameLeafBlast,
    'Leaf Scald': (l) => l.diseaseNameLeafScald,
    'Narrow Brown Leaf Spot': (l) => l.diseaseNameNarrowBrownLeafSpot,
    'Rice Hispa': (l) => l.diseaseNameRiceHispa,
    'Sheath Blight': (l) => l.diseaseNameSheathBlight,
  };

  /// Returns the localized display name for a disease model class.
  /// Falls back to the original class name for unknown classes.
  static String getDisplayName(BuildContext context, String modelClassName) {
    final l = AppLocalizations.of(context);
    if (l == null) return modelClassName;
    final fn = _map[modelClassName];
    return fn != null ? fn(l) : modelClassName;
  }
}

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Maps region IDs (unchanged) to localized display names.
/// The regionId values are never modified.
class RegionLocalizer {
  static final Map<String, String Function(AppLocalizations)> _map = {
    'central_highlands': (l) => l.regionCentralHighlands,
    'uva_zone': (l) => l.regionUvaZone,
    'eastern_dry_zone': (l) => l.regionEasternDryZone,
    'north_central_dry_zone': (l) => l.regionNorthCentralDryZone,
    'northern_dry_zone': (l) => l.regionNorthernDryZone,
    'northwestern_intermediate': (l) => l.regionNorthwesternIntermediate,
    'sabaragamuwa_zone': (l) => l.regionSabaragamuwaZone,
    'southern_wet_zone': (l) => l.regionSouthernWetZone,
    'western_wet_zone': (l) => l.regionWesternWetZone,
  };

  /// Returns the localized display name for a region by its ID.
  /// Falls back to the raw display name if the ID is unknown.
  static String getDisplayName(BuildContext context, String regionId, {String? fallback}) {
    final l = AppLocalizations.of(context);
    if (l == null) return fallback ?? regionId;
    final fn = _map[regionId];
    return fn != null ? fn(l) : (fallback ?? regionId);
  }
}

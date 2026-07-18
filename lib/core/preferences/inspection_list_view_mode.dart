import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

enum InspectionListViewMode {
  cards,
  table;

  String get label => switch (this) {
        InspectionListViewMode.cards => 'Cards',
        InspectionListViewMode.table => 'Table',
      };

  static InspectionListViewMode fromStorage(String? raw) {
    return switch (raw) {
      'table' => InspectionListViewMode.table,
      _ => InspectionListViewMode.cards,
    };
  }

  String get storageValue => name;
}

final inspectionListViewModeProvider = StateNotifierProvider<
    InspectionListViewModeNotifier, InspectionListViewMode>((ref) {
  return InspectionListViewModeNotifier();
});

class InspectionListViewModeNotifier
    extends StateNotifier<InspectionListViewMode> {
  InspectionListViewModeNotifier() : super(InspectionListViewMode.cards) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = InspectionListViewMode.fromStorage(
      prefs.getString(AppConstants.prefInspectionListView),
    );
  }

  Future<void> setMode(InspectionListViewMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefInspectionListView, mode.storageValue);
  }
}

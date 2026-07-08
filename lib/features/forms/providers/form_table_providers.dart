import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormTableNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FormTableNotifier() : super([]);

  void addRecord(Map<String, dynamic> record) {
    state = [...state, record];
  }

  void updateRecord(int index, Map<String, dynamic> record) {
    if (index < 0 || index >= state.length) return;
    final updated = [...state];
    updated[index] = record;
    state = updated;
  }

  void removeRecord(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }

  void clear() => state = [];
}

final c1TableProvider =
    StateNotifierProvider<FormTableNotifier, List<Map<String, dynamic>>>(
  (ref) => FormTableNotifier(),
);

final c7TableProvider =
    StateNotifierProvider<FormTableNotifier, List<Map<String, dynamic>>>(
  (ref) => FormTableNotifier(),
);

final t2TableProvider =
    StateNotifierProvider<FormTableNotifier, List<Map<String, dynamic>>>(
  (ref) => FormTableNotifier(),
);

final t72TableProvider =
    StateNotifierProvider<FormTableNotifier, List<Map<String, dynamic>>>(
  (ref) => FormTableNotifier(),
);

final t8TableProvider =
    StateNotifierProvider<FormTableNotifier, List<Map<String, dynamic>>>(
  (ref) => FormTableNotifier(),
);

final t9TableProvider =
    StateNotifierProvider<FormTableNotifier, List<Map<String, dynamic>>>(
  (ref) => FormTableNotifier(),
);

final t10TableProvider =
    StateNotifierProvider<FormTableNotifier, List<Map<String, dynamic>>>(
  (ref) => FormTableNotifier(),
);

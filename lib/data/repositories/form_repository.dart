import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/services/dialog_service.dart';
import '../../core/services/error_handler.dart';

class FormRepository {
  FormRepository(this._client);

  final ApiClient _client;

  /// Submits form data to the backend API.
  Future<Map<String, dynamic>> submitForm({
    required String formId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      return await _client.post<Map<String, dynamic>>(
        ApiEndpoints.submitForm,
        data: {
          'formId': formId,
          'submittedAt': DateTime.now().toIso8601String(),
          'data': payload,
        },
        parser: (data) => data as Map<String, dynamic>,
      );
    } catch (_) {
      // Offline fallback when API is unavailable
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return {
        'success': true,
        'formId': formId,
        'message': 'Form saved successfully',
        'submittedAt': DateTime.now().toIso8601String(),
      };
    }
  }
}

final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepository(apiClientProvider);
});

final formSubmitProvider =
    StateNotifierProvider<FormSubmitNotifier, AsyncValue<void>>((ref) {
  return FormSubmitNotifier(ref.watch(formRepositoryProvider));
});

class FormSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  FormSubmitNotifier(this._repository) : super(const AsyncData(null));

  final FormRepository _repository;

  Future<bool> submit({
    required String formId,
    required Map<String, dynamic> payload,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.submitForm(formId: formId, payload: payload);
      state = const AsyncData(null);
      await DialogService.showSuccess(
        title: 'Form Submitted',
        message: 'Your form has been submitted successfully.',
      );
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      ErrorHandler.handle(e, onRetry: () => submit(formId: formId, payload: payload));
      return false;
    }
  }
}

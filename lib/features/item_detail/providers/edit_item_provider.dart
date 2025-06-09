// lib/features/items/providers/edit_item_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/services/image_service.dart';
import 'package:client/services/api_service_item.dart';

final editItemProvider = StateNotifierProvider<EditItemNotifier, EditItemState>(
  (ref) {
    return EditItemNotifier();
  },
);

class EditItemState {
  final bool isLoading;
  final String? error;
  final double uploadProgress;

  EditItemState({
    this.isLoading = false,
    this.error,
    this.uploadProgress = 0.0,
  });

  EditItemState copyWith({
    bool? isLoading,
    String? error,
    double? uploadProgress,
  }) {
    return EditItemState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class EditItemNotifier extends StateNotifier<EditItemState> {
  EditItemNotifier() : super(EditItemState());

  final FirebaseImageService _firebaseImageService = FirebaseImageService();
  final ItemApiService _itemApiService = ItemApiService();

  Future<Map<String, dynamic>> updateItem({
    required String itemId,
    required Map<String, dynamic> itemData,
    required List<String> existingImageUrls,
    required List<XFile> newImages,
    required List<String> imagesToDelete,
  }) async {
    state = state.copyWith(isLoading: true, error: null, uploadProgress: 0.0);

    try {
      List<String> finalImageUrls = [...existingImageUrls];

      // Step 1: Delete removed images from Firebase Storage
      if (imagesToDelete.isNotEmpty) {
        state = state.copyWith(uploadProgress: 0.1);
        await _firebaseImageService.deleteMultipleImages(imagesToDelete);
        // Remove deleted images from final URLs
        finalImageUrls.removeWhere((url) => imagesToDelete.contains(url));
      }

      // print('Final image URLs after deletion: $finalImageUrls');

      // Step 2: Upload new images to Firebase Storage
      if (newImages.isNotEmpty) {
        state = state.copyWith(uploadProgress: 0.3);

        final newImageUrls = await _firebaseImageService.uploadMultipleImages(
          newImages,
        );

        if (newImageUrls.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to upload new images to Firebase Storage',
          );
          return {
            'success': false,
            'message': 'Failed to upload new images to Firebase Storage',
          };
        }

        // Add new images to final URLs
        finalImageUrls.addAll(newImageUrls);
        state = state.copyWith(uploadProgress: 0.7);
      }

      // print('Final image URLs after upload: $finalImageUrls');

      // Step 3: Update item data with final image URLs
      final Map<String, dynamic> itemDataWithImages = {
        ...itemData,
        'imageUrls': finalImageUrls,
      };
      // print('Item data with images: $itemDataWithImages');
      // print('Updating item with ID: $itemId');
      // Step 4: Update the item in the database
      final itemResponse = await _itemApiService.updateItem(
        itemId,
        itemDataWithImages,
      );
      print('Item update response: $itemResponse');
      if (!itemResponse['success']) {
        state = state.copyWith(
          isLoading: false,
          error: itemResponse['message'],
        );
        return {'success': false, 'message': itemResponse['message']};
      }

      state = state.copyWith(isLoading: false, uploadProgress: 1.0);
      return {'success': true, 'message': 'Item updated successfully'};
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  void resetState() {
    state = EditItemState();
  }
}

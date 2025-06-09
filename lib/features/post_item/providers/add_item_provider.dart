// lib/features/items/providers/add_item_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/services/image_service.dart';
import 'package:client/services/api_service_item.dart';

final addItemProvider = StateNotifierProvider<AddItemNotifier, AddItemState>((
  ref,
) {
  return AddItemNotifier();
});

class AddItemState {
  final bool isLoading;
  final String? error;
  final double uploadProgress;

  AddItemState({this.isLoading = false, this.error, this.uploadProgress = 0.0});

  AddItemState copyWith({
    bool? isLoading,
    String? error,
    double? uploadProgress,
  }) {
    return AddItemState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class AddItemNotifier extends StateNotifier<AddItemState> {
  AddItemNotifier() : super(AddItemState());

  final FirebaseImageService _firebaseImageService = FirebaseImageService();
  final ItemApiService _itemApiService = ItemApiService();

  Future<Map<String, dynamic>> createItem({
    required Map<String, dynamic> itemData,
    required List<XFile> images,
  }) async {
    state = state.copyWith(isLoading: true, error: null, uploadProgress: 0.0);

    try {
      List<String> imageUrls = [];

      // Step 1: Upload images to Firebase Storage first
      if (images.isNotEmpty) {
        state = state.copyWith(uploadProgress: 0.2);

        imageUrls = await _firebaseImageService.uploadMultipleImages(images);

        if (imageUrls.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to upload images to Firebase Storage',
          );
          return {
            'success': false,
            'message': 'Failed to upload images to Firebase Storage',
          };
        }

        state = state.copyWith(uploadProgress: 0.7);
      }

      // Step 2: Add image URLs to item data
      final Map<String, dynamic> itemDataWithImages = {
        ...itemData,
        'imageUrls': imageUrls, // Add the Firebase URLs to the item data
      };

      // Step 3: Create the item with image URLs in the database
      final itemResponse = await _itemApiService.createItem(itemDataWithImages);

      if (!itemResponse['success']) {
        // If item creation fails, clean up uploaded images
        if (imageUrls.isNotEmpty) {
          await _firebaseImageService.deleteMultipleImages(imageUrls);
        }

        state = state.copyWith(
          isLoading: false,
          error: itemResponse['message'],
        );
        return {'success': false, 'message': itemResponse['message']};
      }

      state = state.copyWith(isLoading: false, uploadProgress: 1.0);
      return {'success': true, 'message': 'Item created successfully'};
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }
}

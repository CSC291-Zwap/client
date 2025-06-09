import 'package:client/features/item_detail/providers/edit_item_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:client/data/models/item.dart';
import 'package:client/features/home/providers/items_provider.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  final Item item;

  const EditItemScreen({super.key, required this.item});

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  // Changed from TextEditingController to String for dropdown
  String _selectedCategory = 'fashion'; // Default value

  // Image handling
  final ImagePicker _picker = ImagePicker();
  List<String> _existingImageUrls = [];
  List<XFile> _newImages = [];
  List<String> _imagesToDelete = [];

  // Categories list (same as add item screen)
  final List<String> _categories = [
    'fashion',
    'electronic',
    'kitchen',
    'others',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _priceController = TextEditingController(
      text: widget.item.price.toString(),
    );

    // Initialize category dropdown with existing value or keep default
    if (widget.item.category != null && widget.item.category!.isNotEmpty) {
      final itemCategory = widget.item.category!.toLowerCase();
      if (_categories.contains(itemCategory)) {
        _selectedCategory = itemCategory;
      }
      // If category doesn't exist in our list, keep the default 'fashion'
    }

    // Initialize existing images - ensure we're working with a proper list
    _existingImageUrls =
        widget.item.images != null ? List<String>.from(widget.item.images) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking images from gallery: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _newImages.add(image);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  void _removeExistingImage(int index) {
    // Add safety check
    if (index >= 0 && index < _existingImageUrls.length) {
      setState(() {
        final imageUrl = _existingImageUrls[index];
        _imagesToDelete.add(imageUrl);
        _existingImageUrls.removeAt(index);
      });
    }
  }

  void _removeNewImage(int index) {
    // Add safety check
    if (index >= 0 && index < _newImages.length) {
      setState(() {
        _newImages.removeAt(index);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if there's at least one image (existing or new)
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      _showErrorSnackBar('Please keep at least one image');
      return;
    }

    try {
      final itemData = {
        'prodName': _titleController.text.trim(),
        'prodDesc': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
      };

      final result = await ref
          .read(editItemProvider.notifier)
          .updateItem(
            itemId: widget.item.id,
            itemData: itemData,
            existingImageUrls: _existingImageUrls,
            newImages: _newImages,
            imagesToDelete: _imagesToDelete,
          );

      print('Update result: $result');

      if (result['success']) {
        if (mounted) {
          // Invalidate the items provider to refresh the list
          ref.invalidate(allItemsProvider);

          _showSuccessSnackBar('Item updated successfully');

          // Create updated item object
          final updatedItem = Item(
            id: widget.item.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            price: double.parse(_priceController.text.trim()).toInt(),
            category: _selectedCategory,
            images: _existingImageUrls, // Updated URLs
            userId: widget.item.userId,
            createdAt: widget.item.createdAt,
          );

          Navigator.of(context).pop(updatedItem);
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(result['message'] ?? 'Failed to update item');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error updating item: $e');
      }
    }
  }

  Widget _buildImageSection() {
    final editItemState = ref.watch(editItemProvider);
    final totalImages = _existingImageUrls.length + _newImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              totalImages == 0
                  ? InkWell(
                    onTap:
                        editItemState.isLoading ? null : _showImageSourceDialog,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Images',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: totalImages + 1,
                    itemBuilder: (context, index) {
                      if (index == totalImages) {
                        return InkWell(
                          onTap:
                              editItemState.isLoading
                                  ? null
                                  : _showImageSourceDialog,
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.grey),
                          ),
                        );
                      }

                      // Show existing images first
                      if (index < _existingImageUrls.length) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _existingImageUrls[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade300,
                                      child: const CircularProgressIndicator(),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap:
                                      editItemState.isLoading
                                          ? null
                                          : () => _removeExistingImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Show new images
                      final newImageIndex = index - _existingImageUrls.length;
                      // Add safety check for new image index
                      if (newImageIndex >= 0 &&
                          newImageIndex < _newImages.length) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_newImages[newImageIndex].path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap:
                                      editItemState.isLoading
                                          ? null
                                          : () =>
                                              _removeNewImage(newImageIndex),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                              // Badge for new images
                              Positioned(
                                bottom: 2,
                                left: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Return empty container if index is out of bounds
                      return const SizedBox.shrink();
                    },
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final editItemState = ref.watch(editItemProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        actions: [
          TextButton(
            onPressed: editItemState.isLoading ? null : _updateItem,
            child:
                editItemState.isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show upload progress if loading
              if (editItemState.isLoading) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Updating item...'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: editItemState.uploadProgress,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(editItemState.uploadProgress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Images Section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                controller: _titleController,
                enabled: !editItemState.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                enabled: !editItemState.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                enabled: !editItemState.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Price (Baht)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.toUpperCase()),
                      );
                    }).toList(),
                onChanged:
                    editItemState.isLoading
                        ? null
                        : (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: editItemState.isLoading ? null : _updateItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      editItemState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Update Item',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

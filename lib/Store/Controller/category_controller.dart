import 'package:family_mart/Store/services/category_services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../Models/category_model.dart';

class CategoryController extends GetxController {
  // final CategoryService _categoryService;
  final _categoryService = Get.find<CategoryService>();
  var isLoading = false.obs;
  var categories = <CategoryFamily>[].obs;
  var errorMessage = ''.obs;

  // CategoryController({required CategoryService categoryService})
  // : _categoryService = categoryService;
  @override
  void onInit() {
    super.onInit();

    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _categoryService.getCategories();

      if (response.success) {
        // Explicit type casting here
        final List<CategoryFamily>? categoryList = response.data;
        if (categoryList != null) {
          categories.assignAll(categoryList);
        } else {
          errorMessage('Invalid category data format');
        }
      } else {
        errorMessage(response.message ?? 'Failed to load categories');
      }
    } catch (e) {
      errorMessage('An error occurred while loading categories');
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
    } finally {
      isLoading(false);
    }
  }
}

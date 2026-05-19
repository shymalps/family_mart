import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/category_controller.dart';
import '../../../Controller/product_list_controller.dart';
import '../../../Extras/approutes/route_name.dart';

class EnhancedSearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final ProductController productController;
  final CategoryController categoryController;

  const EnhancedSearchWidget({
    Key? key,
    required this.onSearch,
    required this.productController,
    required this.categoryController,
  }) : super(key: key);

  @override
  State<EnhancedSearchWidget> createState() => _EnhancedSearchWidgetState();
}

class _EnhancedSearchWidgetState extends State<EnhancedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isShowingDropdown = false;
  List<SearchSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _searchController.text.isNotEmpty) {
      _showDropdown();
    } else {
      _hideDropdown();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _hideDropdown();
      return;
    }

    _generateSuggestions(query);

    if (_focusNode.hasFocus) {
      _showDropdown();
    }

    // Don't trigger search for home page - only show suggestions
  }

  void _generateSuggestions(String query) {
    final suggestions = <SearchSuggestion>[];
    final queryLower = query.toLowerCase();

    // Add product suggestions with their category info
    final products = widget.productController.products
        .where((product) => product.name.toLowerCase().contains(queryLower))
        .take(8)
        .toList();

    for (final product in products) {
      // Get category name for this product
      String categoryName = 'Product';
      try {
        final category = widget.categoryController.categories
            .firstWhere((cat) => cat.id == product.id);
        categoryName = category.name;
      } catch (e) {
        // Category not found, use default
        categoryName = 'Product';
      }

      suggestions.add(SearchSuggestion(
        text: product.name,
        subtitle: categoryName,
        type: SuggestionType.product,
        imageUrl: product.imageUrl,
        productData: product, // Store the actual product data
      ));
    }

    // Add category suggestions
    final categories = widget.categoryController.categories
        .where((category) => category.name.toLowerCase().contains(queryLower))
        .take(3)
        .toList();

    for (final category in categories) {
      suggestions.add(SearchSuggestion(
        text: category.name,
        subtitle: 'Browse ${category.name}',
        type: SuggestionType.category,
        icon: Icons.category_outlined,
        categoryData: category, // Store category data
      ));
    }

    setState(() {
      _suggestions = suggestions;
    });
  }

  void _showDropdown() {
    if (_isShowingDropdown || _suggestions.isEmpty) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isShowingDropdown = true;
  }

  void _hideDropdown() {
    _removeOverlay();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowingDropdown = false;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return _buildSuggestionItem(_suggestions[index]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(SearchSuggestion suggestion) {
    return InkWell(
      onTap: () {
        _hideDropdown();
        _focusNode.unfocus();

        // Handle different types of suggestions
        if (suggestion.type == SuggestionType.product && suggestion.productData != null) {
          // Navigate to product description page
          Get.toNamed(RouteName.prodesc, arguments: suggestion.productData);
        } else if (suggestion.type == SuggestionType.category && suggestion.categoryData != null) {
          // Navigate to category page
          Get.toNamed(RouteName.productsBasedOnCategory, arguments: {
            'id': suggestion.categoryData!.id,
            'name': suggestion.categoryData!.name,
            'icon': Icons.category_rounded,
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Product image or category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: suggestion.type == SuggestionType.product && suggestion.imageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  suggestion.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.shopping_basket_outlined,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                        ),
                      ),
                    );
                  },
                ),
              )
                  : Icon(
                suggestion.icon ?? Icons.category_outlined,
                size: 20,
                color: _getIconColor(suggestion.type),
              ),
            ),
            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow button
            GestureDetector(
              onTap: () {
                _searchController.text = suggestion.text;
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: suggestion.text.length),
                );
                _hideDropdown();
                // Only fill the search box, don't perform search or navigate
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Transform.rotate(
                  angle: -0.785398, // -45 degrees in radians
                  child: Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(SuggestionType type) {
    switch (type) {
      case SuggestionType.product:
        return Colors.blue;
      case SuggestionType.category:
        return Colors.orange;
      case SuggestionType.trending:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search for products, categories...',
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                _searchController.clear();
                widget.onSearch('');
                _hideDropdown();
              },
              icon: Icon(
                Icons.clear,
                color: Colors.grey[500],
                size: 20,
              ),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          onSubmitted: (value) {
            // Only perform search when user presses enter/search
            widget.onSearch(value);
            _hideDropdown();
            _focusNode.unfocus();
          },
        ),
      ),
    );
  }
}

class SearchSuggestion {
  final String text;
  final String subtitle;
  final SuggestionType type;
  final IconData? icon;
  final String? imageUrl;
  final dynamic productData; // Store actual product object
  final dynamic categoryData; // Store actual category object

  SearchSuggestion({
    required this.text,
    required this.subtitle,
    required this.type,
    this.icon,
    this.imageUrl,
    this.productData,
    this.categoryData,
  });
}

enum SuggestionType {
  product,
  category,
  trending,
}
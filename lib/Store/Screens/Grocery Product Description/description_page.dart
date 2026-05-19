import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/product_desription_controller.dart';
import '../../Extras/animated_wrapper.dart';
import '../../Extras/styles.dart';
import '../../Widgets/loading_spinner.dart';

class ProductDescriptionPage extends StatefulWidget {
  const ProductDescriptionPage({super.key});

  // final dynamic product;

  // const ProductDescriptionPage({super.key, required this.product});

  @override
  State<ProductDescriptionPage> createState() => _ProductDescriptionPageState();
}

class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  dynamic product = Get.arguments;

  int quantity = 1;
  int selectedImageIndex = 0;
  bool isFavorite = false;
  late ProductDescriptionController controller;

  @override
  void initState() {
    super.initState();
    print(product);
    controller = Get.put(ProductDescriptionController());
    _fetchProductDescription();
  }


  void _fetchProductDescription() {
    if (product.id != null) {
      controller.fetchProductDescription(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.bgColor,
              AppColors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedWrapper(index: 0, child: _buildTopBar()),
              Expanded(
                // This is the key fix
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.bgColor, AppColors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.1, 0.5],
                    ),
                  ),
                  child: Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _buildProductImages(),
                                _buildProductDetails(),
                                _buildNutritionInfo(),
                                _buildRelatedProducts(MediaQuery.of(context)),
                                const SizedBox(height: 100),
                                // Space for bottom bar
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildBottomBar(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImages() {
    return AnimatedWrapper(
      index: 2,
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: 1,
              onPageChanged: (index) {
                setState(() {
                  selectedImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      // Square image box (adjust to 3/4 or 4/3 if needed)
                      child: product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.contain, // Fill and crop as needed
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.background,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.shopping_basket,
                                  size: 60,
                                  color: AppColors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.background,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.shopping_basket,
                                size: 60,
                                color: AppColors.grey,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),

            // Favorite button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryDark,
                      width: 1,
                    ),
                    color: AppColors.bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.red : AppColors.grey,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Image indicators
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  1,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selectedImageIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selectedImageIndex == index
                          ? AppColors.primary
                          : AppColors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return AnimatedWrapper(
      index: 3,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: SmallLoadingSpinner(
                colors: [AppColors.primary],
              ),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.red),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage,
                  style: AppTextStyles.body1.copyWith(color: AppColors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchProductDescription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            );
          }

          final productDesc = controller.productDescription;
          if (productDesc == null) {
            return const Center(child: Text('Product not found'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      productDesc.subName.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('4.5', style: AppTextStyles.caption),
                      const SizedBox(width: 4),
                      Text('(128 reviews)',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                productDesc.name,
                style: AppTextStyles.heading2.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 8),
              Text(
                controller.getFormattedMeasurement(),
                style: AppTextStyles.body1.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Brand: ${productDesc.company}',
                style: AppTextStyles.body2.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.getFormattedPrice(),
                        style: AppTextStyles.price.copyWith(fontSize: 20),
                      ),
                      if (controller.isOnSale) ...[
                        Text(
                          controller.getFormattedMRP(),
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  _buildQuantitySelector(),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.lightGrey),
              const SizedBox(height: 20),
              Text('Description', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                (productDesc.description != null &&
                        productDesc.description!.isNotEmpty &&
                        productDesc.description != 'null')
                    ? productDesc.description!
                    : 'Product information will be updated soon. For more details, feel free to contact us.',
                style: AppTextStyles.body2.copyWith(color: AppColors.grey),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildFeatureChip(
                      'Barcode: ${productDesc.barcode}', Icons.barcode_reader),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
            icon: const Icon(Icons.remove, size: 20),
            color: quantity > 1 ? AppColors.primary : AppColors.grey,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '$quantity',
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => quantity++),
            icon: const Icon(Icons.add, size: 20),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo() {
    return AnimatedWrapper(
      index: 4,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Obx(() {
          final productDesc = controller.productDescription;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Additional Information', style: AppTextStyles.heading3),
                  const Spacer(),
                  _buildInfoButton(productDesc),
                ],
              ),
              const SizedBox(height: 20),
              if (productDesc != null) ...[
                _buildInfoGrid(productDesc),
              ] else ...[
                _buildFallbackNutritionInfo(),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInfoButton(dynamic productDesc) {
    return InkWell(
      onTap: () => _showProductDetailsDialog(productDesc),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child:
            const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _buildInfoGrid(dynamic productDesc) {
    return Column(
      children: [
        _buildInfoRow('MRP', '₹${productDesc.mrp}'),
        if (productDesc.saleRate?.isNotEmpty == true)
          _buildInfoRow('Sale Price', '₹${productDesc.saleRate}'),
        if (productDesc.cgst?.isNotEmpty == true)
          _buildInfoRow('CGST', '${productDesc.cgst}%'),
        if (productDesc.sgst?.isNotEmpty == true)
          _buildInfoRow('SGST', '${productDesc.sgst}%'),
        if (productDesc.igst?.isNotEmpty == true)
          _buildInfoRow('IGST', '${productDesc.igst}%'),
        _buildInfoRow('Measurement', controller.getFormattedMeasurement()),
        _buildInfoRow('Company', productDesc.company),
      ],
    );
  }

  Widget _buildFallbackNutritionInfo() {
    return const SizedBox.shrink();
  }

  void _showProductDetailsDialog(dynamic productDesc) {
    if (productDesc == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Additional Details',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete information about this product',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogSection('Pricing Information', [
                        _buildDialogInfoRow(
                            'MRP', '₹${productDesc.mrp}', Icons.attach_money),
                        _buildDialogInfoRow(
                            'Sale Price',
                            productDesc.saleRate ?? 'Not available',
                            Icons.local_offer),
                        _buildDialogInfoRow(
                            'Sale Margin',
                            productDesc.saleMargin ?? 'Not available',
                            Icons.trending_up),
                        _buildDialogInfoRow(
                            'Amount',
                            productDesc.amount ?? 'Not available',
                            Icons.account_balance_wallet),
                      ]),
                      const SizedBox(height: 24),
                      _buildDialogSection('Tax Information', [
                        _buildDialogInfoRow(
                            'CGST',
                            productDesc.cgst != null
                                ? '${productDesc.cgst}%'
                                : 'Not available',
                            Icons.receipt),
                        _buildDialogInfoRow(
                            'SGST',
                            productDesc.sgst != null
                                ? '${productDesc.sgst}%'
                                : 'Not available',
                            Icons.receipt_long),
                        _buildDialogInfoRow(
                            'IGST',
                            productDesc.igst != null
                                ? '${productDesc.igst}%'
                                : 'Not available',
                            Icons.description),
                      ]),
                      const SizedBox(height: 24),
                      _buildDialogSection('Product Information', [
                        _buildDialogInfoRow(
                            'Measurement',
                            controller.getFormattedMeasurement(),
                            Icons.straighten),
                        _buildDialogInfoRow(
                            'Company', productDesc.company, Icons.business),
                      ]),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top:
                        BorderSide(color: AppColors.lightGrey.withOpacity(0.5)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Got it',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDialogInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Description', style: AppTextStyles.heading1),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.4)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.body2.copyWith(color: AppColors.grey)),
          Text(value,
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    AppTextStyles.heading3.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.caption.copyWith(color: AppColors.black)),
            Text(unit,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(dynamic mediaQuery) {
    return AnimatedWrapper(
      index: 5,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Related Products', style: AppTextStyles.heading3),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: mediaQuery.size.height * 0.25,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Center(
                            child: Icon(Icons.shopping_basket,
                                size: 40, color: AppColors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product ${index + 1}',
                                style: AppTextStyles.body2
                                    .copyWith(color: AppColors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('₹${(45 + index * 10).toStringAsFixed(2)}',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.primary)),
                              const SizedBox(height: 8),
                              Container(
                                height: 24,
                                width: 24,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add,
                                    color: AppColors.white, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedWrapper(
        index: 6,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Obx(() {
              final productDesc = controller.productDescription;
              String price = '₹0.00';

              if (productDesc != null) {
                final saleRate = productDesc.saleRate;
                if (saleRate != null && saleRate.isNotEmpty) {
                  final salePrice = double.tryParse(saleRate) ?? 0.0;
                  price = '₹${(salePrice * quantity).toStringAsFixed(2)}';
                } else {
                  final mrpPrice = double.tryParse(productDesc.mrp) ?? 0.0;
                  price = '₹${(mrpPrice * quantity).toStringAsFixed(2)}';
                }
              }

              return Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Price',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.grey)),
                      Text(price, style: AppTextStyles.price),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () {
                              final productName = productDesc?.name ??
                                  product.name ??
                                  'Product';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Requested $quantity $productName to cart'),
                                  backgroundColor: AppColors.primary,
                                  margin: const EdgeInsets.only(
                                    bottom: 100,
                                    left: 16,
                                    right: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: SmallLoadingSpinner(
                                colors: [AppColors.primary],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart, size: 20),
                                const SizedBox(width: 8),
                                Text('Request this product',
                                    style: AppTextStyles.body1
                                        .copyWith(color: AppColors.white)),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

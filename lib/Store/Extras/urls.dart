class Constants {
  // Base URLs
  static const String _host = "https://billing.familymartsupermarket.com/";
  static const String _apiKeyValue = "a4690239-5216-4974-87f6-1588153d7a20";

  static const String baseURL = "${_host}api/";
  static const String imageBaseURL = "${_host}public/assets/image/customer/";
  static const String thumbnailBaseUrl =
      "${_host}public/assets/image/product/thumbnail/";

  // API Endpoints
  static const String checkVersion = "check_version";
  static const String bannerList = "banner_img";
  static const String login = "login";
  static const String register = "register";
  static const String otp = "otp";
  static const String shopListAPI = "get_table";
  static const String getTableCondition = "get_table_condition";
  static const String customerBillHistory = "customer_bill_history_loader";
  static const String billDuesHistory = "bill_dues_history_loader";
  static const String billView = "bill_view/";
  static const String creditHistory = "credit_history";
  static const String totalPurchaseCount = "total_purchase_count";
  static const String passwordReset = "password_reset";
  static const String customerProfileUpdate = "cust_profile_update";
  static const String getLedger = "get_ledger";
  static const String productListLoader = "product_list_loader";
  static const String searchProduct = "product_search_by_name";
  static const String updateCart = "upadate_cart"; // check for typo
  static const String viewCart = "view_cart";
  static const String saveAppError = "save_app_error";
  static const String placeOrder = "place_order";
  static const String viewNewOrder = "view_new_order";
  static const String productOrderDetails = "product_order_details";
  static const String categoryApi = 'get_table';
  static const String profileUpdate = 'cust_profile_update';
  static const String clearCart = 'clear_cart';

  // API Headers
  static const String contentType = "Content-Type";
  static const String applicationJson = "application/json; charset=UTF-8";
  static const String plainText = "text/plain; charset=UTF-8";
  static const String apiKeyHeader = "api-key";

  static String get apiKey => _apiKeyValue;
}

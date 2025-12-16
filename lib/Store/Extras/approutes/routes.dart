import 'package:family_mart/Store/Bindings/bills_binding.dart';
import 'package:family_mart/Store/Screens/About%20Us/about_us.dart';
import 'package:family_mart/Store/Screens/Category/category_page.dart';
import 'package:family_mart/Store/Screens/Dashboard/credit_screen.dart';
import 'package:family_mart/Store/Screens/Dashboard/dues.dart';
import 'package:family_mart/Store/Screens/Dashboard/ledger.dart';
import 'package:family_mart/Store/Screens/Grocery%20Product%20Description/description_page.dart';
import 'package:family_mart/Store/Screens/Notifications/notifications.dart';
import 'package:family_mart/Store/Screens/Splash%20Screen/splash_screen.dart';
import 'package:family_mart/Store/Screens/settings/reset_password.dart';
import 'package:family_mart/Store/Screens/settings/settings.dart';
import 'package:family_mart/Store/orders/orders_screen.dart';
import '../../Bindings/homescreenbinding.dart';
import '../../Screens/Authentication/auth.dart';
import '../../Screens/Authentication/otp.dart';
import '../../Screens/Category/category_listing.dart';
import '../../Screens/Dashboard/bills.dart';
import '../../Screens/Dashboard/dashboard_screen.dart';
import '../../Screens/Dashboard/single_bill_view.dart';
import '../../Screens/Navigation/bottom_navigation.dart';
import '../../Screens/Profile/edit_profile.dart';
import 'route_name.dart';
import 'routig_widget.dart';

class AppRoutes {
  static final routes = [
    getPage(RouteName.splash, const SplashScreen(), []),
    getPage(RouteName.home, AuthPage(), []),
    getPage(RouteName.navbar,  MainNavigationPage(), [
      HomeScreenBinding(),
    ]),
    getPage(RouteName.otp, const OtpVerificationPage(), []),
    getPage(RouteName.editprofile, const EditProfilePage(), []),
    getPage(RouteName.dashboard, const DashboardPage(), []),
    getPage(RouteName.billlist, const BillsPage(), [BillsBinding()]),
    getPage(RouteName.prodesc, const ProductDescriptionPage(), []),
    getPage(RouteName.singlebillview, const SingleBillViewUI(), []),
    getPage(RouteName.ledger, LedgerScreen(), []),
    getPage(RouteName.dues, const DuesPage(), []),
    getPage(RouteName.aboutUs, const AboutUs(), []),
    getPage(RouteName.category, const CategoryPage(), []),
    getPage(RouteName.productsBasedOnCategory, const CategoryProductsScreen(), []),
    getPage(RouteName.notifications,  NotificationScreen(), []),
    getPage(RouteName.settings, const SettingsScreen(), []),
    getPage(RouteName.changepassword, const ChangePasswordPage(), []),
    getPage(RouteName.creditHistory, const CreditHistoryPage(), []),
    getPage(RouteName.orders, const OrdersScreen(), []),
  ];
}

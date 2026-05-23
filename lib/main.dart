import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/order_success_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/product/product_list_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SeedService.seedProducts();
  runApp(const RichFashionApp());
}

class RichFashionApp extends StatelessWidget {
  const RichFashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rich Fashion',
        theme: AppTheme.light(),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName:        (_) => const SplashScreen(),
          OnboardingScreen.routeName:    (_) => const OnboardingScreen(),
          LoginScreen.routeName:         (_) => const LoginScreen(),
          RegisterScreen.routeName:      (_) => const RegisterScreen(),
          MainShell.routeName:           (_) => const MainShell(),
          ProductListScreen.routeName:   (_) => const ProductListScreen(),
          ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
          CartScreen.routeName:          (_) => const CartScreen(),
          CheckoutScreen.routeName:      (_) => const CheckoutScreen(),
          OrderSuccessScreen.routeName:  (_) => const OrderSuccessScreen(),
          OrderHistoryScreen.routeName:  (_) => const OrderHistoryScreen(),
          EditProfileScreen.routeName:   (_) => const EditProfileScreen(),
        },
      ),
    );
  }
}
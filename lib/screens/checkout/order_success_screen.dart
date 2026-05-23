import 'package:flutter/material.dart';

import '../../widgets/common/app_button.dart';
import '../home/main_shell.dart';
import '../orders/order_history_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  static const routeName = '/order-success';

  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receive the order ID passed from CheckoutScreen
    final orderId = ModalRoute.of(context)?.settings.arguments as String?;
    final shortId = (orderId != null && orderId.length > 6)
        ? orderId.substring(0, 6).toUpperCase()
        : '------';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.green.shade50,
                child: Icon(Icons.check_circle_rounded,
                    size: 58, color: Colors.green.shade700),
              ),
              const SizedBox(height: 22),
              Text(
                'Order Placed Successfully',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your order has been confirmed and saved.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Order ID badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EFE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Order #$shortId',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // View orders button
              AppButton(
                label: 'View My Orders',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MainShell.routeName,
                    (_) => false,
                  );
                  Navigator.pushNamed(
                    context,
                    OrderHistoryScreen.routeName,
                  );
                },
              ),
              const SizedBox(height: 10),

              // Back to home button
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MainShell.routeName,
                    (_) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
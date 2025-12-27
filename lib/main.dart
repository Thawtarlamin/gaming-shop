import 'package:flutter/material.dart';
import 'package:gaming_shop/router/app_router.dart';
import 'utils/storage_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if user is already logged in
  final isLoggedIn = await StorageHelper.isLoggedIn();
  
  final appRouter = AppRouter();
  
  runApp(MaterialApp.router(
    debugShowCheckedModeBanner: false,
    routerConfig: appRouter.config(),
    theme: ThemeData(
      primaryColor: const Color(0xFF08652C),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    ),
    builder: (context, child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout for web
          if (constraints.maxWidth > 1200) {
            // Desktop: max width container
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: child,
              ),
            );
          } else if (constraints.maxWidth > 600) {
            // Tablet: centered with padding
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: child,
              ),
            );
          }
          // Mobile: full width
          return child ?? const SizedBox.shrink();
        },
      );
    },
  ));
  
  // Navigate to appropriate page based on login status
  if (!isLoggedIn) {
    appRouter.push(const LoginRoute());
  }
}

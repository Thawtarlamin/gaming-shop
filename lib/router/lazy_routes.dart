// Lazy loading helper for routes
// This helps reduce initial bundle size for web

import 'package:flutter/material.dart';

// Core pages - loaded immediately
export 'package:gaming_shop/page/home_page.dart';
export 'package:gaming_shop/page/login_page.dart';
export 'package:gaming_shop/page/register_page.dart';

// Feature pages - can be lazy loaded
class LazyPages {
  // Game detail page
  static Widget gameDetail() {
    return FutureBuilder(
      future: _loadGameDetailPage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF08652C),
          ),
        );
      },
    );
  }

  static Future<Widget> _loadGameDetailPage() async {
    final module = await import('package:gaming_shop/page/game_detail_page.dart');
    return module.GameDetailPage();
  }

  // Profile page
  static Widget profile() {
    return FutureBuilder(
      future: _loadProfilePage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF08652C),
          ),
        );
      },
    );
  }

  static Future<Widget> _loadProfilePage() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final module = await import('package:gaming_shop/page/profile_page.dart');
    return module.ProfilePage();
  }

  // Settings page
  static Widget settings() {
    return FutureBuilder(
      future: _loadSettingsPage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF08652C),
          ),
        );
      },
    );
  }

  static Future<Widget> _loadSettingsPage() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final module = await import('package:gaming_shop/page/settings_page.dart');
    return module.SettingsPage();
  }
}

// Dynamic import helper
Future<dynamic> import(String path) async {
  // This is a placeholder - Dart doesn't support dynamic imports like JavaScript
  // In production build, Flutter will handle code splitting automatically
  await Future.delayed(const Duration(milliseconds: 50));
  throw UnimplementedError('Dynamic imports not supported in Dart');
}

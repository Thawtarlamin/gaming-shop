import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gaming_shop/page/login_page.dart';
import 'package:gaming_shop/page/register_page.dart';
import 'package:gaming_shop/page/home_page.dart';
import 'package:gaming_shop/page/game_detail_page.dart';
import 'package:gaming_shop/page/profile_page.dart';
import 'package:gaming_shop/page/settings_page.dart';
import 'package:gaming_shop/page/order_history_page.dart';
import 'package:gaming_shop/page/topup_history_page.dart';
import 'package:gaming_shop/page/topup_page.dart';
import 'package:gaming_shop/model/game_model.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, path: '/', initial: true),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: RegisterRoute.page, path: '/register'),
        AutoRoute(page: GameDetailRoute.page, path: '/game/:id'),
        AutoRoute(page: ProfileRoute.page, path: '/profile'),
        AutoRoute(page: SettingsRoute.page, path: '/settings'),
        AutoRoute(page: OrderHistoryRoute.page, path: '/orders'),
        AutoRoute(page: TopupHistoryRoute.page, path: '/topup-history'),
        AutoRoute(page: TopupRoute.page, path: '/topup'),
      ];
}

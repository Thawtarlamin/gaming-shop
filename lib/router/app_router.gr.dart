// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [GameDetailPage]
class GameDetailRoute extends PageRouteInfo<GameDetailRouteArgs> {
  GameDetailRoute({
    Key? key,
    GameModel? game,
    String? gameId,
    List<PageRouteInfo>? children,
  }) : super(
         GameDetailRoute.name,
         args: GameDetailRouteArgs(key: key, game: game, gameId: gameId),
         rawPathParams: {'id': gameId},
         initialChildren: children,
       );

  static const String name = 'GameDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<GameDetailRouteArgs>(
        orElse: () => GameDetailRouteArgs(gameId: pathParams.optString('id')),
      );
      return GameDetailPage(
        key: args.key,
        game: args.game,
        gameId: args.gameId,
      );
    },
  );
}

class GameDetailRouteArgs {
  const GameDetailRouteArgs({this.key, this.game, this.gameId});

  final Key? key;

  final GameModel? game;

  final String? gameId;

  @override
  String toString() {
    return 'GameDetailRouteArgs{key: $key, game: $game, gameId: $gameId}';
  }
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [OrderHistoryPage]
class OrderHistoryRoute extends PageRouteInfo<void> {
  const OrderHistoryRoute({List<PageRouteInfo>? children})
    : super(OrderHistoryRoute.name, initialChildren: children);

  static const String name = 'OrderHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrderHistoryPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [TopupHistoryPage]
class TopupHistoryRoute extends PageRouteInfo<void> {
  const TopupHistoryRoute({List<PageRouteInfo>? children})
    : super(TopupHistoryRoute.name, initialChildren: children);

  static const String name = 'TopupHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TopupHistoryPage();
    },
  );
}

/// generated route for
/// [TopupPage]
class TopupRoute extends PageRouteInfo<void> {
  const TopupRoute({List<PageRouteInfo>? children})
    : super(TopupRoute.name, initialChildren: children);

  static const String name = 'TopupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TopupPage();
    },
  );
}

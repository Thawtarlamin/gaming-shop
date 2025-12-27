import 'package:dio/dio.dart';
import 'package:gaming_shop/model/app_config_model.dart';
import 'package:gaming_shop/model/game_model.dart';

class ApiService {
  static Future<AppConfigModel?> getAppConfig() async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/app-config',
      );

      if (response.data != null) {
        return AppConfigModel.fromJson(response.data);
      } else {
        throw Exception("API did not return data");
      }
    } catch (e) {
      print("Error fetching app config: $e");
      return null;
    }
  }

  static Future<List<GameModel>> Products() async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/products',
      );

      // check response.data is List
      if (response.data is List) {
        return (response.data as List)
            .map((e) => GameModel.fromJson(e))
            .toList();
      } else {
        throw Exception("API did not return a List");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getProductFields(String gameCode) async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/products/fields/$gameCode',
      );

      if (response.data != null && response.data['success'] == true) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching product fields: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> checkPlayerId({
    required String game,
    required String userId,
    String? serverId,
  }) async {
    try {
      final response = await Dio().post(
        'https://sl-gaming-shop.store/api/validation/check-player',
        data: {
          'game': game,
          'user_id': userId,
          if (serverId != null && serverId.isNotEmpty) 'server_id': serverId,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Validation failed',
        };
      }
    } catch (e) {
      print("Error checking player ID: $e");
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Player ID validation failed',
        };
      }
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Dio().post(
        'https://sl-gaming-shop.store/api/auth/login',
        data: {'email': email, 'password': password},
      );

      // API က success field မပါဘဲ တိုက်ရိုက် user data ပြန်ပေးတာမို့
      // token ရှိ/မရှိ သို့မဟုတ် _id ရှိ/မရှိစစ်မယ်
      if (response.data != null &&
          (response.data['token'] != null || response.data['_id'] != null)) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print("Error logging in: $e");
      if (e is DioException && e.response != null) {
        print('Error response: ${e.response?.data}');
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Invalid credentials',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await Dio().post(
        'https://sl-gaming-shop.store/api/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      print('Register response: ${response.data}');

      // Same as login - check for token or _id
      if (response.data != null &&
          (response.data['token'] != null || response.data['_id'] != null)) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print("Error registering: $e");
      if (e is DioException && e.response != null) {
        print('Error response: ${e.response?.data}');
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Registration failed',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Profile response: ${response.data}');

      if (response.data != null && response.data['_id'] != null) {
        return {'success': true, 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to get profile'};
      }
    } catch (e) {
      print("Error getting profile: $e");
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to get profile',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await Dio().put(
        'https://sl-gaming-shop.store/api/auth/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('Update password response: ${response.data}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password updated successfully'};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update password',
        };
      }
    } catch (e) {
      print("Error updating password: $e");
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to update password',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String token,
    required String productCode,
    required String catalogueName,
    required String playerId,
    String? serverId,
  }) async {
    try {
      final response = await Dio().post(
        'https://sl-gaming-shop.store/api/orders',
        data: {
          'product_code': productCode,
          'catalogue_name': catalogueName,
          'player_id': playerId,
          if (serverId != null) 'server_id': serverId,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      print("Error creating order: $e");
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to create order',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> getOrderById({
    required String token,
    required String orderId,
  }) async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to get order',
        };
      }
    } catch (e) {
      print("Error getting order: $e");
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Failed to get order',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> createTopup({
    required String token,
    required String screenshotPath,
    required String method,
    required String amount,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'screenshot': await MultipartFile.fromFile(screenshotPath),
        'method': method,
        'amount': amount,
      });

      final response = await Dio().post(
        'https://sl-gaming-shop.store/api/topups',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Failed to create topup request',
        };
      }
    } catch (e) {
      print("Error creating topup: $e");
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message':
              e.response?.data['message'] ?? 'Failed to create topup request',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<List<dynamic>> getPaymentAccounts({String? token}) async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/payment-accounts',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is List) {
        return response.data;
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching payment accounts: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserOrders({
    required String token,
  }) async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/orders/user/check-order',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // Handle different response structures
        if (response.data is List) {
          // If response is directly a list of orders
          return {'success': true, 'data': response.data};
        } else if (response.data is Map) {
          // If response is a map with orders inside
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('orders')) {
            return {'success': true, 'data': data['orders']};
          } else if (data.containsKey('data')) {
            return {'success': true, 'data': data['data']};
          } else {
            // Assume the entire map is the data
            return {
              'success': true,
              'data': [response.data],
            };
          }
        } else {
          return {'success': true, 'data': []};
        }
      } else {
        return {'success': false, 'message': 'Failed to get orders'};
      }
    } catch (e) {
      print("Error getting user orders: $e");
      if (e is DioException && e.response != null) {
        return {
          'success': false,
          'message': e.response?.data is Map
              ? (e.response?.data['message'] ?? 'Failed to get orders')
              : 'Failed to get orders',
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }

  static Future<Map<String, dynamic>> getUserTopups({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await Dio().get(
        'https://sl-gaming-shop.store/api/topups/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // Handle different response structures
        if (response.data is List) {
          return {'success': true, 'data': response.data};
        } else if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('topups')) {
            return {'success': true, 'data': data['topups']};
          } else if (data.containsKey('data')) {
            return {'success': true, 'data': data['data']};
          } else {
            return {
              'success': true,
              'data': [response.data],
            };
          }
        } else {
          return {'success': true, 'data': []};
        }
      } else {
        return {'success': false, 'message': 'Failed to get topup history'};
      }
    } catch (e) {
      print("Error getting user topups: $e");
      if (e is DioException && e.response != null) {
        print("Topup error status: ${e.response?.statusCode}");
        print("Topup error data: ${e.response?.data}");
        return {
          'success': false,
          'message': e.response?.statusCode == 500
              ? 'Server error. The topup history feature may not be available yet.'
              : (e.response?.data is Map
                    ? (e.response?.data['message'] ??
                          'Failed to get topup history')
                    : 'Failed to get topup history'),
        };
      }
      return {'success': false, 'message': 'Connection error'};
    }
  }
}

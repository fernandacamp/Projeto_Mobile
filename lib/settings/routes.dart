import 'package:flutter/material.dart';
import 'package:projeto_mobile/screens/new_trip_page.dart';
import '../screens/change_password.dart';
import '../screens/login_page.dart';
import '../screens/menu_page.dart';
import '../screens/order_history_page.dart';
import '../screens/profile_page.dart';
import '../screens/register_page.dart';
import '../services/auth_service.dart';

class AppRoutes {
  // Rotas estáticas
  static const String newTrip = "/new_trip";
  static const String login = "/login";
  static const String menu = "/menu";
  static const String profile = "/profile";
  static const String register = "/register";
  static const String changePassword = "/change_password";
  static const String orderHistory = "/order_history";

  // Mapa de rotas
  static final Map<String, WidgetBuilder> routes = {
    newTrip: (context) => NewTripPage(),
    login: (context) => LoginPage(),
    menu: (context) => MenuPage(),
    profile: (context) => ProfilePage(),
    register: (context) => RegisterPage(),
    changePassword: (context) => ChangePasswordPage(),
    orderHistory: (context) => OrderHistoryPage(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (routes.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: routes[settings.name]!,
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('Página não encontrada!'),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:order_food_ui/pages/dashboard_page.dart';
import 'package:order_food_ui/pages/list_food.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:order_food_ui/pages/payment-cancel.dart';
import 'package:order_food_ui/pages/payment-success.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('vi', ''), // Vietnamese
      ],
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name!);
    if (uri.path == '/') {
      return MaterialPageRoute(builder: (context) => const DashboardPage());
    } else if (uri.path == '/list_food_page') {
      return MaterialPageRoute(builder: (context) => const FoodListPage());
    } else if (uri.path == '/payment/cancel-payment') {
      return MaterialPageRoute(
          builder: (context) =>
              PaymentCancelPage(queryParams: uri.queryParameters));
    } else if (uri.path == '/payment/callback') {
      return MaterialPageRoute(
          builder: (context) =>
              PaymentSuccessPage(queryParams: uri.queryParameters));
    }
    return MaterialPageRoute(
        builder: (context) => const DashboardPage()); // Default route
  }
}

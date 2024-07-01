import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaymentSuccessPage extends StatelessWidget {
  final Map<String, String> queryParams;

  PaymentSuccessPage({required this.queryParams});

  @override
  Widget build(BuildContext context) {
    
    final String? code = queryParams['code'];
    final String? id = queryParams['id'];
    final String? cancel = queryParams['cancel'];
    final String? status = queryParams['status'];
    final String? orderCode = queryParams['orderCode'];

    // Check if the cancel status is true and status is CANCELLED
    bool isPaid = cancel == 'false' && status == 'PAID';

    if (isPaid) {
      // Call the API
      _checkTransactionSuccessed(queryParams);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Cancel - OrderCode: $orderCode'),
      ),
      body: Center(
        child: isPaid
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network('assets/payment-success.webp'),
                  SizedBox(height: 16),
                  Text(
                    'Payment has been successful',
                    style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 23),
                  ),
                ],
              )
            : Text('Invalid cancellation status'),
      ),
    );
  }

  void _checkTransactionSuccessed(Map<String, String?> queryParams) async {
    final uri = Uri.http(
        dotenv.env['API_DOMAIN'] ?? '', '/api/payment/callback', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print('Transaction cancelled successfully');
    } else {
      print('Failed to cancel transaction');
    }
  }
}

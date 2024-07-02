import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaymentCancelPage extends StatelessWidget {
  final Map<String, String> queryParams;

  PaymentCancelPage({required this.queryParams});

  @override
  Widget build(BuildContext context) {
    final String? code = queryParams['code'];
    final String? id = queryParams['id'];
    final String? cancel = queryParams['cancel'];
    final String? status = queryParams['status'];
    final String? orderCode = queryParams['orderCode'];

    // Check if the cancel status is true and status is CANCELLED
    bool isCancelled = cancel == 'true' && status == 'CANCELLED';

    if (isCancelled) {
      // Call the API
      _checkTransactionCancelled(queryParams);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Cancel - OrderCode: $orderCode'),
      ),
      body: Center(
        child: isCancelled
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network('assets/payment-failed.jpg'),
                  SizedBox(height: 16),
                  Text(
                    'Payment has been cancelled',
                    style: TextStyle(
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                        fontSize: 23),
                  ),
                ],
              )
            : Text('Invalid cancellation status'),
      ),
    );
  }

  void _checkTransactionCancelled(Map<String, String?> queryParams) async {
    final uri = Uri.http(dotenv.env['API_DOMAIN'] ?? '',
        '/api/payment/cancel-payment', queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      print('Transaction cancelled successfully');
    } else {
      print('Failed to cancel transaction');
    }
  }
}

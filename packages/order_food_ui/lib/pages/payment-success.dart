import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PaymentSuccessPage extends StatefulWidget {
  final Map<String, String> queryParams;

  PaymentSuccessPage({required this.queryParams});

  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool isLoading = false;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();

    final String? cancel = widget.queryParams['cancel'];
    final String? status = widget.queryParams['status'];

    // Check if the cancel status is true and status is PAID
    isPaid = cancel == 'false' && status == 'PAID';

    if (isPaid) {
      _checkTransactionSuccessed(widget.queryParams);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? orderCode = widget.queryParams['orderCode'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Cancel - OrderCode: $orderCode'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : isPaid
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
    setState(() {
      isLoading = true;
    });

    final uri = Uri.http(
        dotenv.env['API_DOMAIN'] ?? '', '/api/payment/callback', queryParams);
    final response = await http.get(uri);

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      print('Transaction cancelled successfully');
    } else {
      print('Failed to cancel transaction');
    }
  }
}

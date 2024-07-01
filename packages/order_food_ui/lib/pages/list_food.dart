import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  DateTime selectedDate = DateTime.now();
  List<FoodItem> foodList = [];
  List<String> uploadedFiles = [];
  Uint8List? _imageData;
  String _fileName = '';
  List<DropdownMenuItem<String>> listMember = [];

  @override
  void initState() {
    super.initState();
    loadFoodList();
    loadListMember();
  }

  Future<void> loadListMember() async {
    final dateString = DateFormat('dd/MM/yyyy').format(selectedDate);
    final url =
        '${dotenv.env['API_URL'] ?? ''}/api/gs/members/?orderDate=${Uri.encodeComponent(dateString)}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        List<String> dataMapping = List<String>.from(data);
        setState(() {
          listMember =
              dataMapping.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load food list');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadFoodList() async {
    print(dotenv.env['API_URL'] ?? '');
    final dateString = DateFormat('dd/MM/yyyy').format(selectedDate);
    final url =
        '${dotenv.env['API_URL'] ?? ''}/api/gs/?orderDate=${Uri.encodeComponent(dateString)}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          foodList = data.map((item) => FoodItem.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load food list');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showDatePicker(StateSetter updateDialogState) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      updateDialogState(() {
        selectedDate = selectedDate;
      });
    }
  }

  void _selectFoodDatePicker(BuildContext content) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      loadFoodList();
      loadListMember();
    }
  }

  Future<void> _captureImageFromCamera(StateSetter updateDialogState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
      onFileLoading: (FilePickerStatus status) {
        print(status);
      },
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageData = result.files.first.bytes;
        _fileName = result.files.first.name;
      });
      updateDialogState(() {
        _fileName = result.files.first.name;
      });
    } else {
      print("No file selected or result is null");
    }
  }

  Future<void> selectWeek(BuildContext context) async {
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2030);

    final DatePeriod? picked = await showDialog<DatePeriod>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn Tuần',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: dp.WeekPicker(
                    selectedDate: selectedDate,
                    onChanged: (datePeriod) {
                      Navigator.of(context).pop(datePeriod);
                    },
                    firstDate: firstDate,
                    lastDate: lastDate,
                    datePickerStyles: dp.DatePickerRangeStyles(
                      selectedPeriodLastDecoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadiusDirectional.only(
                          topEnd: Radius.circular(10.0),
                          bottomEnd: Radius.circular(10.0),
                        ),
                      ),
                      selectedPeriodStartDecoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(10.0),
                          bottomStart: Radius.circular(10.0),
                        ),
                      ),
                      selectedPeriodMiddleDecoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && picked.start != selectedDate) {
      setState(() {
        selectedDate = picked.start;
        loadListMember();
        loadFoodList();
      });
    }
  }

  Future<void> showAddDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Upload File'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('File name: $_fileName'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _captureImageFromCamera(setState),
                    child: Text('Pick Image from Gallery'),
                  ),
                  Padding(padding: const EdgeInsets.all(8)),
                  ElevatedButton(
                      onPressed: () => _showDatePicker(setState),
                      child: Text(
                          "Current Date: ${DateFormat("dd/MM/yyyy").format(selectedDate)}"))
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Approve'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food List'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Food List',
                    style: TextStyle(fontSize: 24),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.all(15),
                  //   child: FloatingActionButton(
                  //     child: Icon(Icons.add),
                  //     backgroundColor: Colors.green,
                  //     foregroundColor: Colors.white,
                  //     onPressed: () => showAddDialog(context),
                  //     mini: true,
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                  ),
                  MaterialButton(
                    onPressed: () => _selectFoodDatePicker(context),
                    color:
                        Theme.of(context).primaryColor, // Set the button color
                    textColor: Colors.white, // Set the text color
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                            'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)} ',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: foodList.length,
                itemBuilder: (context, index) {
                  return FoodItemCard(
                    listMember: listMember,
                    orderDate: DateFormat('dd/MM/yyyy').format(selectedDate),
                    foodItem: foodList[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int getWeekOfYear(DateTime date) {
  final DateTime firstDayOfYear = DateTime(date.year, 1, 1);
  final int daysDifference = date.difference(firstDayOfYear).inDays;
  final int weekNumber = (daysDifference / 7).ceil();
  return weekNumber;
}

class FoodItem {
  final String name;
  final String value;
  final int quantity;
  final int unitPrice;
  final String image;
  final String? note;

  FoodItem(
      {required this.name,
      required this.value,
      required this.quantity,
      required this.unitPrice,
      required this.image,
      this.note});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      value: json['value'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
      image: json['image'] ??
          '', // Provide a default image URL if none is available
    );
  }
}

void _submitOrder(BuildContext context, FoodItem item, String orderDate,
    String buyerName, int quantity, int totalPrice) async {
  try {
    print(item);
    print(buyerName);
    print(quantity);

    final response = await http.post(
      Uri.parse(
          '${dotenv.env['API_URL'] ?? ''}/api/payment/create-payment-link/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'orderDate': orderDate,
        'buyerName': buyerName,
        'orderCode': null,
        'name': item.value,
        'note': item.note ?? '',
        'quantity': quantity,
        'unitPrice': item.unitPrice,
        'totalPrice': totalPrice,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      print(responseData);
      // Extract the checkoutUrl from the response data
      final checkoutUrl = responseData['checkoutUrl'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment link created successfully')),
      );

      // Open the checkoutUrl in the current browser tab
      redirectToUrl(checkoutUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create payment link')),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}

void redirectToUrl(String url) {
  html.window.location.href = url;
}

Future<void> showOrderDialog(
  BuildContext context,
  FoodItem foodItem,
  String? _paymentUser,
  String? orderDate,
  List<DropdownMenuItem<String>> listMember,
) async {
  int totalPrice = foodItem.unitPrice;
  int quantity = 1;
  String messageError = '';

  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Order ${foodItem.value}'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "1. Order for:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    hint: const Text("Select order user..."),
                    value: _paymentUser,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? value) {
                      setState(() {
                        _paymentUser = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a user';
                      }
                      return null;
                    },
                    items: listMember,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "2. Quantity:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    onChanged: (value) => {
                      setState(() {
                        quantity = int.tryParse(value) ?? 0;
                        totalPrice = foodItem.unitPrice * quantity;
                      })
                    },
                    decoration:
                        const InputDecoration(labelText: "Enter your quantity"),
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Total: ${NumberFormat.currency(locale: 'vi-VN').format(totalPrice)}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Hãy kiểm tra thông tin thật kỹ trước khi Submit",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green[600]),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    messageError.isNotEmpty
                        ? "Error Message: $messageError"
                        : '',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red[400]),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.white),
                  backgroundColor: Colors.amber[500],
                ),
                onPressed: () {
                  print(_formKey.currentState!.validate());
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with the submission
                    _submitOrder(context, foodItem, orderDate ?? '',
                        _paymentUser ?? '', quantity, totalPrice);
                  } else {
                    // Form is invalid, show error message
                    setState(() {
                      messageError = 'Please correct the errors in the form';
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final List<DropdownMenuItem<String>> listMember;
  final String orderDate;
  FoodItemCard(
      {Key? key,
      required this.listMember,
      required this.orderDate,
      required this.foodItem})
      : super(key: key);

  String? _paymentUser = null;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image placeholder for the food item
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
              image: DecorationImage(
                image: NetworkImage("assets/food.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  foodItem.value,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Text(
                    //   'Quantity: ${foodItem.quantity}',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.grey[800],
                    //   ),
                    // ),
                    Text(
                      (NumberFormat.currency(locale: 'vi-VN'))
                          .format(foodItem.unitPrice)
                          .toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MaterialButton(
                      color: Theme.of(context)
                          .primaryColor, // Set the button color
                      textColor: Colors.white, // Set the text color
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onPressed: () => showOrderDialog(context, foodItem,
                          _paymentUser, orderDate, listMember),
                      child: Text('Order Now'),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

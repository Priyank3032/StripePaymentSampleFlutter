import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePyament extends StatefulWidget {
  const StripePyament({Key? key}) : super(key: key);

  @override
  _StripePyamentState createState() => _StripePyamentState();
}

class _StripePyamentState extends State<StripePyament> {
  var clientSecret;
  String strPay = "";

  bool visible = false;
  bool isLoading = false;

  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stripe Payment',
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (text) {
                if (text.length == 0) {
                  myController.clear();
                  setState(() {
                    strPay = "";
                  });
                } else {
                  strPay = text;
                  setState(() {
                    strPay;
                  });
                }
              },
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your amount',
              ),
              inputFormatters: [
                new FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: visible,
              child: CircularProgressIndicator()),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');

                visible = true;

                String getAmount = myController.text;
                int amount = int.parse(getAmount) * 100;
                payment_intents(amount, "usd", "card");
              },
              child: Text(
                'Pay $strPay'.toString(),
                style: TextStyle(fontSize: 15, color: Colors.white),
              )),
        ],
      ),
    );
  }

  Future<String> payment_intents(
      int? amount, String? currency, String? payment_method_types) async {
    setState(() {
      isLoading = true;
    });

    Map data = {
      'amount': amount.toString(),
      'currency': currency,
      'payment_method_types[]': payment_method_types
    };

    var url = 'https://api.stripe.com/v1/payment_intents';

    var body = data;
    String token = "Set your Token";

    var response = await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body);

    String str = response.body.toString();
    Map<String, dynamic> user = jsonDecode(str);

    clientSecret = user['client_secret'];

    initPaymentSheet();

    setState(() {
      isLoading = false;
    });
    return response.body.toString();
  }

  Future<void> initPaymentSheet() async {
    visible = false;

    try {
      // create some billingdetails
      final billingDetails = BillingDetails(
        name: 'Flutter Stripe',
        email: 'email@stripe.com',
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      ); // mocked data for tests

      // initialize the payment sheet

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Main params
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Flutter Stripe Store Demo',

          style: ThemeMode.dark,
          billingDetails: billingDetails,
        ),
      );
      confirmPayment();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> confirmPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment succesfully completed'),
        ),
      );
    } on Exception catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error from Stripe: ${e.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unforeseen error: ${e}'),
          ),
        );
      }
    }
  }
}

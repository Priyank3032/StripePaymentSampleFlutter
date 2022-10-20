import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment_sample/stripe_payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String stripePublishableKey = 'Set your Stripe Public Key';

  Stripe.publishableKey = stripePublishableKey;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stripe Payment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StripePyament(),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class GooglePayStripeScreen extends StatefulWidget {
  const GooglePayStripeScreen({Key? key}) : super(key: key);

  @override
  _GooglePayStripeScreenState createState() => _GooglePayStripeScreenState();
}

class _GooglePayStripeScreenState extends State<GooglePayStripeScreen> {
  Future<void> startGooglePay() async {
    try {
      // 1. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret();
      final clientSecret = response['clientSecret'];

      // 2.present google pay sheet
      await Stripe.instance.initGooglePay(GooglePayInitParams(
          merchantName: "Example Merchant Name", countryCode: 'us'));

      await Stripe.instance.presentGooglePay(
        PresentGooglePayParams(clientSecret: clientSecret),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Google Pay payment succesfully completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    final url = Uri.parse('$kApiUrl/create-payment-intent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': 'example@gmail.com',
        'currency': 'usd',
        'items': [
          {'id': 'id'}
        ],
        'request_three_d_secure': 'any',
      }),
    );
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
            width: 300,
            height: 75,
            child: GooglePayButton(
              onTap: () {
                startGooglePay();
              },
            )),
      ),
    );
  }
}

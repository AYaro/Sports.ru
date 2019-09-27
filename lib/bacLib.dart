import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class FirebaseComunicator extends StatelessWidget {
  String a;

  void testFunCall() async {
    HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'helloWorld');

    try {
      final HttpsCallableResult result = await callable.call();
      print(result.data);

    } on CloudFunctionsException catch (e) {
      print('caught firebase functions exception');
      print(e.code);
      print(e.message);
      print(e.details);
    } catch (e) {
      print('caught generic exception');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(a),
    );
  }
}


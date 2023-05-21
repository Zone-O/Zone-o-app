import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../network/informations.dart';

/// Function pointer needed to update the Home Page
Function? updatePage;

/// local variable telling if we wanted to logout
bool logout = false;

/// Navigation function -> Go to Home page
void goToHomePage(BuildContext context) {
  if (updatePage != null) {
    updatePage!();
  }
  context.go('/');
}

/// Utility function used to sort area data by name
void sortAreaDataList(String name) {
  if (name == '') {
    areaDataList.sort((a, b) {
      return b.updatedAt.toString().compareTo(a.updatedAt.toString());
    });
  } else {
    areaDataList.sort((a, b) {
      return b.name.compareTo(a.name);
    });
    areaDataList.sort((a, b) {
      return name.compareTo(a.name);
    });
  }
}

/// Update all the Flutter object and call the api
Future<void> updateAllFlutterObject() async {
  try {
    var response = await http.get(
      Uri.parse('http://$serverIp:8080/api/get/service'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${userInformation!.token}',
      },
    );

    response = await http.get(
      Uri.parse('http://$serverIp:8080/api/area'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${userInformation!.token}',
      },
    );

    response = await http.get(
      Uri.parse('http://$serverIp:8080/api/newsLetter'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${userInformation!.token}',
      },
    );

  } catch (err) {
    debugPrint(err.toString());
  }
}

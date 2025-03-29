import 'dart:convert';
import 'package:flutter/services.dart';
import 'model_spravka_helper.dart';

class SpravkaService {
  Future<List<Spravka>> loadSpravki() async {
    String data = await rootBundle.loadString('lib/assets/data/json/spravka.json');
    List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Spravka.fromJson(json)).toList();
  }
}
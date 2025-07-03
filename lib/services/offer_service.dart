import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer_model.dart';
import '../models/task_model.dart';

class OfferService {
  final String offerEndpoint = "http://10.0.2.2:8888/api/offers";

  Future<List<OfferResponse>> getOffersForTask(int taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$offerEndpoint/task/$taskId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OfferResponse.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<bool> placeOffer(Offer offer) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(offerEndpoint);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(offer.toJson()),
    );
    if (response.statusCode == 200) {
      print(response.body);
      return true;
    }
    print(response.body);
    return false;
  }

  Future<bool> acceptOffer(
      {required int taskId,
      required int offerId,
      required int taskPosterId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(
        '$offerEndpoint/$offerId/accept?taskId=$taskId&taskPosterId=$taskPosterId');
    final response = await http.put(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200;
  }

  Future<List<OfferResponse>> getOffersByRunner(int runnerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$offerEndpoint/runner/$runnerId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => OfferResponse.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<bool> cancelOffer(int offerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$offerEndpoint/$offerId/cancel');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200;
  }

  Future<List<TaskResponse>> getAcceptedOffersTasks(int runnerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$offerEndpoint/accepted/runner/$runnerId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TaskResponse.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  // Future<bool> updateOfferStatus(int offerId, OfferStatus status) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token');
  //   final url = Uri.parse('$offerEndpoint/$offerId/status?status=${status.toString().split('.').last}');
  //   final response = await http.put(url, headers: {
  //     'Content-Type': 'application/json',
  //     if (token != null) 'Authorization': 'Bearer $token',
  //   });
  //   return response.statusCode == 200;
  // }
}

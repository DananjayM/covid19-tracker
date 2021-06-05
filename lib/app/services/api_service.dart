import 'dart:convert';

import 'package:covid_api/app/services/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class APIService {
  final API api;

  APIService(this.api);
  Future<String> getAccessToken() async {
    final response = await http.post(api.tokenUri(),
        headers: {'Authorization': 'Basic ${api.apiKey}'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final accessToken = data['access_token'];
      if (accessToken != null) {
        return accessToken;
      }
    }
    print("${response.statusCode},${response.reasonPhrase}");
    throw response;
  }

  Future<int> getEndpointData(
      {@required String accessToken, @required Endpoint endpoint}) async {
    final uri = api.endpointUri(endpoint);
    final response =
        await http.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final Map<String, dynamic> endpointData = data[0];
        final String responseJsonKey = _responseJsonKeys[endpoint];
        final int result = endpointData[responseJsonKey];
        if (result != null) {
          return result;
        }
      }
    }
    print("${response.statusCode},${response.reasonPhrase}");
    throw response;
  }

  Future<String> getDateTime(
      {@required String accessToken, @required Endpoint endpoint}) async {
    final uri = api.endpointUri(endpoint);
    final response =
        await http.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final Map<String, dynamic> endpointData = data[0];
        final String result = endpointData['date'];
        if (result != null) {
          return result;
        }
      }
    }
    print("${response.statusCode},${response.reasonPhrase}");
    throw response;
  }

  static Map<Endpoint, String> _responseJsonKeys = {
    Endpoint.cases: 'cases',
    Endpoint.casesSuspected: 'data',
    Endpoint.casesConfirmed: 'data',
    Endpoint.deaths: 'data',
    Endpoint.recovered: 'data',
  };
}

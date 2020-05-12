import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const List<String> currenciesList = [
  'AUD',
  'BRL',
  'CAD',
  'CNY',
  'EUR',
  'GBP',
  'HKD',
  'IDR',
  'ILS',
  'INR',
  'JPY',
  'MXN',
  'NOK',
  'NZD',
  'PLN',
  'RON',
  'RUB',
  'SEK',
  'SGD',
  'USD',
  'ZAR'
];

const List<String> cryptoList = [
  'BTC',
  'ETH',
  'LTC',
];

class CoinData {
  String apiUrl = "https://rest.coinapi.io/v1";
  String apiKey;

  CoinData() {
    apiKey = DotEnv().env['COINAPI_APIKEY'];
  }

  Future<double> getConversionRate(
      {@required String crypto, @required String currency}) async {
    http.Response response =
        await http.get("$apiUrl/exchangerate/$crypto/$currency?apiKey=$apiKey");
    dynamic data = jsonDecode(response.body);
    return data['rate'];
  }
}

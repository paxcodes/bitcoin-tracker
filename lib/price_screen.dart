import 'dart:io' show Platform;
import 'package:bitcoin_ticker/conversion_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bitcoin_ticker/services/coin_data.dart' as coinData;

class PriceScreen extends StatefulWidget {
  final coinData.CoinData coinHelper = coinData.CoinData();

  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = 'USD';
  double conversionRate;

  DropdownButton androidDropdown() {
    return DropdownButton<String>(
      value: selectedCurrency,
      items: coinData.currenciesList
          .map((currency) => DropdownMenuItem(
                child: Text(currency),
                value: currency,
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedCurrency = value;
        });
      },
    );
  }

  Future<void> calculateConversionRates(String currency) async {
    double rate = await widget.coinHelper
        .getConversionRate(crypto: 'BTC', currency: currency);
    setState(() {
      selectedCurrency = currency;
      conversionRate = rate;
    });
  }

  NotificationListener iosPicker() {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        FixedExtentMetrics metrics = notification.metrics;
        calculateConversionRates(coinData.currenciesList[metrics.itemIndex]);
        return true;
      },
      child: CupertinoPicker(
        onSelectedItemChanged: (value) {},
        backgroundColor: Colors.lightBlue,
        itemExtent: 32,
        children:
            coinData.currenciesList.map((currency) => Text(currency)).toList(),
      ),
    );
  }

  String _printConversionRate() {
    if (conversionRate != null) {
      return "${conversionRate.toStringAsFixed(2)}";
    }
    return "?";
  }

  @override
  void initState() {
    super.initState();
    calculateConversionRates(selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConversionCard(
            currency: selectedCurrency,
            cryptocurrency: 'BTC',
            value: _printConversionRate(),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iosPicker() : androidDropdown(),
          ),
        ],
      ),
    );
  }
}

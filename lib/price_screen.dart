import 'dart:io' show Platform;
import 'package:bitcoin_ticker/components/conversion_card.dart';
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
  Map<String, double> conversionRates;

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
          setState(() {
            selectedCurrency = value;
            conversionRates = null;
          });
          calculateConversionRates(value);
        });
      },
    );
  }

  Future<void> calculateConversionRates(String currency) async {
    Map<String, double> rates = {};
    double rate;
    for (String crypto in coinData.cryptoList) {
      rate = await widget.coinHelper
          .getConversionRate(crypto: crypto, currency: currency);
      rates[crypto] = rate;
    }

    setState(() {
      conversionRates = rates;
    });
  }

  NotificationListener iosPicker() {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (ScrollEndNotification notification) {
        calculateConversionRates(selectedCurrency);
        return true;
      },
      child: CupertinoPicker(
        onSelectedItemChanged: (value) {
          setState(() {
            conversionRates = null;
            selectedCurrency = coinData.currenciesList[value];
          });
        },
        scrollController: FixedExtentScrollController(
            initialItem: coinData.currenciesList.indexOf(selectedCurrency)),
        backgroundColor: Colors.lightBlue,
        itemExtent: 32,
        children:
            coinData.currenciesList.map((currency) => Text(currency)).toList(),
      ),
    );
  }

  String _printConversionRate(String crypto) {
    if (conversionRates != null) {
      return "${conversionRates[crypto].toStringAsFixed(2)}";
    }
    return "?";
  }

  List<Widget> _getConversionCards() {
    return coinData.cryptoList
        .map<Widget>(
          (crypto) => ConversionCard(
            currency: selectedCurrency,
            cryptocurrency: crypto,
            value: _printConversionRate(crypto),
          ),
        )
        .toList();
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
        children: _getConversionCards() +
            <Widget>[
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

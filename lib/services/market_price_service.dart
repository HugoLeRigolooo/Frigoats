import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketPriceService {
  final String rawUrl = "https://raw.githubusercontent.com/HugoLeRigolooo/Frigoats/main/market_prices.json";
  Map<String, dynamic> _prices = {};

  Future<void> init() async {
    try {
      final response = await http.get(Uri.parse(rawUrl));
      if (response.statusCode == 200) {
        _prices = json.decode(response.body);
        print("Prix du marché chargés !");
      }
    } catch (e) {
      print("Impossible de charger les prix : $e");
    }
  }

  double getPrice(String itemName) {
    String search = itemName.toLowerCase().trim();
    if (_prices.containsKey(search)) {
      return _prices[search]['p'].toDouble();
    }
    return 0.0;
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_drawer.dart';
import 'package:intl/date_symbol_data_local.dart';

class ProduitsSaisonPage extends StatefulWidget {
  const ProduitsSaisonPage({super.key});

  @override
  State<ProduitsSaisonPage> createState() => _ProduitsSaisonPageState();
}

class _ProduitsSaisonPageState extends State<ProduitsSaisonPage> {
  List<dynamic> _produits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // On initialise les données linguistiques avant de charger les produits
    initializeDateFormatting('fr_FR', null).then((_) {
      _chargerProduitsDuMois();
    });
  }

  // Charge les données depuis le fichier JSON local (Source : Manger Bouger / ADEME)
  Future<void> _chargerProduitsDuMois() async {
    setState(() => _isLoading = true);

    try {
      // 1. Charger le fichier JSON des assets
      final String response = await rootBundle.loadString('assets/data/saisons.json');
      final List<dynamic> tousLesProduits = json.decode(response);

      // 2. Récupérer le mois actuel (1 pour Janvier, 2 pour Février...)
      final int moisActuel = DateTime.now().month;

      setState(() {
        // 3. Filtrer uniquement les produits disponibles ce mois-ci
        _produits = tousLesProduits.where((p) {
          final List moisDispo = p['mois'];
          return moisDispo.contains(moisActuel);
        }).toList();
        
        // Tri alphabétique
        _produits.sort((a, b) => a['nom'].compareTo(b['nom']));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur lors du chargement des saisons : $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupération du nom du mois pour l'affichage
    String nomMois = DateFormat('MMMM', 'fr_FR').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Produits de saison',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_open_rounded, color: Colors.orangeAccent, size: 30),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: CustomDrawer(onPlatAjoute: (p) {}),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(nomMois),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _produits.length,
                    itemBuilder: (context, index) => _buildProduitCard(_produits[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(String mois) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              "En ce mois de ${mois.toLowerCase()}, privilégiez ces produits :",
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 75, 74, 74)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProduitCard(dynamic produit) {
    String nom = produit['nom'];
    String type = produit['type'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: type == 'fruit' ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/icons/fruit-legume.png',
              width: 30,
              height: 30,
              color: type == 'fruit' ? Colors.green : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              nom,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
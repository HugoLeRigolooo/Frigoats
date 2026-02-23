import 'package:flutter/material.dart';
import '../widgets/custom_drawer.dart';
import '../models/AlimentModel.dart';
import '../services/database_service.dart';

class ListeCoursesPage extends StatefulWidget {
  const ListeCoursesPage({super.key});

  @override
  State<ListeCoursesPage> createState() => _ListeCoursesPageState();
}

class _ListeCoursesPageState extends State<ListeCoursesPage> {
  List<Aliment> _mesAliments = [];
  bool _isLoading = true;

  final TextEditingController _alimentController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  String _selectedUnite = "kg";
  final List<String> _unites = ["kg", "g", "L", "ml", "paquet", "unité"];

  @override
  void initState() {
    super.initState();
    _refreshAliments();
  }

  Future<void> _refreshAliments() async {
    setState(() => _isLoading = true);
    final data = await DatabaseService.instance.readAllAlimentsListeCourses();
    setState(() {
      _mesAliments = data;
      _isLoading = false;
    });
  }

  Future<void> _ajouterAliment() async {
    if (_alimentController.text.isNotEmpty) {
      final nouvelAliment = Aliment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nom: _alimentController.text.trim(),
        quantite: int.tryParse(_quantiteController.text) ?? 1,
        unite: _selectedUnite,
        datePeremption: null, // Pas de péremption nécessaire pour les courses
      );

      await DatabaseService.instance.createAlimentListeCourses(nouvelAliment);
      
      _alimentController.clear();
      _quantiteController.clear();
      
      if (mounted) Navigator.pop(context);
      _refreshAliments();
    }
  }

  void _afficherDialogueAjout() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Ajouter aux courses"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _alimentController,
                decoration: InputDecoration(
                  hintText: "Nom de l'aliment",
                  prefixIcon: const Icon(Icons.shopping_cart, color: Colors.orangeAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _quantiteController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Qté",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnite,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      items: _unites.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) => setDialogState(() => _selectedUnite = val!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: _ajouterAliment,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              child: const Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Ma liste de courses', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Builder(builder: (context) => IconButton(
            icon: const Icon(Icons.menu_open_rounded, color: Colors.orangeAccent, size: 30),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          )),
        ],
      ),
      endDrawer: CustomDrawer(onPlatAjoute: (p) {}),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
        : _mesAliments.isEmpty 
            ? const Center(child: Text("Votre liste est vide 🛒", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _mesAliments.length,
                itemBuilder: (context, index) => _buildAlimentCard(_mesAliments[index]),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: _afficherDialogueAjout,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAlimentCard(Aliment aliment) {
    String assetPath = 'assets/icons/${aliment.nom.toLowerCase().trim()}.png';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 15, right: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
          child: Image.asset(
            assetPath,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, color: Colors.orangeAccent),
          ),
        ),
        title: Text(aliment.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${aliment.quantite} ${aliment.unite}", style: const TextStyle(color: Colors.orangeAccent)),
        trailing: IconButton(
          icon: const Icon(Icons.add_home_work_rounded, color: Colors.green, size: 28),
          onPressed: () => _transfererAuFrigo(aliment),
        ),
      ),
    );
  }

  Future<void> _transfererAuFrigo(Aliment aliment) async {
    final alimentFrigo = Aliment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nom: aliment.nom,
      quantite: aliment.quantite,
      unite: aliment.unite,
    );

    await DatabaseService.instance.createAliment(alimentFrigo);
    await DatabaseService.instance.deleteAlimentListeCourses(aliment.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${aliment.nom} ajouté au frigo !"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
    _refreshAliments();
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_drawer.dart';
import '../models/AlimentModel.dart';
import '../services/database_service.dart';

class FrigoPage extends StatefulWidget {
  const FrigoPage({super.key});

  @override
  State<FrigoPage> createState() => _FrigoPageState();
}

class _FrigoPageState extends State<FrigoPage> {
  List<Aliment> _mesAliments = [];
  bool _isLoading = true;

  // Contrôleurs pour le dialogue d'ajout
  final TextEditingController _alimentController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedUnite = "kg";
  final List<String> _unites = ["kg", "g", "L", "ml", "paquet", "unité"];

  @override
  void initState() {
    super.initState();
    _refreshAliments();
  }

  // Charge les aliments depuis la BDD SQLite
  Future<void> _refreshAliments() async {
    setState(() => _isLoading = true);
    final data = await DatabaseService.instance.readAllAliments();
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
        datePeremption: _selectedDate,
      );

      await DatabaseService.instance.createAliment(nouvelAliment);
      
      _alimentController.clear();
      _quantiteController.clear();
      _selectedDate = null;
      
      if (mounted) Navigator.pop(context);
      _refreshAliments();
    }
  }

  Future<void> _supprimerAliment(String id) async {
    await DatabaseService.instance.deleteAliment(id);
    _refreshAliments();
  }

  void _afficherDialogueAjout() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Ajouter au frigo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _alimentController,
                  decoration: InputDecoration(
                    hintText: "Nom de l'aliment (ex: Tomates)",
                    prefixIcon: const Icon(Icons.shopping_basket, color: Colors.orangeAccent),
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
                const SizedBox(height: 15),
                ListTile(
                  tileColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  leading: const Icon(Icons.calendar_month, color: Colors.orangeAccent),
                  title: Text(_selectedDate == null 
                      ? "Date de péremption" 
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setDialogState(() => _selectedDate = picked);
                  },
                ),
              ],
            ),
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
        title: const Text('Mon Frigo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            ? const Center(child: Text("Votre frigo est vide 🧊"))
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
    
    bool estUrgent = false;
    if (aliment.datePeremption != null) {
      final difference = aliment.datePeremption!.difference(DateTime.now()).inDays;
      if (difference <= 2) estUrgent = true;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 15, right: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: estUrgent ? Colors.redAccent.withOpacity(0.5) : Colors.grey.shade100,
          width: estUrgent ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: estUrgent ? Colors.red.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            assetPath,
            errorBuilder: (context, error, stackTrace) => 
                Icon(Icons.restaurant, color: estUrgent ? Colors.redAccent : Colors.orangeAccent),
          ),
        ),
        title: Text(
          aliment.nom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${aliment.quantite} ${aliment.unite}", 
                style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600)),
            if (aliment.datePeremption != null)
              Text(
                "Périme le : ${DateFormat('dd/MM/yyyy').format(aliment.datePeremption!)}",
                style: TextStyle(
                  color: estUrgent ? Colors.redAccent : Colors.grey,
                  fontSize: 12,
                  fontWeight: estUrgent ? FontWeight.bold : FontWeight.normal
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _supprimerAliment(aliment.id),
        ),
      ),
    );
  }
}
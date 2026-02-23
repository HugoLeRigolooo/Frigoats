import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/PlatsModel.dart';

class AddPlatDialog extends StatefulWidget {
  const AddPlatDialog({super.key});

  @override
  State<AddPlatDialog> createState() => _AddPlatDialogState();
}

class _AddPlatDialogState extends State<AddPlatDialog> {
  final TextEditingController _platController = TextEditingController();
  int _duree = 15;
  int _prix = 5;
  String _type = "plat";
  File? _imageGallerie;

  final List<String> _ingredients = [
    // --- LÉGUMES & TUBERCULES ---
    "ail", "oignon", "échalote", "cébette", "tomate", "poivron", "piment", "carotte", 
    "courgette", "aubergine", "pomme de terre", "patate douce", "champignon", 
    "haricot vert", "brocoli", "chou-fleur", "chou", "épinard", "laitue", "roquette", 
    "mâche", "endive", "avocat", "poireau", "céleri", "concombre", "petit pois", 
    "maïs", "asperge", "radis", "citrouille", "potiron", "butternut", "panais", 
    "topinambour", "artichaut", "fève", "betterave", "fenouil", "navet", "rutabaga", 
    "kale", "cornichon", "pousse de bambou",

    // --- FRUITS ---
    "citron", "orange", "clémentine", "mandarine", "pamplemousse", "fraise", 
    "framboise", "myrtille", "mûre", "groseille", "banane", "pomme", "poire", 
    "raisin", "melon", "pastèque", "ananas", "kiwi", "mangue", "papaye", 
    "fruit de la passion", "cerise", "pêche", "nectarine", "abricot", "prune", 
    "figue", "rhubarbe", "grenade", "datte", "pruneau", "canneberge", "litchi", 
    "goyave", "kaki",

    // --- VIANDES & CHARCUTERIE ---
    "poulet", "boeuf", "porc", "agneau", "canard", "dinde", "lapin", "veau", 
    "lardons", "bacon", "jambon", "chorizo", "salami", "saucisse", "merguez", 
    "chipolata", "mortadelle", "pancetta", "viande des grisons", "pâté", "rillettes",

    // --- POISSONS & CRUSTACÉS ---
    "saumon", "thon", "cabillaud", "colin", "dorade", "bar", "sardine", "maquereau", 
    "truite", "crevettes", "gambas", "moules", "huîtres", "noix de Saint-Jacques", 
    "calamar", "poulpe", "surimi", "anchois", "crabe", "homard", "langouste", "écrevisse", 
    "morue", "églefin",

    // --- PRODUITS LAITIERS & OEUFS ---
    "oeuf", "lait", "beurre", "crème fraîche", "yaourt", "fromage blanc", "skyr", 
    "mascarpone", "ricotta", "fromage râpé", "emmental", "comté", "parmesan", 
    "mozzarella", "feta", "chèvre", "camembert", "roquefort", "reblochon", "raclette", 
    "mimolette", "cantal", "beaufort", "burrata", "gorgonzola", "cheddar", "brie",

    // --- ALTERNATIVES VÉGÉTALES ---
    "tofu", "tempeh", "seitan", "lait végétal", "steak végétal",

    // --- ÉPICERIE SALÉE ---
    "riz", "pâtes", "quinoa", "semoule", "boulgour", "lentilles", "pois chiches", 
    "haricots", "pois cassés", "farine", "chapelure", "panko", "polenta", "gnocchi",

    // --- ÉPICES & HERBES ---
    "sel", "poivre", "baies roses", "paprika", "cumin", "curcuma", "curry", 
    "coriandre", "persil", "basilic", "thym", "romarin", "origan", "gingembre", 
    "cannelle", "clou de girofle", "noix de muscade", "menthe", "ciboulette", 
    "aneth", "estragon", "sauge", "piment d'Espelette", "herbes de Provence", 
    "ras el hanout", "garam masala", "safran", "sumac",

    // --- CONDIMENTS & SAUCES ---
    "huile", "vinaigre", "moutarde", "mayonnaise", "ketchup", "sauce soja", 
    "nuoc-mâm", "sauce tomate", "concentré de tomate", "pesto", "lait de coco", 
    "bouillon", "câpres", "olives", "tapenade", "harissa", "tahini", "beurre de cacahuète",

    // --- ÉPICERIE SUCRÉE ---
    "sucre", "miel", "sirop d'érable", "sirop d'agave", "chocolat", "pépites de chocolat", 
    "cacao", "levure", "vanille", "amande", "noisette", "noix", "pistache", "noix de coco", 
    "sésame", "graines", "confiture", "pâte à tartiner", "pain", "tortilla", "pain pita", 
    "biscotte", "flocons d'avoine", "muesli",

    // --- BOISSONS ---
    "eau", "jus d'orange", "jus de pomme", "café", "thé", "tisane", "vin", "bière", 
    "cidre", "rhum", "vodka"
  ];
  final List<String> _selectedIngredients = [];

  @override
  void dispose() {
    _platController.dispose();
    super.dispose();
  }

  // --- STYLE : Décoration des champs ---
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orangeAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                "Nouvelle Recette",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Section Photo
              GestureDetector(
                onTap: _pickImageGallerie,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: _imageGallerie != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_imageGallerie!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_rounded, size: 40, color: Colors.orangeAccent),
                            Text("Ajouter une photo", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Nom de la recette
              TextField(
                controller: _platController,
                decoration: _inputStyle("Nom du plat", Icons.restaurant_menu),
              ),
              const SizedBox(height: 15),

              // Type de plat (Chips de sélection)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["entrée", "plat", "dessert"].map((t) {
                  bool isSelected = _type == t;
                  return ChoiceChip(
                    label: Text(t[0].toUpperCase() + t.substring(1)),
                    selected: isSelected,
                    selectedColor: Colors.orangeAccent,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (val) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),

              // Compteurs (Durée & Prix)
              Row(
                children: [
                  Expanded(child: _buildCounterCard("⏳ Durée", _duree, "min", (v) => setState(() => _duree = v))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildCounterCard("💰 Prix", _prix, "€", (v) => setState(() => _prix = v))),
                ],
              ),
              const SizedBox(height: 20),

              // Ingrédients avec Autocomplete
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _ingredients.where((ingredient) =>
                      ingredient.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  setState(() {
                    if (!_selectedIngredients.contains(selection)) {
                      _selectedIngredients.add(selection);
                    }
                  });
                  // On ne vide pas manuellement ici pour éviter le conflit de focus
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: _inputStyle("Ingrédients", Icons.search),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          if (!_selectedIngredients.contains(value.trim())) {
                            _selectedIngredients.add(value.trim());
                          }
                        });
                        textEditingController.clear(); // On vide le champ
                        onFieldSubmitted(); // On notifie l'Autocomplete que c'est fini
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 10),

              // Badges Ingrédients
              Wrap(
                spacing: 8.0,
                children: _selectedIngredients.map((ing) => Chip(
                  backgroundColor: Colors.orange.shade50,
                  label: Text(ing, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.cancel, size: 16, color: Colors.orange),
                  onDeleted: () => setState(() => _selectedIngredients.remove(ing)),
                )).toList(),
              ),
              const SizedBox(height: 30),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        if (_platController.text.isNotEmpty) {
                          final nouveauPlat = PlatsModel(
                            name: _platController.text,
                            duration: "${_duree}min",
                            type: _type,
                            photo: _imageGallerie != null ? _imageGallerie!.path : "",
                            prix: _prix.toDouble(),
                            ingredients: _selectedIngredients,
                          );
                          Navigator.of(context).pop(nouveauPlat);
                        }
                      },
                      child: const Text("Ajouter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard(String title, int value, String unit, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: value > 1 ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "$value$unit",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () => onChanged(value + 1),
                  icon: const Icon(Icons.add_circle_outline, size: 18, color: Colors.orangeAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _pickImageGallerie() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imageGallerie = File(image.path));
  }
}
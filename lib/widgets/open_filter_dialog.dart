import 'package:flutter/material.dart';

class OpenFilterDialog extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  const OpenFilterDialog({super.key, this.initialFilters});

  @override
  State<OpenFilterDialog> createState() => _OpenFilterDialogState();
}

class _OpenFilterDialogState extends State<OpenFilterDialog> {
  // Définition des valeurs par défaut
  static const String _defaultType = 'Tous';
  static const double _defaultPrix = 50.0;
  static const double _defaultDuree = 60.0;

  late String _selectedType;
  late double _maxPrix;
  late double _maxDuree;

  final List<String> _types = ['Tous', 'Entrée', 'Plat', 'Dessert'];

  @override
  void initState() {
    super.initState();
    // On initialise avec les filtres actuels ou les valeurs par défaut
    _selectedType = widget.initialFilters?['type'] ?? _defaultType;
    _maxPrix = widget.initialFilters?['prix'] ?? _defaultPrix;
    _maxDuree = widget.initialFilters?['duree'] ?? _defaultDuree;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Filtrer les recettes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text("Type de plat", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _types.map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: _selectedType == type,
                  selectedColor: Colors.orangeAccent.withOpacity(0.3),
                  onSelected: (val) => setState(() => _selectedType = type),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            Text("Prix maximum : ${_maxPrix.toInt()} €", style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _maxPrix,
              min: 0, max: 50,
              activeColor: Colors.orangeAccent,
              onChanged: (val) => setState(() => _maxPrix = val),
            ),
            
            const SizedBox(height: 10),
            Text("Durée max : ${_maxDuree.toInt()} min", style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _maxDuree,
              min: 0, max: 60,
              activeColor: Colors.orangeAccent,
              onChanged: (val) => setState(() => _maxDuree = val),
            ),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Réinitialiser au lieu de simplement Annuler
                TextButton(
                  onPressed: () {
                    // On renvoie les valeurs par défaut à la HomePage
                    Navigator.pop(context, {
                      'type': _defaultType,
                      'prix': _defaultPrix,
                      'duree': _defaultDuree,
                    });
                  },
                  child: const Text("Réinitialiser"),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'type': _selectedType,
                          'prix': _maxPrix,
                          'duree': _maxDuree,
                        });
                      },
                      child: const Text("Appliquer", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
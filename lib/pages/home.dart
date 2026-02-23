import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mon_application/pages/plat_detail_page.dart';
import '../models/CategoryModel.dart';
import '../models/PlatsModel.dart';
import '../services/database_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/add_plat_dialog.dart';
import '../widgets/open_filter_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  
  List<CategoryModel> categories = [];
  List<PlatsModel> plats = [];
  List<PlatsModel> filteredPlats = [];
  
  bool _isLoading = true;
  bool _isSelectionMode = false;
  List<int> _selectedIds = [];

  // Stockage des filtres actuels
  Map<String, dynamic> _currentFilters = {
    'type': 'Tous',
    'prix': 50.0,
    'duree': 60.0,
  };

  @override
  void initState() {
    super.initState();
    categories = CategoryModel.getCategories();
    _refreshPlats();
  }

  Future<void> _refreshPlats() async {
    setState(() => _isLoading = true);
    final data = await DatabaseService.instance.readAllPlats();
    setState(() {
      plats = data;
      _applyFilters(); // On applique les filtres sur les nouvelles données
      _isLoading = false;
    });
  }

  // Logique combinée : Recherche + Filtres (Type, Prix, Durée)
  void _applyFilters() {
    setState(() {
      filteredPlats = plats.where((plat) {
        // 1. Recherche par nom
        final matchesName = plat.name.toLowerCase().contains(_searchController.text.toLowerCase());

        // 2. Filtre par type (CORRIGÉ)
        // On compare tout en minuscules et sans espaces superflus
        final String filterType = _currentFilters['type'].toString().trim().toLowerCase();
        final String platType = plat.type.trim().toLowerCase();
        
        final matchesType = filterType == 'tous' || platType == filterType;

        // 3. Filtre par prix
        final matchesPrix = plat.prix <= _currentFilters['prix'];

        // 4. Filtre par durée
        final intMinutes = int.tryParse(plat.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final matchesDuree = intMinutes <= _currentFilters['duree'];

        return matchesName && matchesType && matchesPrix && matchesDuree;
      }).toList();
    });
  }

  Future<void> _ouvrirDialogueAjout() async {
    final nouveauPlat = await showDialog<PlatsModel>(
      context: context,
      builder: (context) => const AddPlatDialog(),
    );

    if (nouveauPlat != null) {
      await DatabaseService.instance.createPlat(nouveauPlat);
      _refreshPlats();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nouvelle recette enregistrée !")),
      );
    }
  }

  Future<void> _deleteSelectedPlats() async {
    if (_selectedIds.isNotEmpty) {
      await DatabaseService.instance.deleteMultiplePlats(_selectedIds);
      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
      await _refreshPlats();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Recettes supprimées"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: _buildAppBar(),
      endDrawer: CustomDrawer(
        onPlatAjoute: (nouveauPlat) async {
          await DatabaseService.instance.createPlat(nouveauPlat);
          _refreshPlats();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _searchField(),
                if (filteredPlats.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("Aucune recette ne correspond... 🍳", 
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                  )
                else
                  ...categories.map((category) {
                    final sectionList = filteredPlats.where((p) => p.type == category.type).toList();
                    if (sectionList.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25, top: 20, bottom: 10),
                          child: Center(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildGrid(sectionList),
                        const SizedBox(height: 20),
                        if (category != categories.last)
                          const Divider(height: 30, thickness: 1, indent: 50, endIndent: 50)
                      ],
                    );
                  }),
                const SizedBox(height: 100),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: _ouvrirDialogueAjout,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        _isSelectionMode ? "${_selectedIds.length} sélectionné(s)" : 'Mes recettes',
        style: TextStyle(
          color: _isSelectionMode ? Colors.orangeAccent : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      leading: _isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () => setState(() {
                _isSelectionMode = false;
                _selectedIds.clear();
              }),
            )
          : null,
      actions: [
        if (_isSelectionMode)
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
            onPressed: _deleteSelectedPlats,
          )
        else
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(Icons.menu_open_rounded, color: Colors.orangeAccent, size: 30),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => _applyFilters(),
        decoration: InputDecoration(
          hintText: 'Rechercher une recette...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.orangeAccent),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.filter_list_rounded, 
              color: _hasActiveFilters() ? Colors.green : Colors.orangeAccent, 
              size: 30
            ),
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => OpenFilterDialog(initialFilters: _currentFilters),
              );

              if (result != null) {
                _currentFilters = result;
                _applyFilters();
              }
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // Vérifie si des filtres (hors "Tous") sont actifs pour changer la couleur de l'icône
  bool _hasActiveFilters() {
    return _currentFilters['type'] != 'Tous' || 
           _currentFilters['prix'] < 100.0 || 
           _currentFilters['duree'] < 180.0;
  }

  Widget _buildGrid(List<PlatsModel> list) {
    return GridView.builder(
      itemCount: list.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final plat = list[index];
        final isSelected = _selectedIds.contains(plat.id);

        return GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                if (plat.id != null) _selectedIds.add(plat.id!);
              });
            }
          },
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(plat.id);
                  if (_selectedIds.isEmpty) _isSelectionMode = false;
                } else {
                  _selectedIds.add(plat.id!);
                }
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlatDetailPage(plat: plat)),
              );
            }
          },
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.orangeAccent : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        child: plat.photo.startsWith('assets/')
                            ? Image.asset(plat.photo, fit: BoxFit.cover, width: double.infinity)
                            : Image.file(File(plat.photo), 
                                fit: BoxFit.cover, 
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.broken_image, color: Color.fromARGB(255, 245, 197, 135), size: 70))),
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(plat.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${plat.prix} €", 
                                    style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(plat.duration, 
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSelectionMode)
                Positioned(
                  top: 10, right: 10,
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? Colors.orangeAccent : Colors.white.withOpacity(0.8),
                    size: 26,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
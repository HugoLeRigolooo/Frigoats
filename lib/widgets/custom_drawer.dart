import 'package:flutter/material.dart';
import 'package:mon_application/pages/frigo_page.dart';
import 'package:mon_application/pages/home.dart';
import 'package:mon_application/widgets/minuteur_page.dart';
import '../models/PlatsModel.dart';
import 'package:mon_application/pages/liste_courses_page.dart';
import 'package:mon_application/pages/produit_saison_page.dart';

class CustomDrawer extends StatelessWidget {
  final Function(PlatsModel) onPlatAjoute;

  const CustomDrawer({super.key, required this.onPlatAjoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // On donne un bord arrondi au Drawer lui-même
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // En-tête stylisé avec dégradé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orangeAccent, Color(0xFFFFCC80)],
              ),
            ),
            child: Column(
              children: [
                // Logo avec ombre
                // En-tête stylisé sans le rond derrière le logo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orangeAccent, Color(0xFFFFCC80)],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo affiché directement
                      SizedBox(
                        height: 80,
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.restaurant, color: Colors.white, size: 60),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Frigoats',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Cuisinez avec ce que vous avez',
                        style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Liste des options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.account_circle_outlined,
                    title: 'Se connecter',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(indent: 20, endIndent: 20),
                  _buildDrawerItem(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Mes recettes',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                       );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.kitchen_outlined,
                    title: 'Mon frigo',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FrigoPage()),
                       );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Ma liste de courses',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListeCoursesPage()),
                       );
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20),
                  _buildDrawerItem(
                    icon: Icons.timer_outlined,
                    title: 'Minuteur',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MinuteurPage(dureeInitiale: 5)),
                       );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Produits de saison',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProduitsSaisonPage()),
                       );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Version 1.0.2',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // Widget personnalisé pour les éléments du menu
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.orangeAccent, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      hoverColor: Colors.orange.shade100,
    );
  }
}
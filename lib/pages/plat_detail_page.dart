import 'package:flutter/material.dart';
import '../models/PlatsModel.dart';
import 'dart:io';

class PlatDetailPage extends StatelessWidget {
  final PlatsModel plat;

  const PlatDetailPage({super.key, required this.plat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            backgroundColor: Colors.orangeAccent,
            flexibleSpace: FlexibleSpaceBar(
              background: plat.photo.isEmpty
                  ? Container(
                      color: Colors.orange.shade100,
                      child: const Icon(Icons.restaurant_menu, size: 80, color: Colors.orangeAccent),
                    )
                  : plat.photo.startsWith('assets/')
                      ? Image.asset(plat.photo, fit: BoxFit.cover)
                      : Image.file(File(plat.photo), fit: BoxFit.cover, 
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                          ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          plat.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "${plat.prix}€",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Text(plat.duration, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Ingrédients",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: plat.ingredients.map((ing) {
                      return Chip(
                        backgroundColor: Colors.orange.shade50,
                        label: Text(ing.trim()),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
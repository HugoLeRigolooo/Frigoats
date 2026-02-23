class Aliment {
  final String id;
  final String nom;
  final int quantite;
  final String unite;
  final DateTime? datePeremption;

  Aliment({
    required this.id,
    required this.nom,
    required this.quantite,
    required this.unite,
    this.datePeremption,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'quantite': quantite,
      'unite': unite,
      'datePeremption': datePeremption?.toIso8601String(),
    };
  }

  factory Aliment.fromMap(Map<String, dynamic> map) {
    return Aliment(
      id: map['id'],
      nom: map['nom'],
      quantite: map['quantite'],
      unite: map['unite'],
      datePeremption: map['datePeremption'] != null 
          ? DateTime.parse(map['datePeremption']) 
          : null,
    );
  }
}
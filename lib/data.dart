import 'package:cloud_firestore/cloud_firestore.dart';

class Consulta {
  final String id;
  final String name;
  final String telephone;
  final DateTime date;
  final String title;
  final String description;

  Consulta({
    required this.id,
    required this.name,
    required this.telephone,
    required this.date,
    required this.title,
    required this.description,
  });

  // Método para converter o documento do Firestore em um objeto Consulta
  factory Consulta.fromFirestore(Map<String, dynamic> data, String id) {
    return Consulta(
      id: id,
      name: data['name'] ?? '',
      telephone: data['telephone'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
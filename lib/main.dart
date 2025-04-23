import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // Pour la conversion des données en JSON

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulaire de Demande de Congé',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyFormPage(title: 'Demande de Congé'),
    );
  }
}

class MyFormPage extends StatefulWidget {
  const MyFormPage({super.key, required this.title});

  final String title;

  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  // Clé pour identifier le formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Variable pour le type de congé
  String _leaveType = 'vacation';

  // Méthode pour envoyer la demande de congé à l'API
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Créez un objet JSON avec les données du formulaire
      Map<String, dynamic> formData = {
        'username': _nameController.text,
        'email': _emailController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'leaveType': _leaveType,
      };

      // Envoi de la requête HTTP POST à l'API Spring Boot
      final response = await http.post(
        Uri.parse('http://votre-backend-api-url/demande-conge'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        // Si la requête a réussi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande de congé envoyée avec succès!')),
        );
      } else {
        // Si la requête a échoué
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi de la demande')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs quand le widget est supprimé
    _nameController.dispose();
    _emailController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Champ Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  hintText: 'Entrez votre nom',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Entrez votre email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ Date de début
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de début',
                  hintText: 'Entrez la date de début',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une date de début';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ Date de fin
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de fin',
                  hintText: 'Entrez la date de fin',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une date de fin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélection du type de congé
              const Text('Type de congé:'),
              DropdownButton<String>(
                value: _leaveType,
                onChanged: (String? newValue) {
                  setState(() {
                    _leaveType = newValue!;
                  });
                },
                items: <String>['vacation', 'sick', 'maternity']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Envoyer la demande'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

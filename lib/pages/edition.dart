import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/utils.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  EditPageState createState() => EditPageState();
}

class EditPageState extends State<EditPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Task? task = ModalRoute.of(context)?.settings.arguments as Task?;
    if (task != null) {
      titleController.text = task.title;
      descriptionController.text = task.description;
      _selectedDate = task.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une tâche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Titre',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '*',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Entrez le titre de la tâche',
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Text(
                  'Description',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '*',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Entrez la description de la tâche',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Text('Choisir une date'),
                ),
                const SizedBox(width: 16),
                Text(
                  _selectedDate != null
                      ? 'Date : ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                      : 'Aucune Date Choisie',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final description = descriptionController.text;

                // Vérifier la validité des champs
                if (title.isNotEmpty && description.isNotEmpty) {
                  if (!_isValidInput(title) || !_isValidInput(description)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez entrer uniquement des lettres et des chiffres.'),
                      ),
                    );
                    return; // Ne pas soumettre le formulaire
                  }

                  final utils = Provider.of<Utils>(context, listen: false);
                  final task = ModalRoute.of(context)?.settings.arguments as Task?;

                  if (task == null) {
                    utils.addTask(title, description, _selectedDate);
                  } else {
                    utils.updateTask(task, title, description, _selectedDate);
                  }

                  Navigator.pop(context); // Retourner à la page précédente
                } else {
                  // Afficher un message d'erreur si les champs obligatoires sont vides
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Erreur'),
                      content: const Text('Veuillez remplir tous les champs obligatoires.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour valider l'entrée (lettres, chiffres et espaces uniquement)
  bool _isValidInput(String input) {
    final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
    return regex.hasMatch(input);
  }
}
  
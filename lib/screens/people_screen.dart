import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/person.dart';
import '../services/person_service.dart'; // Import PersonService

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final List<Person> _people = [];
  final ImagePicker _picker = ImagePicker();
  final PersonService _personService = PersonService(); // Initialize PersonService

  @override
  void initState() {
    super.initState();
    _fetchPeople(); // Fetch people on screen load
  }

  // Fetch people from the backend
  Future<void> _fetchPeople() async {
    try {
      List<Person> people = await _personService.getAllPeople();
      setState(() {
        _people.addAll(people);
      });
    } catch (e) {
      // Handle error
      print('Error fetching people: $e');
    }
  }

  // Method to add a new person to the backend
  Future<void> _addPerson(String name, String relation, String imagePath) async {
    final person = Person(
      name: name,
      relation: relation,
      imagePath: imagePath, // Assuming `profilePhotoUrl` is the field for imagePath in Person model
    );

    try {
      await _personService.addPerson(person); // Add to backend
      setState(() {
        _people.add(person); // Add to the list locally after backend call succeeds
      });
    } catch (e) {
      // Handle error
      print('Error adding person: $e');
    }
  }

  // Method to allow user to pick an image and save it to local storage
  Future<void> _pickAndSaveImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String savedPath = '${appDir.path}/$fileName';
      final File localFile = await File(pickedFile.path).copy(savedPath);

      _showAddPersonDialog(localFile.path); // Pass the image path to the dialog
    }
  }

  // Method to show a dialog for adding new person details
  void _showAddPersonDialog(String imagePath) {
    String name = '';
    String relation = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add new person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Relationship'),
                onChanged: (value) {
                  relation = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && relation.isNotEmpty) {
                  _addPerson(name, relation, imagePath); 
                }
                Navigator.of(context).pop();
              },
              child: Text('add'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People To Remember'),
      ),
      body: _people.isEmpty? const Center(child: Text('No entries yet.'))
      :ListView(
        padding: const EdgeInsets.all(10),
        children: [
          ..._people.map((person) => _buildPersonCard(person)).toList(),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _pickAndSaveImage, // Pick image from the gallery
          child: const Text('Add New Person'),
        ),
      ),
    );
  }

  Widget _buildPersonCard(Person person) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: person.imagePath.startsWith('assets')
              ? AssetImage(person.imagePath) as ImageProvider
              : FileImage(File(person.imagePath)),
        ),
        title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(person.relation),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            // Action for the phone button
          },
        ),
      ),
    );
  }
}

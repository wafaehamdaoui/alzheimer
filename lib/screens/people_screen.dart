import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:path/path.dart' as path;
import '../models/person.dart';
import '../services/person_service.dart'; 
class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final List<Person> _people = [];
  bool _isLoading = true;
  final Logger _logger = Logger();
  final ImagePicker _picker = ImagePicker();
  final PersonService _personService = PersonService(); 

  @override
  void initState() {
    super.initState();
    _fetchPeople(); 
  }

  // Fetch people from the backend
  Future<void> _fetchPeople() async {
    try {
      List<Person> people = await _personService.getAllPeople();
      setState(() {
        _people.addAll(people);
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      if (this.mounted) {
        setState(() {
          setState(() {
            _isLoading = false;
          });
        });
      }
      _logger.e('Error fetching tasks: $e', e, stackTrace);
    }
  }

  Future<int> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id')??0; 
  } 

  // Method to add a new person to the backend
  Future<void> _addPerson(String name, String relation, String phone, String imagePath) async {
    final userId = await getUserID();
    final person = Person(
      name: name,
      relation: relation,
      phone: phone,
      imagePath: imagePath, 
      userId: userId
    );

    try {
      await _personService.addPerson(person); 
      setState(() {
        _people.add(person); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StyledSuccessText('Person_added_successfully'.tr()), backgroundColor: Colors.white),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StyledErrorText('Action_failed'.tr()), backgroundColor: Colors.white),
        );
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

      _showAddPersonDialog(localFile.path); 
    }
  }

  // Method to show a dialog for adding new person details
  void _showAddPersonDialog(String imagePath) {
    String name = '';
    String relation = '';
    String phone = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Add_New_Person'.tr(),style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:  InputDecoration(labelText: 'Name'.tr()),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration:  InputDecoration(labelText: 'Relationship'.tr()),
                onChanged: (value) {
                  relation = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Phone_Number'.tr()),
                onChanged: (value) {
                  phone = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && relation.isNotEmpty && phone.isNotEmpty) {
                  _addPerson(name, relation,phone, imagePath); 
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
        title: Text('People_To_Remember'.tr()),
      ),
      body:  _isLoading
          ? const Center(child: CircularProgressIndicator())
          :_people.isEmpty? Center(child: Text('No_Entries'.tr()))
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
          onPressed: _pickAndSaveImage, 
          child: Text('Add_New_Person'.tr()),
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
          onPressed: () async {
            final Uri phoneUri = Uri(scheme: 'tel', path: person.phone);
            if (!await launchUrl(phoneUri)) {
              throw 'Could not launch $phoneUri';
            }
          },
        ),
      ),
    );
  }

}

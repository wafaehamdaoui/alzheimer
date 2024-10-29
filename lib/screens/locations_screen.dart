import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:myproject/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:myproject/models/location.dart'; // Import your Location model
import 'package:myproject/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import LocationService

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final List<Location> _locations = [];
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService(); 
  final Logger _logger = Logger();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations(); 
  }

  // Fetch locations from the service
  Future<void> _fetchLocations() async {
    try {
      List<Location> locations = await _locationService.getAllLocations();
      setState(() {
        _locations.addAll(locations);
        _isLoading = false;
      });
      _logger.i("Location : ${_locations.first.id}");
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

  // Method to allow user to pick an image and save it to local storage
  Future<void> _pickAndSaveImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String savedPath = '${appDir.path}/$fileName';
      final File localFile = await File(pickedFile.path).copy(savedPath);

      _showAddLocationDialog(localFile.path); 
    }
  }

  Future<int> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id')??0; 
  } 

  // Method to show dialog for adding a new location
  void _showAddLocationDialog(String imagePath) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController coordinatesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add_New_Location'.tr(),style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Place_Name'.tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: coordinatesController,
                decoration: InputDecoration(
                  labelText: 'Address'.tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                // Create a new Location object
                final userId = await getUserID();
                final newLocation = Location(
                  id: null,
                  title: titleController.text,
                  coordinates: coordinatesController.text,
                  imagePath: imagePath,
                  userId: userId
                );

                // Add the new location using the service
                await _locationService.addLocation(newLocation);
                setState(() {
                  _locations.add(newLocation); 
                });
                
                Navigator.of(context).pop(); 
              },
              child: Text('add'.tr()),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a location
  Future<void> _deleteLocation(Location location) async {
    await _locationService.deleteLocation(location.id??0); 
    setState(() {
      _locations.remove(location); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Important_Locations'.tr()),
      ),
      body:  _isLoading
          ? const Center(child: CircularProgressIndicator())
          :_locations.isEmpty?
        Center(child: Text('No_Entries'.tr()),)
      :ListView(
        padding: const EdgeInsets.all(10),
        children: _locations.map((location) {
          return _buildLocationCard(location);
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _pickAndSaveImage, 
          child: Text('Add_New_Location'.tr()),
        ),
      ),
    );
  }

  Widget _buildLocationCard(Location location) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: ListTile(
      leading: Image.file(
        File(location.imagePath),
        width: 65,
        height: 65,
        fit: BoxFit.cover,
      ),
      title: Text(
        location.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(location.coordinates),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _showDeleteConfirmationDialog(location), 
      ),
    ),
  );
}

// Method to show confirmation dialog before deletion
void _showDeleteConfirmationDialog(Location location) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('confirm'.tr(),style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.bold)),
        content: Text('${'Are_you_sure'} ${location.title}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              await _deleteLocation(location); 
              Navigator.of(context).pop(); 
            },
            child: Text('Delete'.tr()),
          ),
        ],
      );
    },
  );
}

}

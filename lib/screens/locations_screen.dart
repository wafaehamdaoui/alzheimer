import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:myproject/models/location.dart'; // Import your Location model
import 'package:myproject/services/location_service.dart'; // Import LocationService

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

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Fetch locations on screen load
  }

  // Fetch locations from the service
  Future<void> _fetchLocations() async {
    try {
      List<Location> locations = await _locationService.getAllLocations();
      setState(() {
        _locations.addAll(locations);
      });
      _logger.i("Location : ${_locations.first.id}");
    } catch (e) {
      print('Error fetching locations: $e'); // Handle error
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

      _showAddLocationDialog(localFile.path); // Pass the image path to the dialog
    }
  }

  // Method to show dialog for adding a new location
  void _showAddLocationDialog(String imagePath) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController coordinatesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Place Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: coordinatesController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Create a new Location object
                final newLocation = Location(
                  id: null,
                  title: titleController.text,
                  coordinates: coordinatesController.text,
                  imagePath: imagePath,
                );

                // Add the new location using the service
                await _locationService.addLocation(newLocation);
                setState(() {
                  _locations.add(newLocation); // Update local state
                });
                
                Navigator.of(context).pop(); // Close dialog after adding entry
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a location
  Future<void> _deleteLocation(Location location) async {
    await _locationService.deleteLocation(location.id??0); // Delete using the service
    setState(() {
      _locations.remove(location); // Update local state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Important Locations'),
      ),
      body: _locations.isEmpty?
      const Center(child: Text('No Entries Yet!'),)
      :ListView(
        padding: const EdgeInsets.all(10),
        children: _locations.map((location) {
          return _buildLocationCard(location);
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _pickAndSaveImage, // Open image picker
          child: const Text('Add New Location'),
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
        onPressed: () => _showDeleteConfirmationDialog(location), // Show confirmation dialog
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
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${location.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _deleteLocation(location); // Call delete method
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}

}

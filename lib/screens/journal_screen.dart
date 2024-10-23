import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/models/journal.dart'; 
import 'package:myproject/services/journal_service.dart';
import 'package:myproject/theme.dart';

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<JournalEntry> _entries = []; // List to hold journal entries
  final TextEditingController _textController = TextEditingController(); // Text controller for journal entry
  final JournalService _journalService = JournalService(); // Create an instance of the JournalService
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _fetchEntries(); 
  }

  Future<void> _fetchEntries() async {
    setState(() {
      _isLoading = true; 
    });

    try {
      final entries = await _journalService.getAllJournals();
      setState(() {
        _entries.addAll(entries); 
      });
    } catch (e) {
      print('Error fetching journal entries: $e');
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  Future<void> _addEntry() async {
    final String description = _textController.text;
    if (description.isNotEmpty) {
      final request = JournalEntry(description: description, date: DateTime.now()); 
      try {
        final newEntry = await _journalService.addJournal(request);
        setState(() {
          _entries.add(newEntry); 
        });
        _textController.clear(); 
      } catch (e) {
        print('Error adding journal entry: $e');
      }
    }
  }

  // Method to show dialog for adding a new entry
  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Journal Entry for Today'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'What happened today?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10), // Add space between text field and button
              ElevatedButton(
                onPressed: () {
                  _addEntry();
                  Navigator.of(context).pop(); // Close dialog after adding entry
                },
                child: const Text('Add Entry'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _entries.isEmpty
                ? const Center(child: Text('No entries yet.'))
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          subtitle: Text(entry.description),
                          title: Text(DateFormat('yyyy-MM-dd – kk:mm').format(entry.date), style: TextStyle(color:AppTheme.textColor, fontWeight: FontWeight.w900 ),), 
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _showAddEntryDialog,
          child: const Text('Add Today\'s Journal Entry'),
        ),
      ),
    );
  }
}

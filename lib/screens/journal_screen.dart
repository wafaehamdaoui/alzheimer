import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myproject/models/journal.dart'; 
import 'package:myproject/services/journal_service.dart';
import 'package:myproject/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final List<JournalEntry> _entries = []; // List to hold journal entries
  final TextEditingController _textController = TextEditingController(); // Text controller for journal entry
  final JournalService _journalService = JournalService(); // Create an instance of the JournalService
  final Logger _logger = Logger();
  bool _isLoading = true; 


  @override
  void initState() {
    super.initState();
    _fetchEntries(); 
  }

  Future<void> _fetchEntries() async {

    try {
      final entries = await _journalService.getAllJournals();
      setState(() {
        _entries.addAll(entries); 
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

  Future<void> _addEntry() async {
    final String description = _textController.text;
    final userId = await getUserID();
    if (description.isNotEmpty) {
      final request = JournalEntry(description: description, date: DateTime.now(),userId: userId); 
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
          title: Text('journal_add_title'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'journal_label'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10), 
              ElevatedButton(
                onPressed: () {
                  _addEntry();
                  Navigator.of(context).pop(); 
                },
                child: Text('add'.tr()),
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
        title: Text('journals'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          :_entries.isEmpty
                ? Center(child: Text('No_Entries'.tr()))
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
          child: Text('add_btn_title'.tr()),
        ),
      ),
    );
  }
}

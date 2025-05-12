import 'package:flutter/material.dart';
import 'widgets/course_card.dart';
import 'package:bu_scholar/appwrite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, Map<String, dynamic>> documents = {};
  Map<String, Map<String, dynamic>> filteredDocuments = {};
  Appwrite appwrite = Appwrite();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      documents = await appwrite.fetchDocuments();
      filteredDocuments = documents;
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterDocuments(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredDocuments = documents;
      });
      return;
    }

    // Split the query into words for multi-word search
    final queryWords =
        query
            .toLowerCase()
            .split(' ')
            .where((word) => word.isNotEmpty)
            .toList();

    setState(() {
      filteredDocuments = documents.map(
        (key, value) => MapEntry(key, value),
      )..removeWhere((key, value) {
        final courseName =
            (value['course_name'] ?? '').toString().toLowerCase();
        final courseCode =
            (value['course_code'] ?? '').toString().toLowerCase();
        final description =
            (value['description'] ?? '').toString().toLowerCase();

        // Check if ALL words in the query are found in at least one of the fields
        bool matchesAllWords = true;
        for (final word in queryWords) {
          // If none of the fields contain this word, this document doesn't match
          if (!courseName.contains(word) &&
              !courseCode.contains(word) &&
              !description.contains(word)) {
            matchesAllWords = false;
            break;
          }
        }

        // Also check for exact phrase match (the original full query)
        final exactPhraseMatch =
            courseName.contains(query.toLowerCase()) ||
            courseCode.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());

        // Document should be removed if it doesn't match all words AND doesn't match exact phrase
        return !matchesAllWords && !exactPhraseMatch;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            filterDocuments('');
                          },
                        )
                        : null,
              ),
              onChanged: filterDocuments,
            ),
          ),
          Expanded(
            child:
                documents.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredDocuments.isEmpty
                    ? const Center(
                      child: Text(
                        'No courses found. Try a different search term.',
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredDocuments.length,
                      itemBuilder: (context, index) {
                        final entry = filteredDocuments.entries.elementAt(
                          index,
                        );
                        return CourseCard(data: entry.value);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/services/firestore_service.dart';
import 'package:winter_arc/screens/profile/other_user_profile_screen.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _searchController = TextEditingController();
  final _firestoreService = FirestoreService();
  List<User> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _firestoreService.searchUsers(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Debounce could be added here
                _performSearch(value);
              },
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Search for other Winter Arc warriors'
                              : 'No users found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                              ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      user.avatarEmoji ?? user.name[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 20),
                                    )
                                  : null,
                            ),
                            title: Text(user.name),
                            subtitle: Text('Joined ${user.joinedDate.year}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OtherUserProfileScreen(user: user),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

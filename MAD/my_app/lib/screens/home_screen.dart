import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../services/preference_service.dart';
import '../widgets/course_card.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/error_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<CourseProvider>(context, listen: false)
        .setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userName = PreferenceService.getUserName();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName 👋',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'What do you want to learn today?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notification quick view / action if needed
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search courses or instructors...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
              ],
              elevation: MaterialStateProperty.all(1),
              backgroundColor: MaterialStateProperty.all(
                theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingSpinner(message: 'Fetching online courses...');
          }

          if (provider.errorMessage.isNotEmpty && provider.courses.isEmpty) {
            return ErrorMessage(
              message: provider.errorMessage,
              onRetry: () => provider.loadCourses(),
            );
          }

          final filtered = provider.filteredCourses;

          return RefreshIndicator(
            onRefresh: () => provider.loadCourses(isRefresh: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: provider.selectedFilter == CourseFilter.all,
                        onSelected: (_) => provider.setFilter(CourseFilter.all),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Free'),
                        selected: provider.selectedFilter == CourseFilter.free,
                        onSelected: (_) => provider.setFilter(CourseFilter.free),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Popular'),
                        selected: provider.selectedFilter == CourseFilter.popular,
                        onSelected: (_) => provider.setFilter(CourseFilter.popular),
                      ),
                    ],
                  ),
                ),
                // Grid/List of Courses
                Expanded(
                  child: filtered.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                            const Center(
                              child: Text(
                                'No courses match your criteria.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return CourseCard(course: filtered[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

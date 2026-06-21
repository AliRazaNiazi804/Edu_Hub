import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/course_model.dart';
import '../data/database_helper.dart';
import '../services/preference_service.dart';

class DetailScreen extends StatefulWidget {
  final String itemId;
  const DetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  bool _isEnrolled = false;
  late CourseModel _course;
  bool _initialized = false;
  List<String> _watchedLessonIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Get the course model passed via extra or build a placeholder
      final extra = GoRouterState.of(context).extra;
      if (extra is CourseModel) {
        _course = extra;
      } else {
        // Safe fallback if navigated directly by link
        _course = CourseModel(
          id: widget.itemId,
          title: 'Course Details',
          instructor: 'Dr. Alex Stone',
          description: 'This is the detailed description of the online course.',
          rating: 4.5,
          thumbnail: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=600&auto=format&fit=crop',
          price: 0.0,
          isFree: true,
          isPopular: false,
          lessons: [],
        );
      }
      _isFavorite = PreferenceService.getFavorites().contains(_course.id);
      _checkEnrollment();
      _initialized = true;
    }
  }

  void _checkEnrollment() async {
    final enrolled = await DatabaseHelper.instance.isEnrolled(_course.id);
    final watched = await DatabaseHelper.instance.getWatchedLessons(_course.id);
    final watchedIds = watched.map((w) => w['lessonId'].toString()).toList();
    if (mounted) {
      setState(() {
        _isEnrolled = enrolled;
        _watchedLessonIds = watchedIds;
      });
    }
  }

  void _toggleFavorite() async {
    await PreferenceService.toggleFavorite(_course.id);
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _enrollCourse() async {
    if (_isEnrolled) return;

    final now = DateTime.now().toIso8601String();
    await DatabaseHelper.instance.insertEnrolledCourse({
      'id': _course.id,
      'title': _course.title,
      'instructor': _course.instructor,
      'enrolledDate': now,
      'progressPercent': 0.0,
    });

    setState(() {
      _isEnrolled = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully Enrolled!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner Image + App Bar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _course.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.colorScheme.surfaceVariant,
                        child: const Icon(Icons.school, size: 80),
                      );
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          // Course Info & Lesson List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _course.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _course.isFree ? 'Free' : '\$${_course.price.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _course.instructor,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      _course.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'About this course',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _course.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isEnrolled ? null : _enrollCourse,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: _isEnrolled ? theme.colorScheme.surfaceVariant : theme.colorScheme.primary,
                    foregroundColor: _isEnrolled ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _isEnrolled ? 'Enrolled' : 'Enroll Now',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Curriculum (${_course.lessons.length} Lessons)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._course.lessons.map((lesson) {
                  final isWatched = _watchedLessonIds.contains(lesson.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isWatched ? Colors.green.shade100 : theme.colorScheme.primaryContainer,
                        child: Icon(
                          isWatched ? Icons.check : Icons.play_arrow,
                          color: isWatched ? Colors.green.shade800 : theme.colorScheme.onPrimaryContainer
                        ),
                      ),
                      title: Text(
                        lesson.title,
                        style: TextStyle(
                          decoration: isWatched ? TextDecoration.lineThrough : null,
                          color: isWatched ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6) : null,
                        ),
                      ),
                      subtitle: Text(lesson.duration),
                      onTap: () async {
                        // Mark watched on tap and open video
                        await DatabaseHelper.instance.markLessonWatched(lesson.id, _course.id);
                        _checkEnrollment(); // Refresh watched lessons list state
                        if (mounted) {
                          context.push('/video-player', extra: lesson.title);
                        }
                      },
                    ),
                  );
                }),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

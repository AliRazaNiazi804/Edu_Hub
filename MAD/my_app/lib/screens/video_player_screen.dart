import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String lessonTitle;

  const VideoPlayerScreen({Key? key, required this.lessonTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(lessonTitle)),
      body: Column(
        children: [
          // Black video placeholder area
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_fill, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    const Text(
                      'Video Player Loading...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Info description area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lessonTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        avatar: const Icon(Icons.hd),
                        label: const Text('1080p'),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(Icons.timer_outlined),
                        label: const Text('12 mins'),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lesson description',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lesson video will play here. This placeholder demonstrates navigating to a simulated dynamic player for the learning platform.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Back to Course'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

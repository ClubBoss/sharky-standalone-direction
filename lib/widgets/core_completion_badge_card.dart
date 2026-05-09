import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/core_completion_badge_service.dart';

class CoreCompletionBadgeCard extends StatelessWidget {
  const CoreCompletionBadgeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: CoreCompletionBadgeService().isCoreComplete(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data == false) {
        return const SizedBox.shrink(); // Auto-hide if not completed
      }

      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 32.0,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    Intl.message(
                      "Core Path Completed!",
                      name: "corePathCompletedLabel",
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Stub for share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        Intl.message(
                          "Sharing is coming soon!",
                          name: "shareComingSoon",
                        ),
                      ),
                    ),
                  );
                },
                child: Text(Intl.message("Share", name: "shareButton")),
              ),
            ],
          ),
        ),
      );
    },
  );
}

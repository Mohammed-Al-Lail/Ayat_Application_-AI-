import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AyaWidget extends StatelessWidget {
  final String ayaText;
  final String ayaMeaning;
  final bool showMeaning;
  final VoidCallback playAya;
  final VoidCallback toggleMeaning;

  const AyaWidget({
    super.key,
    required this.ayaText,
    required this.ayaMeaning,
    required this.showMeaning,
    required this.playAya,
    required this.toggleMeaning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                ayaText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (showMeaning)
                Text(
                  ayaMeaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: playAya,
              icon: const Icon(CupertinoIcons.volume_up),
              label: const Text("Listen"),
              style: ElevatedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimary,
                backgroundColor:
                    Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: toggleMeaning,
              icon: Icon(showMeaning
                  ? CupertinoIcons.eye_slash
                  : CupertinoIcons.eye),
              label: Text(showMeaning
                  ? "Hide Meaning"
                  : "Show Meaning"),
              style: ElevatedButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.onSecondary,
                backgroundColor:
                    Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
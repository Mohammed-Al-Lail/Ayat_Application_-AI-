import 'package:flutter/material.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback onTimerEnd;

  const TimerWidget({
    Key? key,
    required this.initialDuration,
    required this.onTimerEnd,
  }) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Duration _remainingTime;
  // Timer? _timer; // Removed the internal timer

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    // _startCountdownTimer(); // No longer start an internal timer
  }

  @override
  void didUpdateWidget(covariant TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update _remainingTime when initialDuration changes from the parent
    if (widget.initialDuration != oldWidget.initialDuration) {
      _remainingTime = widget.initialDuration;
    }
  }

  @override
  void dispose() {
    // _timer?.cancel(); // No internal timer to cancel
    super.dispose();
  }

  // Removed _startCountdownTimer

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Use the initialDuration directly for display
    _remainingTime = widget.initialDuration;

    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: _remainingTime.inSeconds / const Duration(hours: 12).inSeconds, // Use the fixed initial duration for the progress indicator calculation
            strokeWidth: 9,
            backgroundColor: Colors.grey[700], // Added background color
            color: _remainingTime.inSeconds > Duration(hours: 1).inSeconds ? Colors.white : const Color.fromARGB(255, 93, 17, 12), // Adjusted color threshold
          ),
          Center(
            child: Text(
              formatDuration(_remainingTime),
              style:  TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                 color: _remainingTime.inSeconds > Duration(hours: 1).inSeconds ? Colors.white : const Color.fromARGB(255, 93, 17, 12), // Adjusted color threshold
              ),
            ),
          ),
        ],
      ),
    );
  }
}

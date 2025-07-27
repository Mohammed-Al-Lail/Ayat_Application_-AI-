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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        if (_remainingTime.inSeconds < 1) {
          timer.cancel();
          widget.onTimerEnd();
             _remainingTime = widget.initialDuration;
          _startCountdownTimer();
          
        }
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: _remainingTime.inSeconds / widget.initialDuration.inSeconds,
            strokeWidth: 9,
            backgroundColor: Colors.grey[700], // Added background color
            color: _remainingTime.inSeconds> Duration(hours: 1).inSeconds ? Colors.white : const Color.fromARGB(255, 93, 17, 12), // Adjusted color threshold
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

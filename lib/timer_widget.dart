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

  @override
  Widget build(BuildContext context) {
    return Text(
      'Next Aya in: ${_remainingTime.inHours.toString().padLeft(2, '0')}:${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
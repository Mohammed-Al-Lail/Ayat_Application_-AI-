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
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: _remainingTime.inSeconds / widget.initialDuration.inSeconds,
            strokeWidth: 8,
            color: _remainingTime.inSeconds>5 ? Colors.white : Colors.red,
          ),
          Center(
            child: Text(
              '${_remainingTime.inSeconds} s',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

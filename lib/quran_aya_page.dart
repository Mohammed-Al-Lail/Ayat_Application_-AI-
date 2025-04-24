import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'aya_widget.dart';
import 'timer_widget.dart';

class QuranAyaPage extends StatefulWidget {
  const QuranAyaPage({super.key});
  @override
  State<QuranAyaPage> createState() => _QuranAyaPageState();
}

class _QuranAyaPageState extends State<QuranAyaPage> {
  String _ayaText = "";
  String _ayaMeaning = "";
  bool _showMeaning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
    List<Map<String, dynamic>> _ayas = [];
    
    @override
  void initState() {
    super.initState();
    _loadAyas();
    _startTimer();
    
  }
  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAyas() async {
    final String response = await rootBundle.loadString('assets/ayas.json');
    final data = await json.decode(response);
    setState(() {
      _ayas = List<Map<String, dynamic>>.from(data['ayas']);
      _loadNewAya();
    });
  }

  void _loadNewAya() {
    final now = DateTime.now();
    final ayaIndex = now.second % _ayas.length;
    setState(() {
      _ayaText = _ayas[ayaIndex]['text'] ?? "No Aya found";
       _ayaMeaning = _ayas[ayaIndex]['meaning'] ?? "No meaning found";
       _showMeaning = false;
    });
  }

    Duration _calculateRemainingTime() {
        return const Duration(seconds: 10);
  }
  void _startTimer() {
    const duration = Duration(seconds: 10);
    _timer = Timer.periodic(duration, (Timer timer) {
      _loadNewAya();
    });
  }
  
  void _playAya() async {
    String url = 'assets/audio/aya1.mp3'; // Replace with actual URLs from json
    await _audioPlayer.play(AssetSource(url));
  }

  void _toggleMeaning() {
    setState(() {
      _showMeaning = !_showMeaning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AyaWidget(
                  ayaText: _ayaText, 
                  ayaMeaning: _ayaMeaning, 
                  showMeaning: _showMeaning, 
                  playAya: _playAya, 
                  toggleMeaning: _toggleMeaning
                ),
                const SizedBox(height: 20),
                TimerWidget(
                  initialDuration: _calculateRemainingTime(),
                  onTimerEnd: _loadNewAya,
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
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

  late int _ayaIndex;
  String _currentSurahName = "";
  int _currentAyaNumber = 0;
    
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

  void _loadNewAya() async {
    final now = DateTime.now();
    final ayaIndex = now.second % _ayas.length;
   
    
    setState(() {
      _ayaIndex = ayaIndex; // we will use the _ayaIndex instead of the orginal one -> (ayaIndex), so we can use _ayaIndex in different methods

      _ayaText = _ayas[_ayaIndex]['text'] ?? "No Aya found";
      _currentSurahName = _ayas[_ayaIndex]['surah'] ?? "";
      _currentAyaNumber = _ayas[_ayaIndex]['aya_number'] ?? 0;
      _ayaMeaning = _ayas[_ayaIndex]['meaning'] ?? "No meaning found";
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
   
      String url = _ayas[_ayaIndex]['audio_url'];
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

      backgroundColor: Colors.blue[300],

      body: Column(


        children: [

        

         Center(
           child: Container(
                   
            margin: EdgeInsets.all(10),
            
            height: MediaQuery.of(context).size.height*0.9,
            width:  MediaQuery.of(context).size.width*0.9,
            
            
                   
            decoration: BoxDecoration(
                   
              border: Border.all(
                color: Colors.black54,
                width: 12,
              ),
                   
              borderRadius:BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30)
              ) ,
           
              
                   
              color: Colors.blue[200]
             
            ),
                   
            child: SingleChildScrollView( // this to Enable the vertical scrolling
              scrollDirection: Axis.vertical,
              
              
              child: Center(
           
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
           
                  child: SingleChildScrollView( // this to enable the horizontal scrolling
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                                
                      children: [
                                
                        Text(
                          "آيَاتٌ مُحْكَمَاتٌ",
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.6
                            ),
                            fontSize: 46,
                            fontWeight: FontWeight.w900
                          ),
                        ),
                                
                        const SizedBox(height: 60,),
                                
                        AyaWidget(
                          ayaText: _ayaText, 
                          ayaMeaning: _ayaMeaning, 
                          showMeaning: _showMeaning, 
                          playAya: _playAya,
                          surahName: _currentSurahName,
                          ayaNumber: _currentAyaNumber,
                          toggleMeaning: _toggleMeaning
                        ),
                        const SizedBox(height: 70),
                                
                        Text(
                          "The Aya Will be Updated After:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white70
                          ),
                        ),
                                
                        const SizedBox(height: 20,),
                                
                        TimerWidget(
                          initialDuration: _calculateRemainingTime(),
                          onTimerEnd: _loadNewAya,
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
                   ),
         ),

        ],
      ),
    );
  }
}
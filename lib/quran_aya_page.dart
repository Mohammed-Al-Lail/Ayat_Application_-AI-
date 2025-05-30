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
    _ayaIndex = ayaIndex; // we will use the _ayaIndex instead of the orginal one -> (ayaIndex), so we can use _ayaIndex in different methods
    
    setState(() {
       

      _ayaText = _ayas[_ayaIndex]['text'] ?? "No Aya found";
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

     // backgroundColor: Colors.amber[100] ,
      

      body: Stack(

        children: [

        // this container will hold the outer img background
          Container(

            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover
                )
            ),
          ),

         Container(
        
          margin: EdgeInsets.all(50),
          
        
          decoration: BoxDecoration(
        
            border: Border.all(
              color: Colors.black54,
              width: 8,
            ),
        
            borderRadius:BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30)
            ) ,

            image: DecorationImage( // this container will hold the inner img background
              image: AssetImage("assets/images/background2.jpg"),
              fit: BoxFit.cover
              ),
        
            color: Colors.transparent
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Theme.of(context).colorScheme.primaryContainer,
            //     Theme.of(context).colorScheme.secondaryContainer,
            //   ],
            // ),
          ),
        
          child: SingleChildScrollView( // this to enable the vertical scrolling
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
                        toggleMeaning: _toggleMeaning
                      ),
                      const SizedBox(height: 70),
                              
                      Text(
                        "The Aya Will be Updated After:",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white
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

        ],
      ),
    );
  }
}
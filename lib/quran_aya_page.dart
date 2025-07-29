import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:myapp/drawerListTail.dart';
// import 'package:url_launcher/url_launcher.dart'; // Removed url_launcher
import 'package:flutter_email_sender/flutter_email_sender.dart'; // Imported flutter_email_sender
import 'aya_widget.dart';
import 'timer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';


class QuranAyaPage extends StatefulWidget {
  const QuranAyaPage({super.key});
  @override
  State<QuranAyaPage> createState() => _QuranAyaPageState();
}

class _QuranAyaPageState extends State<QuranAyaPage> with WidgetsBindingObserver{
  String _ayaText = "";
  String _ayaMeaning = "";
  bool _showMeaning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Timer? _timer; // Removed the timer
  Timer? _uiUpdateTimer; // Timer for UI updates when app is open
  List<Map<String, dynamic>> _ayas = [];

  int _ayaIndex = 0; // Initialize _ayaIndex
  String _currentSurahName = "";
  int _currentAyaNumber = 0;
  Duration _remainingTime = const Duration(hours: 12); // Initialize with the default duration

    @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _loadAyas().then((_) {
      _loadTimerState();
       // Removed the call to _updateAyaDisplay() here
    });

  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    // _saveTimerState(); // No need to save timer state on dispose with this approach
    _uiUpdateTimer?.cancel(); // Cancel UI update timer
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTimerState(); // Load and update on resume
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    // No need to save remaining time, only the end time
    // await prefs.setInt('timerEndTime', timerEndTime.millisecondsSinceEpoch);
    await prefs.setInt('currentAyaIndex', _ayaIndex); // Save the current aya index
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEndTimeMillis = prefs.getInt('timerEndTime');
    final savedAyaIndex = prefs.getInt('currentAyaIndex'); // Load the saved aya index

    if (savedEndTimeMillis != null && savedAyaIndex != null) {
      final savedEndTime = DateTime.fromMillisecondsSinceEpoch(savedEndTimeMillis);
      final remaining = savedEndTime.difference(DateTime.now());

      if (remaining.isNegative) {
        // Timer has already ended
        _remainingTime = Duration.zero;
        _loadNewAya(); // Trigger the next aya
      } else {
        _remainingTime = remaining;
        _ayaIndex = savedAyaIndex; // Use the saved aya index
        _updateAyaDisplay(); // Update the displayed aya based on the loaded index
        _startUiUpdateTimer(); // Start UI update timer
      }
    } else {
      // No saved state, start with the first aya and a new timer
      _ayaIndex = 0; // Start with the first aya
      _remainingTime = const Duration(hours: 12); // Or your initial duration
      _updateAyaDisplay(); // Display the first aya
      _startTimer(); // Start the timer (sets end time and starts UI update timer)
    }
  }

  void _startTimer() async {
    // This function now only sets the end time and saves it
    final endTime = DateTime.now().add(_remainingTime);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timerEndTime', endTime.millisecondsSinceEpoch);
    _startUiUpdateTimer(); // Start the UI update timer
  }

 void _startUiUpdateTimer() async { // Made the function async
  _uiUpdateTimer?.cancel(); // Cancel any existing UI update timer

  final prefs = await SharedPreferences.getInstance(); // Get prefs once

  _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    // No need for await inside setState now
    final savedEndTimeMillis = prefs.getInt('timerEndTime');
    if (savedEndTimeMillis != null) {
      final savedEndTime = DateTime.fromMillisecondsSinceEpoch(savedEndTimeMillis);
      setState(() {
        _remainingTime = savedEndTime.difference(DateTime.now());
        if (_remainingTime.inSeconds < 1) {
          _remainingTime = Duration.zero;
          timer.cancel();
          _loadNewAya(); // Load new aya when timer ends
        }
      });
    } else {
      setState(() {
        _remainingTime = const Duration(hours: 12); // Reset to default if no end time is saved
        timer.cancel();
      });
    }
  });
}




  Future<void> _loadAyas() async {
    final String response = await rootBundle.loadString('assets/ayas.json');
    final data = await json.decode(response);
    setState(() {
      _ayas = List<Map<String, dynamic>>.from(data['ayas']);
    });
  }

  void _loadNewAya() async {
    _uiUpdateTimer?.cancel(); // Cancel UI update timer before loading new aya
    if (_ayas.isEmpty) return; // Ensure ayas are loaded

    // Logic to select the next aya (example: move to the next aya sequentially)
    _ayaIndex = (_ayaIndex + 1) % _ayas.length;

    setState(() {
      _updateAyaDisplay(); // Update the UI with the new aya
      _remainingTime = const Duration(hours: 12); // Reset timer for the new aya
      _saveTimerState(); // Save the new aya index
      _startTimer(); // Start the timer (sets end time and starts UI update timer)
    });
  }

  void _updateAyaDisplay() {
    if (_ayas.isNotEmpty && _ayaIndex >= 0 && _ayaIndex < _ayas.length) {
      setState(() {
        _ayaText = _ayas[_ayaIndex]['text'] ?? "No Aya found";
        _currentSurahName = _ayas[_ayaIndex]['surah'] ?? "";
        _currentAyaNumber = _ayas[_ayaIndex]['aya_number'] ?? 0;
        _ayaMeaning = _ayas[_ayaIndex]['meaning'] ?? "No meaning found";
        _showMeaning = false;
      });
    }
  }


    Duration _calculateRemainingTime() {
        return _remainingTime;
  }

  
 void _playAya() async {
    
      String url = _ayas[_ayaIndex]['audio_url'];
      // Use just_audio to load and play the audio
      await _audioPlayer.setAsset(url); // Use setAsset for local assets
      _audioPlayer.play();
     
  
  }
  void _toggleMeaning() {
    setState(() {
      _showMeaning = !_showMeaning;
    });
  }


  void _sendEmail() async {
    final Email email = Email(
      body: '', // Optional: Email body
      subject: '', // Optional: Email subject
      recipients: ['alalmoh3404@gmail.com'], // Replace with recipient's email
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      // Handle error, e.g., no email client available
      print('Error sending email: $error');
      // You might want to show a dialog to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Could not launch email app. Please configure an email account on your device.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color.fromRGBO(24, 65, 99, 1),

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        title: Center(
          child: Text(
            "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.7
              ),
              fontSize: 26,
              fontWeight: FontWeight.w900
            ), 

          ),
        ),

        leading: Builder(
          builder: (ctx) {

            return Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 50, 
                  height: 50, 
                  color: Colors.blue[200],
                  child: IconButton(
                    onPressed: (){
                      Scaffold.of(ctx).openDrawer();
                    },
                     icon: Icon(
                      Icons.menu,
                     )
                     ),
                ),
              ),
            );
          }
        ) ,
      ),

      
      drawer: Drawer(

        backgroundColor: Colors.grey[300],

        child: ListView(
          
          children: [

            SizedBox(height: 50,),

            Center(
             
              child: Text(
                "آيَاتٌ مُحْكَمَاتٌ",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 34,
                  fontWeight: FontWeight.bold
              
                ),
              
              ),
            ),
            SizedBox(height: 30,),

            Divider(
              color: Colors.grey[800],
              thickness: 2,
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "يمكنكم التواصل معنا من خلال البريد الالكتروني",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 28,
              
                ),
              
              ),
            ),
            SizedBox(height: 20,),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "You can communicate with us through the following Email",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 22,
              
                ),
              
              ),
            ),
           
            SizedBox(height: 20,),
            
            Icon(
              Icons.arrow_downward_sharp,
              size: 48,
              color: Colors.grey[800],
            ),
            SizedBox(height: 30,),

            DrawerlistTail(
              title: "Send Email",
              icon: Icons.message_outlined,
              onTap: _sendEmail,
              ),
             // SizedBox(height: 20,),

            

          ],
        ),
      ),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
        
          
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
             
                
                     
                color: const Color.fromRGBO(72, 120, 159, 1)
               
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
      ),
    );
  }
}
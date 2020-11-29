import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'statisticsPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doggowatch Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        accentColor: Colors.white,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DoggoWatchPage(title: 'DoggoWatch'),
    );
  }
}

class DoggoWatchPage extends StatefulWidget {
  DoggoWatchPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DoggoWatchPage> {
  String _counter = "0";

  var _stopwatch = Stopwatch();
  bool _started = false;

  bool _initialized = false;
  bool _error = false;

  //FirebaseFirestore _firestore;
  CollectionReference _durations;

  PageController _controller = PageController(
    initialPage: 0,
  );

  _MyHomePageState() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      _incrementCounter();
    });
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      //_firestore = FirebaseFirestore.instance;
      _durations = FirebaseFirestore.instance.collection('durations');
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      var s = Duration(milliseconds: _stopwatch.elapsedMilliseconds).toString();
      _counter = s.substring(0, s.length - 5);
    });
  }

  void _resetTimer() {
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _started = false;
      _counter = "0";
    });
  }

  void _activate() {
    setState(() {
      if (!_started) {
        _stopwatch.start();
      } else {
        _stopwatch.stop();
      }
      _started = !_started;
    });
  }

  Future<void> _addDuration() {
    int dur = Duration(milliseconds: _stopwatch.elapsedMilliseconds).inSeconds;
    return _durations.add({
      'durationStr': _counter,
      'duration': dur,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    }).then((value) {
      _stopwatch.stop();
      _started = false;
      _resetTimer();
    }).catchError((error) => print("failed to add duration: $error"));
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return _loading();
    }
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          _counterWidget(),
          StatisticsPage(),
        ],
      ),
    );
  }

  Widget _counterWidget() {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/1.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 30, bottom: 10),
            ),
            Text(
              '$_counter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
              textScaleFactor: 1.7,
            ),
            Container(
              padding: EdgeInsets.only(top: 30, bottom: 200),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _resetTimer,
                  color: Colors.white,
                  iconSize: 100,
                ),
                IconButton(
                  icon: _started ? Icon(Icons.stop) : Icon(Icons.not_started),
                  tooltip: _started ? "Stop" : "Start",
                  onPressed: _activate,
                  color: Colors.white,
                  iconSize: 100,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.cloud),
                  iconSize: 100,
                  color: Colors.white,
                  onPressed: (_started || _stopwatch.elapsedMilliseconds == 0)
                      ? null
                      : _addDuration,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loading() {
    return new Scaffold(
      body: Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }
}

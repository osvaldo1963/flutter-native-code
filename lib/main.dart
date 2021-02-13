import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:worker_manager/worker_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
  void _getLocation() async {
    await _determinePosition();
    var position =  Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation);
    position.listen((event) {
      //print(event.toJson());
    });

  }
  static const platform = const MethodChannel('sample.flutter.dev/battery');
  String _batteryLevel = "unknown battery lavel ";

  checkPermissions() async { await _determinePosition(); }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermissions();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_batteryLevel),
            FlatButton(onPressed: getBaterryLevel, child: Text("click me"))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  getBaterryLevel() async {
    await setworker();
    String batteryLevel;
    try{
      final int result = await platform.invokeMethod("getBatteryLevel");
      batteryLevel = "baterry lelvel at $result";
    } on PlatformException catch(e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    setState(() {
      this._batteryLevel = batteryLevel;
    });
  }

}

getLocation() async {
  var currentPosition = Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  var position = await currentPosition;
  print(position);
}
Future setworker() {
  return Executor().execute(fun1: counter()).next(onNext: (v) {});
}
counter() {
  var milisecons = Duration(seconds: 1);
  var counter = 0;
  new Timer.periodic(milisecons, (timer) {
    if(timer.tick == counter + 15) {
      counter = timer.tick;
      print(timer.tick);
      getLocation();
    }
  });
  return;
}

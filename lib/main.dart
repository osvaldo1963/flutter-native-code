import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

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

  void _getLocation() async {

    var position =  Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation);
    position.listen((event) {
      //print(event.toJson());
    });

  }
  static const platform = const MethodChannel('sample.flutter.dev/battery');

  String _batteryLevel = "unknown battery lavel ";

  checkPermissions() async {
    print("ask for location permission");
    var status = await Permission.locationAlways.request();

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermissions();
    getBaterryLevel();
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
            FlatButton(onPressed: () {}, child: Text("click me"))
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  getBaterryLevel() async {

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.onGeofence((location) {
      print('[=================>location<=================] - ${location.location}');
    });

    bg.BackgroundGeolocation.addGeofence(bg.Geofence(
        identifier: "Home",
        radius: 200,
        latitude: 45.51921926,
        longitude: -73.61678581,
        notifyOnEntry: true,
        notifyOnExit: true,
        extras: {
          "route_id": 1234
        }
    ));
    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: true,
    )).then((value) {
      if(!value.enabled) {
        bg.BackgroundGeolocation.startGeofences();
      }
    });




    /*
    await setworker(); //isolated worker
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
     */
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

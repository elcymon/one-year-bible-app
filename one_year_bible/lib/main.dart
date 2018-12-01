import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:convert';
//
import 'package:flutter/services.dart' show rootBundle;
Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/eedw2.json');
}
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Map<int,String> _index2Day = new Map.fromIterables([0,1,2,3,4,5,6], ['Sun','Mon','Tue','Wed','Thur','Fri','Sat']);
  Map<int,String> _index2Month = new Map.fromIterables([1,2,3,4,5,6,7,8,9,10,11,12],
                                                    ['January','February','March',
                                                    'April','May','June','July',
                                                    'August','September','October',
                                                    'November','December']);
  DateTime _chosenDate = new DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
  DateTime _chosenReading = new DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
  String _chosenReadinString = '';

  //print(_chosenDate.toString());
  Map _plan = new Map();

  void _uploadPlan() async {
    String jsonString = await loadAsset();
//    print(jsonString);
//    File f = new File(jsonString);
//    jsonString = f.readAsStringSync();
    setState(() {
      _plan = json.decode(jsonString);
    });

    _viewThisDay(_chosenDate);
  }
  Future<void> _selectDate() async {//pick date to view in calender
    DateTime picked = await showDatePicker(context: context,
                                initialDate: new DateTime.now(),
                                firstDate: new DateTime(2018),
                                lastDate: new DateTime(2050)
                      );
    if(picked != null) {

      setState(() {
        _chosenDate = picked;
//        _chosenReading = picked;
      });
      _viewThisDay(_chosenDate);
    }
  }

  void _viewThisDay(DateTime thisDay) {//select current date to view it's reading
    int dayIndex = thisDay.difference(new DateTime(thisDay.year,1,1)).inDays;
    List readingList = List.from(_plan["${dayIndex}"]);

    setState(() {
      _chosenReadinString = readingList.join("\n");
      _chosenReading = thisDay;
    });
  }
  Center _calenderView(int index) {
    //function that takes index as input and generates a view of the calender for the reading plan


    Widget childWidget;
    if(index <= 6){
      childWidget = Text(_index2Day[index],
          style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20),);
    }
    else {
      //handle the display of the dates.
      DateTime monthChosenStart = DateTime(_chosenDate.year,_chosenDate.month,1);

      int firstMonthWeekDay = monthChosenStart.weekday;
      DateTime currentDate;
      int daysValue = index - 7 - firstMonthWeekDay;
      if(daysValue < 0)
        currentDate = monthChosenStart.subtract(new Duration(days: daysValue.abs()));
      else
        currentDate = monthChosenStart.add(new Duration(days: daysValue.abs()));
      childWidget = new FlatButton(onPressed: () => _viewThisDay(currentDate),color: currentDate.compareTo(_chosenReading) == 0 ? Colors.red : Colors.white,
              child: Text("${currentDate.day}"));
    }

    return Center(child: childWidget,);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title:
        new FlatButton(onPressed: _selectDate,padding: EdgeInsets.all(0),
          child: new Text("${_index2Month[_chosenDate.month]}, ${_chosenDate.year}",
            style: TextStyle(fontSize: 25),),),
      ),
      body: Container(
        //padding: EdgeInsets.all(32.0),
        child:  Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            children: <Widget>[
              new Expanded(child: GridView.count(
                // Create a grid with 7 columns. If you change the scrollDirection to
                // horizontal, this would produce 7 rows.
                crossAxisCount: 7,
                // Generate 42 Widgets that display their index in the List
                children: List.generate(42, (index) {return _calenderView(index);
                }),
              )),
              new Expanded(child: new Text(_chosenReadinString,)),
            ],
          ),
        ),

      )
    );
  }

  @override
  void initState() {
    _uploadPlan();
//    print(Directory.current.path);
//    File f = new File('assets/eedw2.json');
//    String jsonString = f.readAsStringSync();
//    var jsonMap = json.decode(jsonString);
  }


}

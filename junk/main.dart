import 'dart:io';
// for step 3:
import 'dart:async';
import 'dart:convert';

List eventsList;
//import 'event_data.dart' show eventsList;

main() {
  eventsList = [];
  processRawData();

  //;
}

Map siteToShortName = {
  'Meadows Leisure Centre': 'MDW',
  'Bootle Leisure Centre': 'BLC',
  'Netherton Activity Centre': 'NAC',
  'Dunes': 'DSW',
  'Crosby Lakeside': 'CLAC',
};
Map dayToIndex = {
  'Monday': 0,
  'Tuesday': 1,
  'Wednesday': 2,
  'Thursday': 3,
  'Friday': 4,
  'Saturday': 5,
  'Sunday': 6,
};
Map<String, String> days = {
  'Mon': 'Monday',
  'Tue': 'Tuesday',
  'Wed': 'Wednesday',
  'Thu': 'Thursday',
  'Fri': 'Friday',
  'Sat': 'Saturday',
  'Sun': 'Sunday',
};
List<String> leisureCentreList = [
  'Meadows Leisure Centre',
  'Bootle Leisure Centre',
  'Netherton Activity Centre',
  'Dunes',
  'Crosby Lakeside',
];

void processClashes() {
  List tmp = [];
  List myDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List myPools = [
    'Learner',
    'Main',
    'Leisure',
  ];

  leisureCentreList.forEach((leisureCentre) {
    myDays.forEach((day) {
      tmp = eventsList
          .where((e) =>
              e["site"] == leisureCentre && e["isPool"] && e["day"] == day)
          .toList();
      myPools.forEach((pool) {
        tmp.forEach((a) {
          List compareTo = tmp
              .where((b) =>
                  ((a["finishDecimal"] > b["startDecimal"] &&
                      a["startDecimal"] < b["finishDecimal"])) &&
                  a["eventID"] < b["eventID"] &&
                  (a["poolName"] == b["poolName"]))
              .toList();
          if (compareTo.length > 0) {
            var aDuration = eventsList[a["eventID"]]["finishDecimal"] -
                eventsList[a["eventID"]]["startDecimal"];
            var bDuration = eventsList[compareTo[0]["eventID"]]
                    ["finishDecimal"] -
                eventsList[compareTo[0]["eventID"]]["startDecimal"];
            if (aDuration >= bDuration) {
              eventsList[a["eventID"]]["clash"] = 0;
              eventsList[compareTo[0]["eventID"]]["clash"] = 1;
            } else {
              eventsList[a["eventID"]]["clash"] = 1;
              eventsList[compareTo[0]["eventID"]]["clash"] = 0;
            }
          }
        });
      });
    });
  });
  File myFile = new File("blogg.dart");
  myFile.openWrite();
  String s = 'List x = ';
  s += json.encode(eventsList);
  s += ';';
  myFile.writeAsString(s);
  print(eventsList[10]);
}

void processRawData() {
  File data = new File("raw_data.txt");
  data.readAsLines().then(processLines).catchError((e) => handleError(e));
}

processLines(List<String> lines) {
  int eventID = 0;
  int i = 0;
  String currentDay = 'not set';

  //Map myEvent = {};

  while (i < lines.length) {
    //consume empty lines
    while (lines[i] == '') {
      i++;
    }

    if (lines[i] == 'Mon' ||
        lines[i] == 'Tue' ||
        lines[i] == 'Wed' ||
        lines[i] == 'Thu' ||
        lines[i] == 'Fri' ||
        lines[i] == 'Sat' ||
        lines[i] == 'Sun') {
      currentDay = days[lines[i]];
      i++;
    }

    //consume empty lines
    while (lines[i] == '') {
      i++;
    }

    var site = lines[i++];
    var name = lines[i++];
    var info = lines[i++];
    var time = lines[i++];
    var poolName = null;
    if (info.contains('Main')) {
      poolName = 'Main';
    }
    if (info.contains('Learner')) {
      poolName = 'Learner';
    }
    if (info.contains('Leisure')) {
      poolName = 'Leisure';
    }
    var type =
        info.contains('Pool') || name.contains('Swim') || name.contains('Aqua')
            ? 'pool'
            : 'class';
    bool isPool =
        info.contains('Pool') || name.contains('Swim') || name.contains('Aqua');
    bool isClass = !info.contains('Pool') || name == 'Swim Fit';
    bool youth = info.contains('Youth') ? true : false;
    Map x = {
      "eventID": eventID++,
      "site": site,
      "siteShortName": siteToShortName[site],
      "day": currentDay,
      "dayIndex": dayToIndex[currentDay],
      "shortName": shortName(name),
      "name": name,
      "youth": youth,
      "poolName": poolName,
      "type": type,
      "isPool": isPool,
      "isClass": isClass,
      "info": info,
      "start": time.split(' - ')[0],
      "finish": time.split(' - ')[1],
      "startDecimal": decimalTime(time.split(' - ')[0]),
      "finishDecimal": decimalTime(time.split(' - ')[1]),
      "clash": null,
    };
    eventsList.add(x);
  }
  print(eventsList.length);

  processClashes();
}

double decimalTime(s) {
  return double.parse(s.split(':')[0]) + double.parse(s.split(':')[1]) / 60;
}

String shortName(name) =>
    name.replaceAll('Les Mills ', '').replaceAll(' Virtual', '');

handleError(e) {
  print('];');
  print(e);
}

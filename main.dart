import 'dart:io';
import 'dart:convert';

List eventsList = [];
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
Map siteToShortName = {
  'Meadows Leisure Centre': 'MDW',
  'Bootle Leisure Centre': 'BLC',
  'Netherton Activity Centre': 'NAC',
  'Dunes': 'DSW',
  'Crosby Lakeside': 'CLAC',
  'Litherland Sports Park': 'LSP',
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
List filteredEventsList = [];

void main() => processRawData();

void processThings(Function fn) {
  leisureCentreList.forEach((leisureCentre) {
    myDays.forEach((day) {
      filteredEventsList = eventsList
          .where((e) =>
              e["site"] == leisureCentre && e["isPool"] && e["day"] == day)
          .toList();
      myPools.forEach((pool) {
        filteredEventsList.forEach((a) {
          fn(a);
        });
      });
    });
  });
  writeFile();
}

void processClash(a) {
   List compareTo = filteredEventsList
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
}

void processJoinEvents(a) {
   List compareTo = filteredEventsList
      .where((b) =>
           a["finishDecimal"] == b["startDecimal"]    &&
          a["name"] == b["name"] &&  a["pool"] == b["pool"])
      .toList();
  if (compareTo.length > 0) { 
    print ('needs joining ${a["day"]} ${a["start"]} ${compareTo[0]["finish"]} ${a["name"]} ${compareTo[0]["name"]} ${a["info"]} ${compareTo[0]["info"]}');
  }
}

void writeFile() {
  File myFile = new File("event_list.dart");
  myFile.openWrite();
  String s = 'List eventList = ';
  s += json.encode(eventsList);
  s += ';';
  myFile.writeAsString(s);
  print(eventsList[10]);
}

void processRawData() {
  File data = new File("raw_data.txt");
  data.readAsLines().then(processLines).catchError((e) => handleError(e));
}

void processLines(List<String> lines) {
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
    addEvent(eventID++, site, currentDay, name, youth, poolName, type, isPool, isClass, info, time);
  }
  print(eventsList.length);
  processThings(processClash);
  processThings(processJoinEvents);
}

void addEvent(int eventID, String site, String currentDay, String name, bool youth, poolName, String type, bool isPool, bool isClass, String info, String time) {
  Map x = {
    "eventID": eventID,
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

double decimalTime(s) {
  return double.parse(s.split(':')[0]) + double.parse(s.split(':')[1]) / 60;
}

String shortName(name) {
  return name.replaceAll('Les Mills ', '').replaceAll(' Virtual', '');
}

void handleError(e) {
  print('];');
  print(e);
}

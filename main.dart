import 'dart:io';
// for step 3:
import 'dart:async';
import 'dart:convert';
 List eventsList=[];
 
main() {
 
  processRawData();
 
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
 
   leisureCentreList.forEach((leisureCentre) {
    myDays.forEach((day) {
      tmp = eventsList
          .where((e) =>
              e["site"] == leisureCentre && e["isPool"] && e["day"] == day)
          .toList();

      tmp.forEach((a) {
       
        List compareTo = tmp
            .where((b) =>
                ((b["finishDecimal"] > a["startDecimal"] &&
                        b["finishDecimal"] < a["finishDecimal"]) ||
                    (b["startDecimal"] > a["startDecimal"] &&
                        b["startDecimal"] < a["startDecimal"]) ||
                    (b["startDecimal"] <= a["startDecimal"] &&
                        b["finishDecimal"] >= a["finishDecimal"])) &&
                a["eventID"] < b["eventID"] &&
                a["info"] == b["info"])
            .toList();
        if (compareTo.length > 0) {
      
          eventsList[a["eventID"]]["clash"] = 0;
          eventsList[compareTo[0]["eventID"]]["clash"] = 1;
        }
      });
    
    });
  });
  File myFile = new File("blogg.dart");
  myFile.openWrite();
  String s = 'List x = ';
  s+=json.encode(eventsList);
  s+=';';
  myFile.writeAsString(s);
   //print(json.encode(eventsList));
}

void processRawData() {
  File data = new File("raw_data.txt");
  data.readAsLines().then(processLines).catchError((e) => handleError(e));
}

processLines(List<String> lines) {
  int eventID = 0;
  int i = 0;
  String currentDay = 'not set';
  
  Map myEvent = {};

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

    //consume empty lines
    while (lines[i] == '') {
      i++;
    }

    var site = lines[i++];
    var name = lines[i++];
    var info = lines[i++];
    var time = lines[i++];
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

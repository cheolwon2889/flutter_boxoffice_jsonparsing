import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("박스오피스"),),
        body: MyBody(),
      ),
    );
  }
}

class MyBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyBodyState();
  }
}

class MyBodyState extends State<MyBody> {
  var sb = StringBuffer();

  // late StringBuffer sb;
  String MyDate = "2024-09-13";
  String result = "결과";
  String urlDate = "20240919";

  String boxoffice = "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=82ca741a2844c5c180a208137bb92bd7&targetDt=";

  void getBoxOffice() async {
    try {
      http.Response res = await http.get(Uri.parse(boxoffice+urlDate));
      if (res.statusCode == 200) {
        jsonParsing(res.body);
        setState(() {
          result = sb.toString();
          sb.clear();
        });
      }
    } catch (e) {
      setState(() {
        result = e.toString();
      });
    }
  }

  void jsonParsing(String jsonStr) {
    try {
      Map<String, dynamic> map = jsonDecode(jsonStr);
      for (dynamic mList in map['boxOfficeResult']["dailyBoxOfficeList"]) {
        print('${mList['rank']}위  ${mList['movieNm']}');
        sb.writeln('${mList['rank']}위  ${mList['movieNm']}');
        //MovieList(mList, mList);
      }
    } catch (e) {
      e.toString();
    }
  }

  void selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context, firstDate: DateTime(2016), lastDate: DateTime(2025));
    print(DateFormat('yyyyMMdd').format(picked ?? DateTime.now()));
    urlDate = DateFormat('yyyyMMdd').format(picked ?? DateTime.now());

    setState(() {
      MyDate = DateFormat('yyyy-MM-dd').format(picked ?? DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('날짜 : ${MyDate}'),
            IconButton(
                onPressed: selectDate, icon: Icon(Icons.date_range_rounded))
          ],
        ),
        ElevatedButton(onPressed: getBoxOffice, child: Text("주말 박스오피스 보기")),
        Text(result)
      ],
    );
  }
}

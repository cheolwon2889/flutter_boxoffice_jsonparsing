import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DatePickerExample(),
    );
  }
}

class DatePickerExample extends StatefulWidget {
  @override
  _DatePickerExampleState createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  DateTime? selectedDate;
  String? yyyymmddFormat;
  List<dynamic>? boxOfficeList; // JSON 데이터 리스트 저장

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        yyyymmddFormat = _formatDateToYYYYMMDD(selectedDate!);
      });
      await _fetchBoxOfficeData(yyyymmddFormat!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateToYYYYMMDD(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchBoxOfficeData(String date) async {
    final String apiKey = '82ca741a2844c5c180a208137bb92bd7';
    final String url =
        'http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=$apiKey&targetDt=$date';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          boxOfficeList =
              data['boxOfficeResult']['dailyBoxOfficeList']; // 데이터 파싱
        });
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('데이트 피커와 API 예제'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              selectedDate == null
                  ? '날짜를 선택하세요!'
                  : '선택된 날짜: ${_formatDate(selectedDate!)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('날짜 선택하기'),
            ),
            SizedBox(height: 10),
            if (boxOfficeList != null)
              Expanded(
                child: ListView.builder(
                  itemCount: boxOfficeList!.length,
                  itemBuilder: (context, index) {
                    final item = boxOfficeList![index];
                    return ListTile(
                      title: Text(
                          '${item['rank']}위 ${item['movieNm']}'), // 영화 순위와 제목 예매율
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:csv/csv.dart';

import 'dart:math' as math;

import 'package:tester/Tester.dart';
import 'package:tester/anim.dart';
import 'package:tester/animation.dart';
import 'package:tester/getcontoller.dart';
import 'package:tester/pie_chart.dart';

extension changer on int {
  toRadian() {
    return this * (math.pi / 180);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Checl());
  }
}

class Checl extends StatefulWidget {
  const Checl({Key? key}) : super(key: key);

  @override
  State<Checl> createState() => _CheclState();
}

class _CheclState extends State<Checl> {
  @override
  Widget build(BuildContext context) {
    final items = DummyDataService.getAccountDataList(context);
    final detailItems = DummyDataService.getAccountDetailList(context);
    final balanceTotal = sumAccountDataPrimaryAmount(items);

    getcontroller gtc = Get.put(getcontroller());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 500,
            child: RallyPieChart(
                heroLabel: "Total",
                segments: buildSegmentsFromAccountItems(items)),
          ),
          TextButton(
            onPressed: () {
              gtc.controller.forward();
            },
            child: Text("data"),
          )
        ],
      ),
    );
  }
}

class DummyDataService {
  static List<AccountData> getAccountDataList(BuildContext context) {
    return <AccountData>[
      const AccountData(
        name: "jaskd",
        primaryAmount: 1,
        accountNumber: '1234561234',
      ),
      const AccountData(
        name: "hljsdfka",
        primaryAmount: 1,
        accountNumber: '8888885678',
      ),
      const AccountData(
        name: "ljsa",
        primaryAmount: 1,
        accountNumber: '8888889012',
      ),
      const AccountData(
        name: "djkfj",
        primaryAmount: 1,
        accountNumber: '1231233456',
      ),
    ];
  }

  static List<UserDetailData> getAccountDetailList(BuildContext context) {
    return <UserDetailData>[
      UserDetailData(
        title: "rallyAccountDetailDataAnnualPercentageYield",
        value: percentFormat(context).format(0.001),
      ),
      UserDetailData(
        title: "rallyAccountDetailDataInterestRate",
        value: usdWithSignFormat(context).format(1676.14),
      ),
      UserDetailData(
        title: "rallyAccountDetailDataInterestYtd",
        value: usdWithSignFormat(context).format(81.45),
      ),
      UserDetailData(
        title: "rallyAccountDetailDataInterestPaidLastYear",
        value: usdWithSignFormat(context).format(987.12),
      ),
      UserDetailData(
        title: "rallyAccountDetailDataNextStatement",
        value: "",
      ),
      UserDetailData(
        title: "rallyAccountDetailDataAccountOwner",
        value: 'Philip Cao',
      ),
    ];
  }

  /// Percent formatter with two decimal points.

  /// Date formatter with year / number month / day.

}

class UserDetailData {
  UserDetailData({
    required this.title,
    required this.value,
  });

  /// The display name of this entity.
  final String title;

  /// The value of this entity.
  final String value;
}

NumberFormat percentFormat(BuildContext context, {int decimalDigits = 2}) {
  return NumberFormat.decimalPercentPattern(
    decimalDigits: decimalDigits,
  );
}

/// Currency formatter for USD.
NumberFormat usdWithSignFormat(BuildContext context, {int decimalDigits = 2}) {
  return NumberFormat.currency(
    name: '\$',
    decimalDigits: decimalDigits,
  );
}

double sumAccountDataPrimaryAmount(List<AccountData> items) =>
    sumOf<AccountData>(items, (item) => item.primaryAmount);

double sumOf<T>(List<T> list, double Function(T elt) getValue) {
  var sum = 0.0;
  for (var elt in list) {
    sum += getValue(elt);
  }
  return sum;
}


/* class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<List<dynamic>> fields = [];

  int _counter = 0;

  void _incrementCounter() async {
    /*  setState(() {
      _counter++;
    }); */

    var result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'xlsx']);
    print(result!.files.single.path);
    /*   final input = File(result.files.single.path!).openRead();
    print(input);
    fields = await input
        .transform(utf8.decoder)
        .transform(CsvToListConverter())
        .toList();
    print(fields); */

    var bytes = File(result.files.single.path!).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table]!.maxCols);
      print(excel.tables[table]!.maxRows);
      for (var row in excel.tables[table]!.rows) {
        print("${row}");
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            if (fields.isNotEmpty) ...[
              MyStatelessWidget(
                fields: fields,
              )
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  var fields;
  MyStatelessWidget({Key? key, required this.fields}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            'Name',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Age',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(
            'Role',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
      rows: <DataRow>[
        DataRow(
          cells: <DataCell>[
            DataCell(Text('hrejvg')),
            DataCell(Text('19')),
            DataCell(Text('Student')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('Janine')),
            DataCell(Text('43')),
            DataCell(Text('Professor')),
          ],
        ),
        DataRow(
          cells: <DataCell>[
            DataCell(Text('William')),
            DataCell(Text('27')),
            DataCell(Text('Associate Professor')),
          ],
        ),
      ],
    );
  }
}
 */
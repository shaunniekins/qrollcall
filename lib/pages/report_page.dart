import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<List<String>> scans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final scanStrings = prefs.getStringList('scans') ?? [];
    final newScans = <List<String>>[];
    for (final scan in scanStrings) {
      final parts = scan.split(',');
      if (parts.length == 3) {
        newScans.add(parts);
      }
    }

    // Sort the scans by date and time in descending order
    newScans.sort((a, b) {
      final dateA = DateTime.parse('${a[0]} ${a[1]}');
      final dateB = DateTime.parse('${b[0]} ${b[1]}');
      return dateB.compareTo(dateA);
    });

    setState(() {
      scans = newScans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text('Date'),
              ),
              DataColumn(
                label: Text('Time'),
              ),
              DataColumn(
                label: Text('QR Code'),
              ),
            ],
            rows: scans
                .map((scan) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(scan[0])),
                        DataCell(Text(scan[1])),
                        DataCell(Text(scan[2])),
                      ],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<List<String>> scans = [];
  List<List<String>> filteredScans = [];
  String searchQuery = '';
  FocusNode searchFocusNode = FocusNode();
  TextEditingController searchController = TextEditingController();

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
    // Filter the scans list based on the search query.
    filteredScans = scans
        .where((scan) => scan.any((item) => item.contains(searchQuery)))
        .toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  searchFocusNode.unfocus();
                },
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  hintStyle: const TextStyle(fontSize: 14.0),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverStickyHeader(
                      header: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16.0)),
                        child: Container(
                          height: 60.0,
                          color: Colors.purple[100],
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          alignment: Alignment.centerLeft,
                          child: const ListTile(
                            title: Text(
                              'QR Code',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            leading: Text('Date    ',
                                style: TextStyle(color: Colors.black)),
                            trailing: Text('Time',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) async {
                              // Store the item and its index before removing it.
                              List<String> deletedScan = scans[i];
                              int deletedIndex = i;

                              // Remove the item from the list.
                              scans.removeAt(i);

                              // Convert the updated list back to a format that can be stored in SharedPreferences.
                              List<String> updatedScanStrings =
                                  scans.map((scan) => scan.join(',')).toList();

                              // Save the updated list to SharedPreferences.
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setStringList('scans', updatedScanStrings);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Item dismissed"),
                                  action: SnackBarAction(
                                    label: 'CANCEL',
                                    onPressed: () async {
                                      // Restore the deleted item.
                                      scans.insert(deletedIndex, deletedScan);
                                      List<String> restoredScanStrings = scans
                                          .map((scan) => scan.join(','))
                                          .toList();
                                      await prefs.setStringList(
                                          'scans', restoredScanStrings);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );

                              setState(() {});
                            },
                            child: ListTile(
                              title: Text(
                                filteredScans[i][2],
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              leading: Text(
                                filteredScans[i][0],
                              ),
                              trailing: Text(filteredScans[i][1]),
                            ),
                          ),
                          childCount: filteredScans.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

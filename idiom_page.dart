import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'key_model.dart';

class ABBProvider with ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  List<IdiomModel> data = [];
  List<IdiomModel> filteredData = [];
  List<IdiomModel> paginatedData = [];
  int currentPage = 1;
  int pageSize = 100;
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();
  Stream<bool> get loadingStream => _loadingController.stream;
  int crossAxisCount = 2; // Added crossAxisCount property

  ABBProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _loadingController.add(true);

    try {
      String jsonString =
          await rootBundle.loadString('assets/json/dict_idiom.json');
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      data = jsonData.entries
          .map((entry) => IdiomModel(
              key: entry.key, values: List<String>.from(entry.value)))
          .toList();
      filteredData = List.from(data);
    } catch (error) {
      // Handle the error, if any.
    }

    paginateData();

    _loadingController.add(false);
    notifyListeners();
  }

  void paginateData() {
    int totalItems = filteredData.length;
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = startIndex + pageSize;

    paginatedData = filteredData.sublist(
      startIndex.clamp(0, totalItems),
      endIndex.clamp(0, totalItems),
    );

    notifyListeners();
  }

  void filterData(String keyword) {
    filteredData = data.where((item) {
      String keyWithoutDot = item.key;
      return keyWithoutDot.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
    currentPage = 1;
    paginateData();

    notifyListeners();
  }

  void jumpToPage(int page) {
    if (page >= 1 && page <= getTotalPages()) {
      currentPage = page;
      paginateData();
    } else {
      currentPage = 1;
    }

    notifyListeners();
  }

  int getTotalPages() {
    return (filteredData.length / pageSize).ceil();
  }

  Future<void> loadMoreData() async {
    if (currentPage < getTotalPages()) {
      await Future.delayed(const Duration(seconds: 2));

      currentPage++;

      paginateData();
    }
  }

  void dispose() {
    _loadingController.close();
    super.dispose();
  }
}

class IdiomPage extends StatelessWidget {
  const IdiomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ABBProvider>(
      create: (_) => ABBProvider(),
      builder: (context, _) {
        return _IdiomPageContent();
      },
    );
  }
}

class _IdiomPageContent extends StatefulWidget {
  @override
  _IdiomPageContentState createState() => _IdiomPageContentState();
}

class _IdiomPageContentState extends State<_IdiomPageContent> {
  late ABBProvider _abbProvider;
  late StreamSubscription<bool> _loadingSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _abbProvider = Provider.of<ABBProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _abbProvider.loadData();
    });

    _loadingSubscription = _abbProvider.loadingStream.listen((isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    });
  }

  @override
  void dispose() {
    _loadingSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;

    if (screenWidth <= 600) {
      crossAxisCount = 2;
    } else if (screenWidth <= 1200) {
      crossAxisCount = 4;
    } else {
      crossAxisCount = 8;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('IDIOM'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Color(0xFF191414),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _abbProvider.searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _abbProvider.filterData(value);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Consumer<ABBProvider>(
                      builder: (context, provider, _) {
                        return ListView.builder(
                          itemCount: provider.paginatedData.length,
                          itemBuilder: (BuildContext context, int index) {
                            IdiomModel idiomModel =
                                provider.paginatedData[index];
                            Color randomColor =
                                Color(Random().nextInt(0xFFFFFFFF));
                            return GestureDetector(
                              onTap: () {},
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: randomColor,
                                    child: Text(
                                      idiomModel.key[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "${idiomModel.key}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: SingleChildScrollView(
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('List'),
                                              content: Container(
                                                width: double.maxFinite,
                                                child: GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      ClampingScrollPhysics(),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        crossAxisCount,
                                                    childAspectRatio: 2.0,
                                                  ),
                                                  itemCount:
                                                      idiomModel.values.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    Color randomColor = Color(
                                                        Random().nextInt(
                                                            0xFFFFFFFF));
                                                    return Card(
                                                      color: randomColor,
                                                      child: Center(
                                                        child: Text(
                                                          idiomModel
                                                              .values[index],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                            fontSize: 16.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('Close'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        idiomModel.values.join("\n"),
                                      
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      List<String> allSentences =
                                          idiomModel.values.toList();

                                      

                                      String combinedSentence =
                                          "${allSentences.join('\n')}";

                                      Clipboard.setData(ClipboardData(
                                          text: combinedSentence.replaceAll(
                                              '.', '')));

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Text copied to clipboard'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.copy_all,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16.0),
            Consumer<ABBProvider>(
              builder: (context, provider, _) {
                int totalPages = provider.getTotalPages();
                int currentPage = provider.currentPage;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: currentPage == 1
                          ? null
                          : () => provider.jumpToPage(currentPage - 1),
                    ),
                    Text('$currentPage / $totalPages'),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: currentPage == totalPages
                          ? null
                          : () => provider.jumpToPage(currentPage + 1),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

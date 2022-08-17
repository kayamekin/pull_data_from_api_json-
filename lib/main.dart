// import 'package:disney_channel/screens/homepage.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePageWidget(),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  // List<String> stringListesi = [
  //   'ahmet',
  //   'mehmet',
  //   'ismail',
  //   'ahmet',
  //   'mehmet',
  //   'ismail',
  //   'ahmet',
  //   'mehmet',
  //   'ismail',
  //   'ahmet',
  //   'mehmet',
  //   'ismail',
  //   'ahmet',
  //   'mehmet',
  //   'ismail',
  // ];

  final _url = 'https://jsonplaceholder.typicode.com/posts';

  int _page = 0;

  final int _limit = 20;

  bool _isFirstLoad = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;

  List _posts = [];

  void _loadMore() async {
    if (_hasNextPage == true && _isFirstLoad == false && _isLoadMoreRunning) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      setState(() {
        _isLoadMoreRunning = false;
      });

      try {
        final res =
            await http.get(Uri.parse("$_url?_page=$_page&_limit=$_limit"));

        final List fetchedPostsJson = json.decode(res.body);
        if (fetchedPostsJson.isNotEmpty) {
          setState(() {
            _posts.addAll(fetchedPostsJson);
          });
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print('Something went wrong!');
        }
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  void _firstLoad() async {
    setState(() {
      _isFirstLoad = true;
    });

    try {
      final res =
          await http.get(Uri.parse("$_url?_pages = $_page&_limit = $_limit"));
      setState(() {
        _posts = json.decode(res.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print("Sayfa çalışmıyor");
      }
    }

    setState(() {
      _isFirstLoad = false;
    });
  }

  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("api ile veri çekme"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: _isFirstLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: _controller,
                      shrinkWrap: true,
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 20,
                            ),
                            child: ListTile(
                              leading: Text(_posts[index]['id'].toString()),
                              title: Text(_posts[index]['title']),
                              subtitle: Text(_posts[index]['body']),
                            ),
                          ),
                        );
                      }),
                ),
                if (_isLoadMoreRunning == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (_hasNextPage == false)
                  Container(
                      padding: EdgeInsets.only(top: 30, bottom: 40),
                      color: Colors.amber,
                      child: const Center(
                        child: Text('Sayfa sonu içerik bitti'),
                      ))
              ],
            ),
    );
  }
}

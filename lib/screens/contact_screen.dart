import 'dart:math';

import 'package:assessment/services/json_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with TickerProviderStateMixin {
  SharedPreferences? prefs;
  List? contacts;
  final List _suggestions = [];
  final ScrollController _scrollController = ScrollController();
  int takeIndex = 10;
  late TabController tabController;


  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    setUp();
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        if (_suggestions.length < contacts!.length) {
          loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.black38,
          selectedItemColor: Colors.black,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (int index) {},
          currentIndex: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.phone_outlined), label: "fdafds"),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "adsfsd"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                label: "adsfsd"),
            BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined), label: "fdafds"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: "adsfsd"),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onPressed: () {},
          child: const Icon(Icons.phone_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          title: const Text(
            "Calls",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: (() => setState(() {
                      if (prefs!.getBool('normalTime') == null) {
                        prefs!.setBool('normalTime', true);
                      } else {
                        prefs!.setBool(
                            'normalTime', !prefs!.getBool('normalTime')!);
                      }
                    })),
                icon: const Icon(
                  Icons.av_timer_outlined,
                  color: Colors.black,
                ))
          ],
        ),
        body: Column(
          children: [
            TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                unselectedLabelColor: Colors.black45,
                controller: tabController,
                tabs: const [
                  Tab(
                    child: Text("All"),
                  ),
                  Tab(
                    child: Text("Placed"),
                  ),
                  Tab(
                    child: Text("Received"),
                  ),
                  Tab(
                    icon: Icon(Icons.more_horiz),
                  ),
                ]),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  contacts == null
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: loadRandomData,
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: _scrollController,
                              itemCount: _suggestions.length + 1,
                              itemBuilder: (context, index) {
                                if (index < _suggestions.length) {
                                  return ListTile(
                                    leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: const Color(0xfff0547b),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: const Icon(
                                          Icons.phone_callback_outlined,
                                          color: Colors.white,
                                        )),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          flex: 9,
                                          child: Text(
                                            _suggestions[index]['user'],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          setTime(
                                              _suggestions[index]['check-in']),
                                          style: const TextStyle(
                                              color: Colors.black38,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    subtitle:
                                        Text(_suggestions[index]['phone']),
                                    trailing: IconButton(
                                      onPressed: () {
                                        Share.share(
                                            _suggestions[index].toString());
                                      },
                                      icon: const Icon(Icons.share),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 50),
                                        child: index >= contacts!.length
                                            ? const Text(
                                                "You have reached end of the list")
                                            : const CircularProgressIndicator()),
                                  );
                                }
                              }),
                        ),
                  const SizedBox(),
                  const SizedBox(),
                  const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future loadRandomData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      int last = contacts!.length;
      for (var i = 0; i < 5; i++) {
        int index = Random().nextInt(last);
        _suggestions.add(contacts![index]);
        contacts!.add(contacts![index]);
      }
    });
  }

  loadMore() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _suggestions.addAll(contacts!.getRange(takeIndex, takeIndex + 5));
      takeIndex += 5;
    });
  }

  setTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    if (prefs!.getBool('normalTime') != null && prefs!.getBool('normalTime')!) {
      return DateFormat.yMd().format(dateTime);
    }
    return timeago.format(dateTime);
  }

  setUp() async {
    prefs = await SharedPreferences.getInstance();
    contacts = await JsonServices.loadJsonData("assets/contacts.json");
    contacts!.sort((a, b) {
      return (a['check-in'] as String).compareTo(b['check-in'] as String);
    });
    _suggestions.addAll(contacts!.take(10));
    setState(() {});
  }
}

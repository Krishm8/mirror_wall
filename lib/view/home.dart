import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/controller/home_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  String? search;
  String? bm;
  InAppWebViewController? inAppWebViewController;
  PullToRefreshController? pullToRefreshController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: StreamBuilder<List<ConnectivityResult>>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            var data = snapshot.data ?? [];
            bool isConnected = !data.contains(ConnectivityResult.none);
            if (!isConnected) {
              Future.delayed(
                Duration(seconds: 1),
                () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Connection"),
                        content: Text("No Internet available plz retry"),
                      );
                    },
                  );
                },
              );
            }
            return Center(
              child: Container(
                height: 20,
                width: 20,
                color: isConnected ? Colors.green : Colors.red,
              ),
            );
          },
        ),
        title: Text("My Browser"),
        actions: [
          Consumer<HomeProvider>(
            builder: (BuildContext context, HomeProvider value, Widget? child) {
              return InkWell(
                onTap: () {
                  value.changetheme();
                },
                child: Icon((value.theme == ThemeMode.light)
                    ? Icons.light_mode
                    : Icons.dark_mode),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: Provider.of<HomeProvider>(context,
                                    listen: false)
                                .bookmarklist
                                .map(
                                  (e) => ListTile(
                                    title: Text(bm ?? ""),
                                    subtitle: Text("$e"),
                                    trailing: InkWell(
                                        onTap: () {
                                          Provider.of<HomeProvider>(context,
                                                  listen: false)
                                              .bookmarklist
                                              .remove(e);
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.highlight_remove)),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text("All Bookmarks"),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Select Search Engine"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () async {
                                  await inAppWebViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: WebUri(
                                              "https://www.google.com/")));
                                  Provider.of<HomeProvider>(context,
                                          listen: false)
                                      .changeweb("https://www.google.com/");
                                  Navigator.pop(context);
                                },
                                title: Text("Google"),
                              ),
                              ListTile(
                                onTap: () async {
                                  await inAppWebViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: WebUri(
                                              "https://in.search.yahoo.com/")));
                                  Provider.of<HomeProvider>(context,
                                          listen: false)
                                      .changeweb(
                                          "https://in.search.yahoo.com/");
                                  Navigator.pop(context);
                                },
                                title: Text("Yahoo"),
                              ),
                              ListTile(
                                onTap: () async {
                                  await inAppWebViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url:
                                              WebUri("https://www.bing.com/")));
                                  Provider.of<HomeProvider>(context,
                                          listen: false)
                                      .changeweb("https://www.bing.com/");
                                  Navigator.pop(context);
                                },
                                title: Text("Bing"),
                              ),
                              ListTile(
                                onTap: () async {
                                  await inAppWebViewController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: WebUri(
                                              "https://duckduckgo.com/")));
                                  Provider.of<HomeProvider>(context,
                                          listen: false)
                                      .changeweb("https://duckduckgo.com/");
                                  Navigator.pop(context);
                                },
                                title: Text("Duck Duck Go"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    leading: Icon(Icons.screen_search_desktop_outlined),
                    title: Text("Search Engine"),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<HomeProvider>(
            builder: (BuildContext context, HomeProvider value, Widget? child) {
              if (value.webProgress == 1) {
                return SizedBox();
              } else {
                return LinearProgressIndicator(
                  value: value.webProgress,
                );
              }
            },
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  child: Consumer<HomeProvider>(
                    builder: (BuildContext context, HomeProvider value,
                        Widget? child) {
                      return InAppWebView(
                        onWebViewCreated: (controller) {
                          inAppWebViewController = controller;
                        },
                        pullToRefreshController: pullToRefreshController,
                        initialUrlRequest:
                            URLRequest(url: WebUri("${value.searchengine}")),
                        onLoadStart: (controller, url) {
                          Provider.of<HomeProvider>(context, listen: false)
                              .onChangeLoad(true);
                        },
                        onLoadStop: (controller, url) {
                          Provider.of<HomeProvider>(context, listen: false)
                              .onChangeLoad(false);
                        },
                        onProgressChanged: (controller, progress) {
                          Provider.of<HomeProvider>(context, listen: false)
                              .onWebProgress(progress / 100);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Consumer<HomeProvider>(
            builder: (BuildContext context, HomeProvider homeProvider,
                Widget? child) {
              return TextFormField(
                decoration: InputDecoration(
                  hintText: "Search here",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onFieldSubmitted: (value) {
                  bm = value;
                  if (homeProvider.searchengine == "https://duckduckgo.com/") {
                    search = "${homeProvider.searchengine}?va=c&t=hn&q=$value";
                  } else {
                    search = "${homeProvider.searchengine}search?q=$value";
                  }

                  inAppWebViewController?.loadUrl(
                      urlRequest: URLRequest(url: WebUri(search ?? "")));
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          page = value;
          if (page == 0) {
            inAppWebViewController?.loadUrl(
              urlRequest: URLRequest(
                url: WebUri(Provider.of<HomeProvider>(context, listen: false)
                    .searchengine),
              ),
            );
          } else if (page == 1) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Bookmark added")));
            Provider.of<HomeProvider>(context, listen: false)
                .bookmarklist
                .add(search);
          } else if (page == 2) {
            inAppWebViewController?.goBack();
          } else if (page == 3) {
            inAppWebViewController?.reload();
          } else if (page == 4) {
            inAppWebViewController?.goForward();
          }
          setState(() {});
        },
        currentIndex: page,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_add), label: "Bookmark"),
          BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_arrow_left), label: "Back"),
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: "Refresh"),
          BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_arrow_right), label: "Next"),
        ],
      ),
    );
  }
}

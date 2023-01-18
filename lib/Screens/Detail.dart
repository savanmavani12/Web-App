import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_app/Global/Global.dart';



class WebApp extends StatefulWidget {
  const WebApp({Key? key}) : super(key: key);

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  String url = "";
  final urlController = TextEditingController();
  late final String web;

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            Expanded(
              flex: 2,
              child: IconButton(
                onPressed: () {
                  webViewController?.goBack();
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const Spacer(flex: 1),
            Expanded(
              flex: 2,
              child: IconButton(
                icon: const Icon(Icons.menu_outlined),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Center(
                            child: Text('All Bookmarks',
                                style: TextStyle(color: Colors.green))),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: ListView.separated(
                            itemCount: Global.bookMarksList.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  webViewController?.loadUrl(
                                    urlRequest: URLRequest(
                                      url: Uri.parse(Global.bookMarksList[i]),
                                    ),
                                  );
                                },
                                title: Text(
                                  Global.bookMarksList[i],
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                  const TextStyle(color: Colors.blueAccent),
                                ),
                              );
                            },
                            separatorBuilder: (context, i) {
                              return const Divider(
                                color: Colors.black,
                                endIndent: 30,
                                indent: 30,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Global.bookMarksList.add(url);
              Global.bookMarksList = Global.bookMarksList.toSet().toList();
            },
            icon: const Icon(Icons.bookmark),
          ),
          IconButton(
            onPressed: () {
              webViewController?.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse(web),
                ),
              );
            },
            icon: const Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              webViewController?.goForward();
            },
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Center(
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(
            url: Uri.parse("https://www.google.co.in/"),
          ),
          initialOptions: options,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController.endRefreshing();
            setState(
                  () {
                this.url = url.toString();
                urlController.text = this.url;
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          webViewController?.reload();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey webViewKey = GlobalKey();
  String? useCookieString;
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      // isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllowFullscreen: true,
);
  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void onMatchedCookie(String cookieString) {
    Navigator.of(context).pop(cookieString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (webViewController != null) {
                webViewController!.goBack();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              if (webViewController != null) {
                webViewController!.goForward();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (webViewController != null) {
                webViewController!.reload();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest:
                  URLRequest(url: WebUri("https://app.suno.ai/")),
              initialSettings: settings,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT);
              },
              // shouldOverrideUrlLoading:
              //     (controller, navigationAction) async {
              //   var uri = navigationAction.request.url!;
              //
              //   if (![
              //     "http",
              //     "https",
              //     "file",
              //     "chrome",
              //     "data",
              //     "javascript",
              //     "about"
              //   ].contains(uri.scheme)) {
              //     if (await canLaunchUrl(uri)) {
              //       // Launch the App
              //       await launchUrl(
              //         uri,
              //       );
              //       // and cancel the request
              //       return NavigationActionPolicy.CANCEL;
              //     }
              //   }
              //
              //   return NavigationActionPolicy.ALLOW;
              // },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
                final cookieManager = CookieManager.instance();
                final cookies = await cookieManager.getCookies(
                    url: WebUri("https://clerk.suno.ai/"));
                String cookieString = "";
                String matchCookieKey = "__client";
                bool isMatch = false;
                for (var cookie in cookies) {
                  if (cookie.name == matchCookieKey) {
                    isMatch = true;
                  }
                  print('Cookie name: ${cookie.name}, value: ${cookie.value}');
                  cookieString += "${cookie.name}=${cookie.value}; ";
                }
                if (isMatch) {
                  setState(() {
                    useCookieString = cookieString;
                  });
                  // onMatchedCookie(cookieString);
                }
                // print cookie string
              },
              onReceivedError: (controller, request, error) {
                pullToRefreshController?.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                }
                setState(() {
                  this.progress = progress / 100;
                  urlController.text = url;
                });
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print(consoleMessage);
              },
            ),
          ),
          Container(
              height: 64,
              width: double.infinity,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Container(
                padding: EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () {
                    if (useCookieString != null) {
                      onMatchedCookie(useCookieString!);
                    }
                  },
                  child: Text("Im' already logged in"),
                ),
              ))
        ],
      ),
    );
  }
}

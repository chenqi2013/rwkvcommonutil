// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// // import 'package:webview_flutter/webview_flutter.dart';
// import 'package:zemyeelife/components/basic/app_bar.dart';
// import 'package:zemyeelife/index.dart';
// import 'package:get/get.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatelessWidget {
  late InAppWebViewController _webViewController;
  final String url;

  WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: InAppWebView(
        //initialUrlRequest有的手机白屏，在下面使用onWebViewCreated中使用loadUrl初始化，
        // initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings:
            InAppWebViewSettings(allowsBackForwardNavigationGestures: true),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          _webViewController.loadUrl(
            urlRequest: URLRequest(url: WebUri(url)),
          );
        },
      ),
    );
  }
}

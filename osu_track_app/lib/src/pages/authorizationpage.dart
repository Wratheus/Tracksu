import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:osu_track_app/src/pages/error_page.dart';
import 'package:osu_track_app/src/pages/home_page.dart';
import '../pages/last_news_page.dart';

import '../requests/requests.dart';
import '../utils/secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  late StreamSubscription onDestroy;
  late StreamSubscription<String> _onUrlChanged;
  late StreamSubscription<WebViewStateChanged> _onStateChanged;

  String? token = '0';


  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
       print("destroy");
    });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
           print("onStateChanged: ${state.type} ${state.url}");
        });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (mounted) {
        print("URL changed: $url");
        if (url.startsWith('https://wratheus.github.io/Liz-to-Aoi-Tori-web-page/')) {
          RegExp regExp = RegExp("code=(.*)");
          this.token = regExp.firstMatch(url)?.group(1);
          var myToken = await getToken(token);
          UserSecureStorage.setTokenInStorage(myToken['access_token']);
          print(await UserSecureStorage.getTokenFromStorage());
          if (this.token != '0') {
            setState(() {
              flutterWebviewPlugin.close();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ErrorPage()));
            });
          }
        }
      }
    });
  }

  //Future<void> authorizeUser() async{

  //}

  @override
  Widget build(BuildContext context) {
    String loginUrl = "https://osu.ppy.sh/oauth/authorize?client_id=9725&redirect_uri=https://wratheus.github.io/Liz-to-Aoi-Tori-web-page/&response_type=code";

    return WebviewScaffold(
        url: loginUrl,
        appBar: AppBar(
          title: const Text("Login to osu OAuth..."),
          leading: Image.asset('assets/cloud_logo.png'),
        ));
  }
}
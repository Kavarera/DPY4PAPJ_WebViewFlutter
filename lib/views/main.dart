import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ujianku/widgets/confrimation_exit_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewMain extends StatefulWidget {
  final String targetURLParams;

  const WebViewMain({super.key, required this.targetURLParams});

  @override
  State<WebViewMain> createState() => _WebViewMainState();
}

class _WebViewMainState extends State<WebViewMain> with WidgetsBindingObserver {
  final wvController = WebViewController();
  final wvcm = WebViewCookieManager();
  String targetURL = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        wvcm.clearCookies();
        wvController.clearCache();
        wvController.clearLocalStorage();
        break;
      case AppLifecycleState.detached:
        wvcm.clearCookies();
        wvController.clearCache();
        wvController.clearLocalStorage();
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    targetURL = widget.targetURLParams;
    wvController.setJavaScriptMode(JavaScriptMode.unrestricted);
    wvController.clearCache();
    wvController.clearLocalStorage();
    wvcm.clearCookies();
    wvController.loadRequest(Uri.parse(targetURL));
    return PopScope(
      canPop: false,
      onPopInvoked: (bool dipdop) async {
        if (await wvController.canGoBack() == true) {
          wvController.goBack();
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              WebViewWidget(
                controller: wvController,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.elliptical(20, 30),
                    ),
                    child: BottomNavigationBar(
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.white,
                      showSelectedLabels: true,
                      elevation: 25,
                      showUnselectedLabels: true,
                      backgroundColor: Colors.black,
                      type: BottomNavigationBarType.fixed,
                      onTap: (int index) async {
                        switch (index) {
                          case 0:
                            final result = await showDialog<bool>(
                                context: context,
                                builder: (context) =>
                                    const ConfirmationExitWidget());
                            if (result == true) {
                              Navigator.pop(context);
                            }
                            break;
                          case 1:
                            wvController.reload();
                            break;
                          case 2:
                            wvController.goBack();
                            print("Go backward");
                            break;
                          case 3:
                            wvController.goForward();
                            print("Go forward");
                            break;
                          default:
                            break;
                        }
                      },
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.exit_to_app_sharp,
                          ),
                          label: "Exit",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.refresh,
                          ),
                          label: "Refresh",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.arrow_back_ios_new_sharp,
                          ),
                          label: "Backward",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.arrow_forward_ios_sharp,
                          ),
                          label: "Forward",
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

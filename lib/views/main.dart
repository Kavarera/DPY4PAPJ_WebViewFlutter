import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ujianku/widgets/qrview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewMain extends StatefulWidget {
  const WebViewMain({super.key});

  @override
  State<WebViewMain> createState() => _WebViewMainState();
}

class _WebViewMainState extends State<WebViewMain> with WidgetsBindingObserver {
  final wvController = WebViewController();
  final wvcm = WebViewCookieManager();
  bool qrScanned = false;
  late QRViewController qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String targetUrl = "https://ujianmu.my.id";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);

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
    qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    wvController.setJavaScriptMode(JavaScriptMode.unrestricted);
    wvController.clearCache();
    wvController.clearLocalStorage();
    wvcm.clearCookies();
    wvController.loadRequest(Uri.parse(targetUrl));
    return PopScope(
      canPop: false,
      onPopInvoked: (bool dipdop) async {
        if (await wvController.canGoBack() == true) {
          wvController.goBack();
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      qrScanned = !qrScanned;
                    });
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.black,
                  )),
              IconButton(
                  onPressed: () {
                    wvController.reload();
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.black,
                  ))
            ],
          ),
          body: Stack(
            children: [
              WebViewWidget(
                controller: wvController,
              ),
              Visibility(
                visible: qrScanned,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: (controller) {
                    this.qrController = controller;
                    controller.scannedDataStream.listen((event) {
                      setState(() {
                        qrScanned = false;
                        targetUrl = event.code!;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(event.code!),
                        duration: Duration(seconds: 1),
                      ));

                      wvController.loadRequest(Uri.parse(targetUrl));
                    });
                  },
                  overlay: QrScannerOverlayShape(
                      borderColor: Colors.white,
                      borderWidth: 10,
                      borderLength: 10,
                      borderRadius: 20,
                      cutOutSize: MediaQuery.of(context).size.width * 0.8),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

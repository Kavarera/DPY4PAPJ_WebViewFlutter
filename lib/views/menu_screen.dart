import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ujianku/views/main.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late QRViewController? qrViewController;
  bool qrScanned = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int _counter = 0;
  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  TextEditingController _TextURLController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: qrScanned == true ? Colors.transparent : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          title: const Text(
            "UJIANMU",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3),
          ),
          centerTitle: true,
        ),
        body: Stack(children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _TextURLController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                            color: Colors.blueAccent, width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                            color: Colors.blueAccent, width: 3),
                      ),
                      hintText: "What's the URL Again?",
                      hintStyle: const TextStyle(
                        color: Colors.blueAccent,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          print(_TextURLController.text);
                          _navigateToWVFromScan(_TextURLController.text);
                        },
                        icon: const Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),
                    child: Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 5,
                              ),
                              onPressed: () {
                                setState(() {
                                  qrScanned = !qrScanned;
                                });
                              },
                              child: const Text(
                                "SCAN QR",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              size: 200,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Visibility(
            visible: qrScanned,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: (controller) {
                    controller.scannedDataStream.listen((event) async {
                      qrViewController = controller;
                      setState(() {
                        qrScanned = false;
                      });
                      //Going to mainwebview
                      await controller.pauseCamera();
                      await _navigateToWVFromScan(event.code!);
                    });
                  },
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.white,
                    borderWidth: 5,
                    borderLength: 5,
                    borderRadius: 5,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          qrScanned = !qrScanned;
                        });
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }

  Future<void> _navigateToWVFromScan(String s) async {
    if (Uri.parse(s).isAbsolute) {
      print("\nO\nT\nW\n\nW\nV");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewMain(targetURLParams: s),
        ),
      ).then((_) {
        qrViewController?.stopCamera();
        qrViewController?.dispose();
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner_example/qr_scanner.dart';
import 'package:qr_code_scanner_example/qr_scanner_mlkit.dart';

void main() => runApp(MaterialApp(
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      /* dark theme settings */
    ),
    themeMode: ThemeMode.dark,
    home: MainScreen()));

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center, //Center Column contents vertically,
          crossAxisAlignment: CrossAxisAlignment.center, //Center Column contents horizontally,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, //Center Column contents vertically,
              crossAxisAlignment: CrossAxisAlignment.center, //C
              children: [
                Icon(Icons.qr_code),
                Text('QR Code Scanner',
                style: TextStyle(
                  fontSize: 24
                ),)
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: ListView(
              children:
              [
                ListTile(
                  title: Text('Default: ZXING & mkbarcode scanner'),
                  subtitle: Text('Available on Android & iOS.'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerExample())),
                ),
                Divider(),
                ListTile(
                  title: Text('ALPHA: MLKit Scanner'),
                  subtitle: Text('Only available on Android!'),
                  onTap: QRScanner.scanBarcode,
                ),
                Divider(),
                ListTile(
                  title: Text('ALPHA: MLKit Scanner Native View'),
                  subtitle: Text('Only available on Android!'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerExampleMLKit())),
                ),
                Divider(),
              ],
            )
          )
        ],
      ),
    );
  }

}

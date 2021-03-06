import 'dart:typed_data';
import 'package:sogasoarventures/bloc/future_values.dart';
import 'package:sogasoarventures/model/reportsDB.dart';
import 'package:sogasoarventures/networking/rest_data.dart';
import 'package:sogasoarventures/ui/navs/home_page.dart';
import 'package:sogasoarventures/utils/constants.dart';
import 'package:sogasoarventures/utils/round_icon.dart';
import 'package:sogasoarventures/utils/size_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_printer/esc_pos_printer.dart';

/// A StatefulWidget class that prints receipt of items recorded
class PrintingReceipt extends StatefulWidget {

  static const String id = 'printing_receipt';

  /// Passing the products recorded in this class constructor
  final List<Map> sentProducts;

  PrintingReceipt({@required this.sentProducts});

  @override
  _PrintingReceiptState createState() => _PrintingReceiptState();
}

class _PrintingReceiptState extends State<PrintingReceipt> {

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// A List to hold the Map of [sentProducts]
  List<Map> receivedProducts = [];

  /// Variable holding the total price
  double totalPrice = 0.0;

  /// A class [PrinterBluetoothManager] to handle bluetooth connection and
  /// sending of receipt through the package [esc_pos_printer]
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();

  /// A list of [PrinterBluetooth] holding the bluetooth devices
  /// available around you
  List<PrinterBluetooth> _devices = [];

  /// This adds the product details [sentProducts] to [receivedProducts] if it's
  /// not empty and calculate the total price [totalPrice]
  void _addProducts() {
    for (var product in widget.sentProducts) {
      if (product.isNotEmpty)  {
        receivedProducts.add(product);
        totalPrice += double.parse(product['totalPrice']);
      }
    }
  }

  /// Calls [_addProducts()] before the class builds its widgets
  @override
  void initState() {
    super.initState();
    _addProducts();
  }

  /// Function to build a ticket of [receivedProducts] using the
  /// package [esc_pos_printer]
  Future<Ticket> _showReceipt() async{
    Ticket ticket = Ticket(PaperSize.mm58);

    // Print image
    final ByteData data = await rootBundle.load('Assets/images/ayole-logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image image = decodeImage(bytes);
    ticket.image(image);

    ticket.text('BizGenie Limited',
        styles: PosStyles(
          align: PosTextAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    ticket.text('56, Olumegbon Rd Gbaja', styles: PosStyles(align: PosTextAlign.center));
    ticket.text('Surulere Lagos', styles: PosStyles(align: PosTextAlign.center));
    ticket.text('08025013518, 09072222068', styles: PosStyles(align: PosTextAlign.center));
    ticket.text('mbkosoko@yahoo.com',
        styles: PosStyles(align: PosTextAlign.center), linesAfter: 1);
    ticket.emptyLines(1);

    ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 2, styles: PosStyles(align: PosTextAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosTextAlign.right)),
    ]);

    for(var item in receivedProducts){
      ticket.row([
        PosColumn(text: '${item['qty']}', width: 1),
        PosColumn(text: '${item['product']}', width: 7),
        PosColumn(
            text: '${item['unitPrice']}', width: 2, styles: PosStyles(align: PosTextAlign.right)),
        PosColumn(
            text: '${item['totalPrice']}', width: 2, styles: PosStyles(align: PosTextAlign.right)),
      ]);
    }

    ticket.emptyLines(1);

    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '${Constants.money(totalPrice)}',
          width: 6,
          styles: PosStyles(
            align: PosTextAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    ticket.emptyLines(2);
    //ticket.hr(ch: '=', linesAfter: 1);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosTextAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp, styles: PosStyles(align: PosTextAlign.center), linesAfter: 2);

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Printer"),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context,position){
          return ListTile(
            onTap: () async {
              printerManager.selectPrinter(_devices[position]);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 0.0,
                  child: Container(
                    width: SizeConfig.safeBlockHorizontal * 60,
                    height: 150.0,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              "Are you sure the product you want to print is confirmed?",
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // To close the dialog
                                },
                                textColor: Colors.blue[900],
                                child: Text('NO'),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // To close the dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (_) => Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16.0),
                                      ),
                                      elevation: 0.0,
                                      child: Container(
                                        width: SizeConfig.safeBlockHorizontal * 60,
                                        height: 150.0,
                                        padding: EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16.0),
                                                child: Text(
                                                  "Select payment mode",
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.bottomLeft,
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // To close the dialog
                                                      _showReceipt().then((ticketValue){
                                                        printerManager.printTicket(ticketValue).then((result) {
                                                          Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.msg)));
                                                          if(result.msg == "Success"){
                                                            _saveProduct("Transfer");
                                                          }
                                                        }).catchError((error){
                                                          Scaffold.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                                                        });
                                                      });
                                                    },
                                                    textColor: Colors.blue[900],
                                                    child: Text('Transfer'),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.bottomLeft,
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // To close the dialog
                                                      _showReceipt().then((ticketValue){
                                                        printerManager.printTicket(ticketValue).then((result) {
                                                          Scaffold.of(context).showSnackBar(SnackBar(content: Text(result.msg)));
                                                          if(result.msg == "Success"){
                                                            _saveProduct("Cash");
                                                          }
                                                        }).catchError((error){
                                                          Scaffold.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
                                                        });
                                                      });
                                                    },
                                                    textColor: Colors.blue[900],
                                                    child: Text('Cash'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                textColor: Colors.blue[900],
                                child: Text('YES'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            title: Text(_devices[position].name),
            subtitle: Text(_devices[position].address),
          );
        },
      ),
      floatingActionButton: RoundIconButton(
        onPressed: () {
          printerManager.startScan(Duration(seconds: 4));
          printerManager.scanResults.listen((scannedDevices) {
            if (!mounted) return;
            setState(() {
              _devices = scannedDevices;
            });
            if(_devices.isEmpty){
              Constants.showMessage('No Available Printer');
            }
          }).onError((handleError){
            Constants.showMessage('${handleError.toString()}');
          });
        },
        icon: Icons.search,
      )
    );
  }

  /// This function calls [saveNewDailyReport()] with the details in
  /// [receivedProducts]
  void _saveProduct(String paymentMode) async {
    if(receivedProducts.length > 0 && receivedProducts.isNotEmpty){
      for (var product in receivedProducts) {
        try {
          await _saveNewDailyReport(
              double.parse(
                  product[
                  'qty']),
              product[
              'product'],
              double.parse(product[
              'costPrice']),
              double.parse(product[
              'unitPrice']),
              double.parse(product[
              'totalPrice']),
              paymentMode)
              .then((value){
            Constants.showMessage("${product['product']} was sold successfully");
          });
        } catch (e) {
          print(e);
          Constants.showMessage(e.toString());
        }
      }
      Navigator.popUntil(context, ModalRoute.withName(MyHomePage.id));
    }
    else {
      Constants.showMessage("Empty receipt");
      Navigator.pop(context);
    }
  }

  /// Function that adds new report to the database by calling
  /// [addNewDailyReport] in the [RestDataSource] class
  Future<void> _saveNewDailyReport(double qty, String productName, double costPrice, double unitPrice,
      double total, String paymentMode) async {
    try {
      var api = RestDataSource();
      var dailyReport = Reports();
      dailyReport.quantity = qty.toString();
      dailyReport.productName = productName.toString();
      dailyReport.costPrice = costPrice.toString();
      dailyReport.unitPrice = unitPrice.toString();
      dailyReport.totalPrice = total.toString();
      dailyReport.paymentMode = paymentMode;
      dailyReport.createdAt = DateTime.now().toString();

      await api.addNewDailyReport(dailyReport).then((value) {
        print('$productName saved successfully');
      }).catchError((e) {
        print(e);
        throw (e);
      });
    } catch (e) {
      print(e);
      throw (e);
    }
  }

}
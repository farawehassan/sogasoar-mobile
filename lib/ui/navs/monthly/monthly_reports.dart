import 'package:sogasoarventures/bloc/daily_report_value.dart';
import 'package:sogasoarventures/bloc/future_values.dart';
import 'package:sogasoarventures/model/reportsDB.dart';
import 'package:sogasoarventures/ui/navs/monthly/paginated_table.dart';
import 'package:sogasoarventures/ui/navs/monthly/products_sold_for_month.dart';
import 'package:sogasoarventures/utils/constants.dart';
import 'package:sogasoarventures/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A StatefulWidget class that displays a Month's Reports details
class MonthReport extends StatefulWidget {

  MonthReport({
    @required this.month,
    @required this.year,
    @required this.userType
  });

  static const String id = 'month_reports';

  final String month;

  final int year;

  final String userType;

  @override
  _MonthReportState createState() => _MonthReportState();
}

class _MonthReportState extends State<MonthReport> {

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// Instantiating a class of the [DailyReportValue]
  var reportValue = DailyReportValue();

  DateTime now = DateTime.now();

  /// Variable to hold the total SalesMade in [_Widget.month] report
  double _totalSalesPrice = 0.0;

  /// Variable to hold the total availableCash of [_Widget.month] report
  double _availableCash = 0.0;

  /// Variable to hold the outstanding payment in today's report
  double _outstandingPayment = 0.0;

  /// Variable to hold the total totalTransfer of [_Widget.month] report
  double _totalTransfer = 0.0;

  /// A variable holding the total profit made
  double _totalProfitMade = 0.0;

  /// A variable holding the length my monthly report data
  int _dataLength;

  /// List of reports for the [widget.month]
  List<Reports> monthReport = List();

  /// A TextEditingController to control the searchText on the AppBar
  final TextEditingController _filter = TextEditingController();

  /// Variable of String to hold the searchText on the AppBar
  String _searchText = "";

  /// Variable of List<Map> to hold the details of all the sales
  List<Map> _sales = List();

  /// Variable of List<Map> to hold the details of all filtered sales
  List<Map> _filteredSales = List();

  /// Variable to hold an Icon Widget of Search
  Icon _searchIcon = Icon(Icons.search);

  /// Variable to hold a Widget of Text for the appBarText
  Widget _appBarTitle;

  /// Checking if the filter controller is empty to reset the
  /// _searchText on the appBar to "" and the filteredSales to Sales
  _MonthReportState(){
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        if (!mounted) return;
        setState(() {
          _searchText = "";
          _filteredSales = _sales;
        });
      }
      else {
        if (!mounted) return;
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  /// Function to reset details of my [_totalProfitMade], [_totalSalesPrice],
  /// [_totalTransfer] and [_availableCash]
  void _resetTotalDetails(){
    if (!mounted) return;
    setState(() {
      _totalProfitMade = 0;
      _totalSalesPrice = 0;
      _availableCash = 0;
      _totalTransfer = 0;

      for (int i = 0; i < _filteredSales.length; i++){
        _totalProfitMade += double.parse(_filteredSales[i]['qty']) *
            (double.parse(_filteredSales[i]['unitPrice']) - double.parse(_filteredSales[i]['costPrice']));
        if(_filteredSales[i]['paymentMode'] == 'Cash'){
          _availableCash += double.parse(_filteredSales[i]['totalPrice']);
        }
        else if(_filteredSales[i]['paymentMode'] == 'Transfer'){
          _totalTransfer += double.parse(_filteredSales[i]['totalPrice']);
        }
      }
      _totalSalesPrice = _availableCash + _totalTransfer;

    });
  }

  /// Getting [_Widget.month] reports from the dailyReportsDatabase based on time
  /// Sets the details of the month and [_filteredSales] to [_sales]
  ///
  /// Increments [_availableCash] with the value of report's totalPrice,
  /// If the payment's mode of a report is cash
  ///
  /// Increments [_totalTransfer] with the value of report's totalPrice,
  /// If the payment's mode of a report is transfer
  ///
  /// sets [_totalSalesPrice] to [_availableCash] + [_totalTransfer]
  Future<void> _getSales() async {
    List<Map> tempList = List();
    Future<List<Reports>> reports = futureValue.getAllReportsFromDB();
    await reports.then((allReports) {
      List<Reports> value = futureValue.getMonthReports(widget.month, allReports, year: widget.year);
      if (!mounted) return;
      setState(() {
        monthReport.addAll(value);
        _dataLength = value.length;
        Map details = {};
        for (int i = 0; i < value.length; i++){
          _totalProfitMade += double.parse(value[i].quantity) * (double.parse(value[i].unitPrice) - double.parse(value[i].costPrice));
          details = {'id': value[i].id, 'qty':'${value[i].quantity}', 'productName': '${value[i].productName}', 'costPrice':'${value[i].costPrice}', 'unitPrice':'${value[i].unitPrice}','totalPrice':'${value[i].totalPrice}', 'paymentMode':'${value[i].paymentMode}', 'time':'${value[i].createdAt}', 'customerName':'${value[i].customerName}'};
          if(value[i].paymentMode == 'Cash'){
            _availableCash += double.parse(value[i].totalPrice);
          }
          else if(value[i].paymentMode == 'Transfer'){
            _totalTransfer += double.parse(value[i].totalPrice);
          }
          tempList.add(details);
        }
        _totalSalesPrice = _availableCash + _totalTransfer;
      });
    }).catchError((error){
      print(error);
      Constants.showMessage(error.toString());
    });
    if(!mounted)return;
    setState(() {
      _sales = tempList;
      _filteredSales = _sales;
    });
  }

  /// Function to get all the outstanding payment for [widget.month] and set the
  /// value to [_outstandingPayment]
  void _getOutstandingPayment() async {
    switch(widget.month) {
      case 'Jan': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.january));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Feb': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.february));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Mar': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.march));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Apr': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.april));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'May': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.may));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Jun': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.june));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Jul': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.july));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Aug': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.august));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Sep': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.september));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Oct': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.october));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Nov': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.november));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      case 'Dec': {
        Future<double> value = reportValue.getMonthOutstandingPayment(DateTime(widget.year, DateTime.december));
        value.then((value) {
          if (!mounted) return;
          setState(() {
            _outstandingPayment = value;
          });
        }).catchError((error){
          print(error);
          Constants.showMessage(error.toString());
        });
      }
      break;

      default: {
        if (!mounted) return;
        setState(() {
          _outstandingPayment = 0.0;
        });
        return null;
      }
      break;
    }
  }

  /// Function to change icons on the appBar when the searchIcon or closeIcon
  /// is pressed then sets the TextController to [_filter] and hintText of
  /// 'Search...' if it was the searchIcon or else it resets the AppBar to its
  /// normal state
  void _searchPressed() {
    if (!mounted) return;
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search...'
          ),
        );
      }
      else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text('${widget.month}, ${widget.year}');
        _filteredSales = _sales;
        _filter.clear();
      }
    });
  }

  /// A function to build the AppBar of the page by calling
  /// [_searchPressed()] when the icon is pressed
  Widget _buildBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF061D5C),
      centerTitle: false,
      title: _appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
        PopupMenuButton<String>(
            onSelected: (choice) {
              choiceAction(choice);
            },
            itemBuilder: (BuildContext context) {
              return Constants.showMonthChoices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            }
        ),
      ],
    );
  }

  /// A function to build the the list and send a list of map to build the
  /// data table by calling [_dataTable]
  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      List<Map> tempList = new List();
      for (int i = 0; i < _filteredSales.length; i++) {
        if (_getFormattedTime(_filteredSales[i]['time']).toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(_filteredSales[i]);
        }
      }
      _filteredSales = tempList;
    }
    if(_filteredSales.length > 0 && _filteredSales.isNotEmpty){
      _resetTotalDetails();
      return _dataTable(_filteredSales);
    }
    else if(_dataLength == 0){
      return Container(
        margin: EdgeInsets.all(20.0),
        alignment: AlignmentDirectional.center,
        child: Center(child: Text("No sales yet", style: TextStyle(fontSize: 20),)),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF061D5C)),
        ),
      ),
    );
  }

  /// Converting [dateTime] in string format to return a formatted time
  /// of hrs, minutes and am/pm
  String _getFormattedTime(String dateTime) {
    return DateFormat('EEE, MMM d, h:mm a').format(DateTime.parse(dateTime)).toString();
  }

  /// Creating a [DataTable] widget from a List of Map [salesList]
  /// using QTY, PRODUCT, UNIT, TOTAL, PAYMENT, TIME as DataColumn and
  /// the values of each DataColumn in the [salesList] as DataRows and
  /// a container to show the [__totalSalesPrice]
  SingleChildScrollView _dataTable(List<Map> salesList){
    var dts = DTS(salesList: _filteredSales.reversed.toList());
    int _rowPerPage = 50;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 40.0),
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'TOTAL SALES = ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600
                  ),
                ),
                Text(
                  '${Constants.money(_totalSalesPrice)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF061D5C),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 40.0),
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'OUTSTANDING PAYMENT = ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600
                  ),
                ),
                Text(
                  '${Constants.money(_outstandingPayment)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF061D5C),
                  ),
                ),
              ],
            ),
          ),
          widget.userType == 'Admin' ? Container(
            margin: EdgeInsets.only(left: 5.0, right: 40.0),
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'TOTAL PROFIT MADE = ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600
                  ),
                ),
                Text(
                  '${Constants.money(_totalProfitMade)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF061D5C),
                  ),
                ),
              ],
            ),
          ) : Container(),
          PaginatedDataTable(
            header: Text('Reports Table'),
            onSelectAll: (b){},
            columns: [
              DataColumn(label: Text('QTY', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('UNIT', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('PAYMENT', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('TIME', style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold),)),
            ],
            source: dts,
            onRowsPerPageChanged: (r){
              setState(() {
                _rowPerPage = r;
              });
            },
            columnSpacing: 5.0,
            rowsPerPage: _rowPerPage,
          ),
        ],
      ),
    );
  }

  /// Calls [_getSales()] and [ _getOutstandingPayment()] before the class
  /// builds its widgets
  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    setState(() {
      _appBarTitle = Text('${widget.month}, ${DateFormat('yyyy').format(now)}');
    });
    _getSales();
    _getOutstandingPayment();
  }

  /// Building a Scaffold Widget to display [_buildList()]
  /// and a [_MonthlyReportCharts]
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: _buildBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child:_buildList(),
        ),
      ),
    );
  }

  /// A function to set actions for the options menu with the value [choice]
  void choiceAction(String choice){
    if(choice == Constants.ShowMonthlyProductsSold){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MonthlyProductSold(reports: monthReport,)),
      );
    }
  }

}
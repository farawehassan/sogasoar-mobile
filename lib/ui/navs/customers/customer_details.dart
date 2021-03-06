import 'package:sogasoarventures/model/customerDB.dart';
import 'package:sogasoarventures/model/customer_reports.dart';
import 'package:sogasoarventures/model/customer_reports_details.dart';
import 'package:sogasoarventures/networking/rest_data.dart';
import 'package:sogasoarventures/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// A stateful widget class to display customer details
class CustomerDetails extends StatefulWidget {

  static const String id = 'customer_details_page';

  /// Passing the customer in this class constructor
  final Customer customer;

  /// Passing the list of customer reports in this class constructor
  final List<CustomerReport> customerReports;

  CustomerDetails({@required this.customer, @required this.customerReports});

  @override
  _CustomerDetailsState createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {

  /// A [TextEditingController] to control the input text for the user's password
  TextEditingController _deletePasswordController = new TextEditingController();

  /// GlobalKey of a my form state to validate my form while deleting a customer
  final _confirmDeleteFormKey = new GlobalKey<FormState>();

  /// Variable of int to hold the numbers of reports
  int _reportLength;

  /// Variable of List<CustomerReport> to hold the details of all the
  /// customer's reports
  List<CustomerReport> _reports = List();

  /// Variable of List<String> to hold the soldAt dateTime in string of all the
  /// customer's reports
  List<String> _dates = List();

  /// Variable of Map<String, CustomerReport> to hold the soldAt dateTime in string
  /// to the customer's reports
  Map<String, CustomerReport> _customerReport = Map();

  /// Converting [dateTime] in string format to return a formatted time
  /// of weekday, month, day and year
  String _getFormattedDate(String dateTime) {
    return DateFormat('EEE, MMM d, ''yyyy').format(DateTime.parse(dateTime)).toString();
  }

  /// Creating a [DataTable] widget from List<[CustomerReportDetails]> in [CustomerReport]
  /// using QTY, PRODUCT, UNIT, TOTAL as DataColumn and
  /// the values of each DataColumn in the [customerList] as DataRows
  /// Also showing the total amount
  SingleChildScrollView _dataTable(CustomerReport customerList){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DataTable(
            columnSpacing: 10.0,
            columns: [
              DataColumn(label: Text('QTY', style: TextStyle(fontWeight: FontWeight.normal),)),
              DataColumn(label: Text('PRODUCT', style: TextStyle(fontWeight: FontWeight.normal),)),
              DataColumn(label: Text('UNIT', style: TextStyle(fontWeight: FontWeight.normal),)),
              DataColumn(label: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.normal),)),
            ],
            rows: customerList.reportDetails.map((customer) {
              return DataRow(
                  cells: [
                    DataCell(
                      Text(customer.quantity.toString()),
                    ),
                    DataCell(
                      Text(customer.productName.toString()),
                    ),
                    DataCell(
                      Text(Constants.money(double.parse(customer.unitPrice))),
                    ),
                    DataCell(
                      Text(Constants.money(double.parse(customer.totalPrice))),
                    ),
                  ]
              );
            }).toList(),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.0, right: 40.0),
            padding: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Total Amount = ',
                  style: TextStyle(
                      fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  '${Constants.money(double.parse(customerList.totalAmount))}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF061D5C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Function to display dialog of customer report's details [details] by showing
  /// [_dataTable()]
  void _displayDialog(CustomerReport details){
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _dataTable(details),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  textColor: Color(0xFF061D5C),
                  child: Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
      //barrierDismissible: false,
    );
  }

  /// Function to get all the report dates from a customer's list of reports
  /// to [_dates]
  void _getAllReportDates() {
    _reports = widget.customerReports.reversed.toList();
    _reportLength = _reports.length;
    for(var report in _reports){
      _dates.add(report.soldAt);
      _customerReport[report.soldAt] = report;
    }
  }

  /// A function to build the list of all the customer's reports
  Widget _buildList() {
    if(_dates.length > 0 && _dates.isNotEmpty){
      return ListView.builder(
        itemCount: _dates == null ? 0 : _dates.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _displayDialog(_customerReport[_dates[index]]);
            },
            onLongPress: (){
              _displayDeleteDialog(_customerReport[_dates[index]]);
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.expand_more, color: Color(0xFF061D5C)),
                      onPressed: () {
                        _displayDialog(_customerReport[_dates[index]]);
                      },
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      _getFormattedDate(_dates[index]),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    else if(_reportLength == 0){
      return Container(
        alignment: AlignmentDirectional.center,
        child: Center(child: Text("No reports yet")),
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

  /// Calling [_getAllReportDates() before the class build its widgets]
  @override
  void initState() {
    super.initState();
    _getAllReportDates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF061D5C),
        title: Text('${widget.customer.name}'),
      ),
      body: SafeArea(
        child: Container(
          child: _buildList(),
        ),
      ),
    );
  }

  /// Function to display dialog of report details [index]
  void _displayDeleteDialog(CustomerReport details){
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                    _confirmDeleteDialog(details);
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ),
              _dataTable(details),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  color: Colors.transparent,
                  //textColor: Color(0xFF008752),
                  child: Text('CANCEL'),
                ),
              ),
            ],
          ),
        ),
      ),
      //barrierDismissible: false,
    );
  }

  /// Function to confirm if a customer sales wants to be deleted
  /// It calls [_deleteCustomerReport()] if user confirms
  void _confirmDeleteDialog(CustomerReport details){
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        child: Container(
          //height: 320.0,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Are you sure you want to delete this sales',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // To close the dialog
                        _confirmPasswordDeleteDialog(details);
                      },
                      textColor: Colors.red,
                      child: Text('YES'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // To close the dialog
                      },
                      textColor: Colors.red,
                      child: Text('NO'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      //barrierDismissible: false,
    );
  }

  /// Function to confirm if a customer sales wants to be deleted by entering pin
  /// It calls [_deleteCustomerReport()] if user confirms
  void _confirmPasswordDeleteDialog(CustomerReport details){
    bool obscureTextLogin = true;
    _deletePasswordController.clear();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        child: Form(
          key: _confirmDeleteFormKey,
          child: Container(
            height: 200.0,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Enter your pin',
                    style: TextStyle(
                      color: Color(0xFF061D5C),
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Container(
                  width: 150.0,
                  child: TextFormField(
                    controller: _deletePasswordController,
                    obscureText: obscureTextLogin,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter a pin';
                      }
                      if (int.parse(_deletePasswordController.text) != 1234) {
                        return 'Incorrect pin';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        decoration: TextDecoration.underline
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        FontAwesomeIcons.lock,
                        size: 22.0,
                        color: Colors.black,
                      ),
                      hintText: "Pin",
                      hintStyle: TextStyle(
                          fontSize: 17.0,
                          color: Colors.black54
                      ),
                      suffixIcon: GestureDetector(
                        onTap: (){
                          if(!mounted)return;
                          setState(() {
                            obscureTextLogin = !obscureTextLogin;
                          });
                        },
                        child: Icon(
                          obscureTextLogin
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 15.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deletePasswordController.clear();// To close the dialog
                        },
                        textColor: Colors.red,
                        child: Text('CANCEL'),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        onPressed: () {
                          if(_confirmDeleteFormKey.currentState.validate()){
                            _deleteCustomerReport(details);
                            Navigator.of(context).pop(); // To close the dialog
                            _deletePasswordController.clear();
                          }
                        },
                        textColor: Colors.red,
                        child: Text('DELETE'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      //barrierDismissible: false,
    );
  }

  /// Function that deletes a customer by calling
  /// [deleteCustomer] in the [RestDataSource] class
  Future<void> _deleteCustomerReport(CustomerReport details) async {
    List<CustomerReportDetails> reports = details.reportDetails;
    String time = details.soldAt;
    var api = new RestDataSource();
    try {
      for(int i = 0; i < reports.length; i++){
        await _deleteReport(time, reports[i].productName);
      }
      await api.deleteCustomerReport(widget.customer.id, details.id).then((value) {
        Constants.showMessage('Sales successfully deleted');
        Navigator.pop(context);
      }).catchError((error) {
        Constants.showMessage(error.toString());
      });
    } catch (e) {
      print(e);
      Constants.showMessage(e.toString());
    }
  }

  /// Function that deletes a report by calling
  /// [deleteReport] in the [RestDataSource] class
  Future<void> _deleteReport(String time, String product) async{
    var api = new RestDataSource();
    try {
      await api.deleteReport(time, widget.customer.name, product).then((value) {
        print('Report successfully deleted');
      }).catchError((error) {
        Constants.showMessage(error.toString());
      });
    } catch (e) {
      print(e);
      Constants.showMessage(e.toString());
    }
  }

}

import 'package:sogasoarventures/model/customerDB.dart';
import 'package:sogasoarventures/model/customer_reports.dart';
import 'package:sogasoarventures/model/reportsDB.dart';
import 'future_values.dart';

/// A class to handle methods needed with daily report records in the database
class DailyReportValue{

  /// Variable [now] holding today's current date time
  static DateTime now = DateTime.now();

  /// Variable to hold today's date in year, month and day
  final today = DateTime(now.year, now.month, now.day);

  /// Variable to hold today's date in weekday
  final weekday = DateTime(now.weekday);

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// Method to format a string value [dateTime] to a [DateTime]
  /// of year, month and day only
  DateTime getFormattedDay(String dateTime) {
    DateTime day = DateTime.parse(dateTime);
    return DateTime(day.year, day.month, day.day);
  }

  /// Method to format a string value [dateTime] to a [DateTime]
  /// of weekday only
  DateTime getFormattedWeek(String dateTime) {
    DateTime day = DateTime.parse(dateTime);
    return DateTime(day.weekday);
  }

  /// Method to format a string value [dateTime] to a [DateTime]
  /// of year and month only
  DateTime getFormattedMonth(String dateTime) {
    DateTime day = DateTime.parse(dateTime);
    return DateTime(day.year, day.month);
  }

  /// Method to format a string value [dateTime] to a [DateTime]
  /// of year only
  String getFormattedYear(String dateTime) {
    DateTime day = DateTime.parse(dateTime);
    return day.year.toString();
  }

  /// Method to format a string value [dateTime] to a [DateTime]
  /// of year and month only
  DateTime getFormattedMonthAndYear(String dateTime) {
    DateTime day = DateTime.parse(dateTime);
    return DateTime(day.year, day.month);
  }

  /// Method to check if a date is today
  /// It returns true if it is and false if it's not
  bool checkIfToday(String dateTime){
    if(getFormattedDay(dateTime) == today){
      return true;
    }
    return false;
  }

  /// Method to check if a date is this month
  /// It returns true if it is and false if it's not
  bool checkMonth(String dateTime, DateTime month){
    if(getFormattedMonth(dateTime) == month){
      return true;
    }
    return false;
  }

  /// Method to get all the years we've been taking reports based on time
  /// It returns a list of [String]
  List<String> getAllYears(List<Reports> value){
    List<String> years = List();
    for(int i = 0; i < value.length; i++){
      if(!(years.contains(getFormattedYear(value[i].createdAt)))){
        years.add(getFormattedYear(value[i].createdAt));
      }
    }
    return years;
  }

  /// Method to get all the months and years we've been taking reports based on time
  /// It returns a list of [String]
  List<DateTime> getAllMonthsAndYears(List<Reports> value){
    List<DateTime> months = List();
    for(int i = 0; i < value.length; i++){
      if(!(months.contains(getFormattedMonthAndYear(value[i].createdAt)))){
        months.add(getFormattedMonthAndYear(value[i].createdAt));
      }
    }
    return months;
  }

  /// Method to calculate profit made of a report by deducting the report's
  /// [unitPrice] from the report's [costPrice] and multiplying the value by the
  /// report's [quantity]
  /// It is done if the report's [paymentMode] is not 'Iya Bimbo'
  /// or else it returns 0
  double calculateProfit(List<Reports> data) {
    double profitMade = 0.0;
    for(int i = 0; i < data.length; i++){
      profitMade += double.parse(data[i].quantity) * (double.parse(data[i].unitPrice) - double.parse(data[i].costPrice));
    }
    return profitMade;
  }

  /// Method to get all outstanding payment from the customers
  /// It returns a double
  Future<double> getAllOutstandingPayment() async {
    double payment = 0.0;
    Future<Map<CustomerReport, Customer>> sortedMap = futureValue.getCustomersWithOutstandingBalance();
    await sortedMap.then((value) {
      if(value.length != 0) {
        value.forEach((k, v) {
          payment += double.parse(k.totalAmount) - double.parse(k.paymentMade);
        });
      }
    }).catchError((error){
      throw error;
    });
    return payment;
  }

  /// Method to get all outstanding payment from the customers that is today
  /// It returns a double
  Future<double> getTodayOutstandingPayment() async {
    double payment = 0.0;
    Future<Map<CustomerReport, Customer>> sortedMap = futureValue.getCustomersWithOutstandingBalance();
    await sortedMap.then((value) {
      if(value.length != 0) {
        value.forEach((k, v) {
          if(checkIfToday(k.soldAt)){
            payment += double.parse(k.totalAmount) - double.parse(k.paymentMade);
          }
        });
      }
    }).catchError((error){
      throw error;
    });
    return payment;
  }

  /// Method to get all outstanding payment from the customers for this month
  /// [month]
  /// It returns a double
  Future<double> getMonthOutstandingPayment(DateTime month) async {
    double payment = 0.0;
    Future<Map<CustomerReport, Customer>> sortedMap = futureValue.getCustomersWithOutstandingBalance();
    await sortedMap.then((value) {
      if(value.length != 0) {
        value.forEach((k, v) {
          if(checkMonth(k.soldAt, month)){
            payment += double.parse(k.totalAmount) - double.parse(k.paymentMade);
          }
        });
      }
    }).catchError((error){
      throw error;
    });
    return payment;
  }

  /// Method to get today's report based on time
  /// It returns a list of [Reports]
  Future<List<Reports>> getTodayReport() async {
    List<Reports> reports = new List();
    Future<List<Reports>> report = futureValue.getAllReportsFromDB();
    await report.then((value) {
      for(int i = 0; i < value.length; i++){
        if(checkIfToday(value[i].createdAt)){
          Reports reportsData = new Reports();
          reportsData.id = value[i].id;
          reportsData.customerName = value[i].customerName;
          reportsData.quantity = value[i].quantity;
          reportsData.productName = value[i].productName;
          reportsData.costPrice = value[i].costPrice;
          reportsData.unitPrice = value[i].unitPrice;
          reportsData.totalPrice = value[i].totalPrice;
          reportsData.paymentMode = value[i].paymentMode;
          reportsData.createdAt = value[i].createdAt;
          reports.add(reportsData);
        }
      }
    }).catchError((onError){
      throw (onError);
    });
    return reports;
  }

  /// reportsData.customerName = value[i].customerName;

  /// Method to get January's report based on time
  /// It returns a list of [Reports]
  List<Reports> getJanReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.january))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get February's report based on time
  /// It returns a list of [Reports]
  List<Reports> getFebReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.february))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get March's report based on time
  /// It returns a list of [Reports]
  List<Reports> getMarReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.march))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get April's report based on time
  /// It returns a list of [Reports]
  List<Reports> getAprReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.april))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get May's report based on time
  /// It returns a list of [Reports]
  List<Reports> getMayReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.may))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get June's report based on time
  /// It returns a list of [Reports]
  List<Reports> getJunReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.june))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get July's report based on time
  /// It returns a list of [Reports]
  List<Reports> getJulReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.july))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get August's report based on time
  /// It returns a list of [Reports]
  List<Reports> getAugReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.august))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get September's report based on time
  /// It returns a list of [Reports]
  List<Reports> getSepReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.september))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get October's report based on time
  /// It returns a list of [Reports]
  List<Reports> getOctReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.october))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get November's report based on time
  /// It returns a list of [Reports]
  List<Reports> getNovReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.november))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

  /// Method to get December's report based on time
  /// It returns a list of [Reports]
  List<Reports> getDecReport(List<Reports> value, {int year}) {
    List<Reports> reports = List();
    for(int i = 0; i < value.length; i++){
      if(checkMonth(value[i].createdAt, DateTime(year == null ? now.year : year, DateTime.december))){
        Reports reportsData = Reports();
        reportsData.id = value[i].id;
        reportsData.customerName = value[i].customerName;
        reportsData.quantity = value[i].quantity;
        reportsData.productName = value[i].productName;
        reportsData.costPrice = value[i].costPrice;
        reportsData.unitPrice = value[i].unitPrice;
        reportsData.totalPrice = value[i].totalPrice;
        reportsData.paymentMode = value[i].paymentMode;
        reportsData.createdAt = value[i].createdAt;
        reports.add(reportsData);
      }
    }
    return reports;
  }

}
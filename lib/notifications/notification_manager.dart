import 'package:sogasoarventures/bloc/future_values.dart';
import 'package:sogasoarventures/model/customerDB.dart';
import 'package:sogasoarventures/model/customer_reports.dart';
import 'package:sogasoarventures/ui/navs/customers/customer_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sogasoarventures/main.dart';
import 'dart:io' show Platform;

class NotificationManager {

  var flutterLocalNotificationsPlugin;

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  NotificationManager() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if(Platform.isIOS ){
      requestIOSPermissions();
    }
    initNotifications();
  }

  getNotificationInstance() {
    return flutterLocalNotificationsPlugin;
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future configureCustomerNotifications() async {
    Future<Map<CustomerReport, Customer>> customers = futureValue.getCustomersWithOutstandingBalance();
    await customers.then((value) {
      if(value.length != 0) {
        //List<Customer> customer = value.values;
        List<CustomerReport> customerReport = value.keys.toList();
        var now = DateTime.now();
        var dueDate;
        for (int j = 0; j < customerReport.length; j++) {
          if (customerReport[j].paid == false) {
            dueDate = DateTime.parse(customerReport[j].dueDate);
            var difference = now.difference(dueDate);
            if (difference.inDays >= 0) {
              //print("Customer = $difference" );
              showCustomerNotificationDaily(
                  0, "Customer", "You have customers "
                  "yet to settle his/her payment."
                  "If settled, kindly come back and update your customer\'s payment",
                  DateTime.now().hour,
                  DateTime.now().minute
              );
            }
          }
        }
      }
    }).catchError((error){
      print(error);
    });
  }

  void initNotifications() async {
    /// initialise the plugin.
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future showCustomerNotificationDaily(
      int id, String title, String body, int hour, int minute) async {
    var time = new Time(hour, minute, 0);
    await flutterLocalNotificationsPlugin.show(
        id, title, body, getCustomerPlatformChannelSpecifics(id), payload: 'customer payload');
    print('Notification Successfully Scheduled at ${time.toString()} with id of $id');
  }

  getCustomerPlatformChannelSpecifics(int id) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '$id',
        'Customer notifications ',
        'Notifications for customers passing their due date',
        importance: Importance.Max,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
        channelShowBadge: true,
        priority: Priority.High,
        ticker: 'Notification Reminder');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    return platformChannelSpecifics;
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: MyApp.navigatorKey.currentContext,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              if(payload == 'customer payload'){
                //print('notification payload: ' + payload);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerPage()),
                );
              }
            },
          )
        ],
      ),
    );
    //return Future.value(1);
  }

  Future onSelectNotification(String payload) async {
    print('Notification clicked');
    if (payload == null || payload.trim().isEmpty) {
      debugPrint('notification payload: ' + payload);
    }
    else if(payload == 'customer payload'){
      //print('notification payload: ' + payload);
      await Navigator.push(
        MyApp.navigatorKey.currentContext,
        MaterialPageRoute(builder: (context) => CustomerPage()),
      );
    }
  }

  void removeReminder(String notificationId) {
    flutterLocalNotificationsPlugin.cancel(notificationId);
    print('Notification with id: $notificationId been removed successfully');
  }

}
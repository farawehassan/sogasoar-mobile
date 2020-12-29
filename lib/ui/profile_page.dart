import 'package:sogasoarventures/bloc/future_values.dart';
import 'package:sogasoarventures/bloc/year_line_charts.dart';
import 'package:sogasoarventures/model/store_details.dart';
import 'package:sogasoarventures/ui/navs/profile/workers.dart';
import 'package:sogasoarventures/utils/constants.dart';
import 'package:sogasoarventures/utils/reusable_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sogasoarventures/utils/size_config.dart';

/// A StatefulWidget class that displays the business's profile
/// only the admin can have access to this page
class Profile extends StatefulWidget {

  static const String id = 'profile_page';

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// A string value to hold the cost price net worth of the products
  String _cpNetWorth= '';

  /// A string value to hold the selling price net worth of the products
  String _spNetWorth = '';

  /// A double value to hold the total number of items available
  double _numberOfItems = 0.0;

  /// A double value to hold the total profit made so far
  double _totalProfit = 0.0;

  /// A function to set the values [_cpNetWorth], [_spNetWorth], [_numberOfItems],
  /// from the [StoreDetails] model fetching from the database
  void _getStoreValues() async {
    Future<StoreDetails> details = futureValue.getStoreDetails();
    await details.then((value) {
      if (!mounted) return;
      setState(() {
        _cpNetWorth = Constants.money(value.cpNetWorth);
        _spNetWorth = Constants.money(value.spNetWorth);
        _numberOfItems = value.totalItems;
        _totalProfit = value.totalProfitMade;
      });
    }).catchError((onError){
      Constants.showMessage(onError);
    });
  }

  /// Calling [_getStoreValues()] and [_getReports()] before the page loads
  @override
  void initState() {
    super.initState();
    _getStoreValues();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF061D5C),
        title: Text('Sogasoar Ventures'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return Constants.profileChoices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            }
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Material(
              elevation: 14.0,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              shadowColor: Color(0xFF004C7F),
              child: Container(
                margin: EdgeInsets.only(top: 30.0),
                padding: EdgeInsets.only(bottom: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Hero(
                            tag: 'displayPicture',
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              maxRadius: 80.0,
                              minRadius: 40.0,
                              backgroundImage: AssetImage('Assets/images/sogasoar_logo.png'),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.0,),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Sogasoar Ventures",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "help@sogasoarventures.com",
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.0,),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'CP Net Worth',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$_cpNetWorth',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF061D5C),
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'SP Net Worth',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$_spNetWorth',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF061D5C),
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.0,),
            Container(
              margin: EdgeInsets.all(8.0),
              height: 200.0,
              child: Material(
                elevation: 14.0,
                borderRadius: BorderRadius.circular(24.0),
                child:  Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF004C7F),
                        Color(0xFF061D5C)
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Sales by Month',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      PointsLineChart(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.0,),
            Container(
              margin: EdgeInsets.all(4.0),
              width: SizeConfig.screenWidth - 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  /*Container(
                  width: (SizeConfig.screenWidth / 2) - 12,
                  child: ProfileCard(
                    cardChild: ProfitCharts(),
                  ),
                ),*/
                  ProfileCard(
                    cardChild: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child:Text(
                            'Profit',
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        Container(
                            width: (SizeConfig.screenWidth / 2) - 12,
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '${Constants.money(_totalProfit)}',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Color(0xFF061D5C),
                                fontWeight: FontWeight.w800,
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  ProfileCard(
                    cardChild: Column(
                      children: <Widget>[
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '$_numberOfItems',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Color(0xFF061D5C),
                                fontWeight: FontWeight.w800,
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0)
          ],
        ),
      ),
    );
  }

  /// A function to set the routes to navigate to when an option is pressed with
  /// the value [choice]
  void choiceAction(String choice){
    if(choice == Constants.Create){
      Navigator.pushNamed(context, MyWorkers.id);
    }
  }
}


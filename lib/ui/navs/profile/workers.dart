import 'package:flutter/material.dart';
import 'package:sogasoarventures/bloc/future_values.dart';
import 'package:sogasoarventures/model/workers.dart';
import 'package:sogasoarventures/networking/rest_data.dart';
import 'package:sogasoarventures/ui/register/create_worker.dart';
import 'package:sogasoarventures/utils/constants.dart';
import 'package:sogasoarventures/utils/round_icon.dart';
import 'package:sogasoarventures/utils/size_config.dart';

class MyWorkers extends StatefulWidget {

  static const String id = 'workers_page';

  @override
  _MyWorkersState createState() => _MyWorkersState();
}

class _MyWorkersState extends State<MyWorkers> {

  /// Instantiating a class of the [FutureValues]
  var futureValue = FutureValues();

  /// GlobalKey of a my RefreshIndicatorState to refresh my list items in the page
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  /// A List to hold the all the banks user has
  List<Workers> _workers = List();

  /// An Integer variable to hold the length of [_workers]
  int _workersLength;

  /// Function to fetch all the workers from the database to
  /// [_workers]
  void _allWorkers() async {
    Future<List<Workers>> workers = futureValue.getAllWorkersFromDB();
    await workers.then((value) {
      if(value.isEmpty || value.length == 0){
        if(!mounted)return;
        setState(() {
          _workersLength = 0;
          _workers = [];
        });
      } else if (value.length > 0){
        if(!mounted)return;
        setState(() {
          _workers.addAll(value);
          _workersLength = value.length;
        });
      }
    }).catchError((error){
      print(error);
      Constants.showMessage(error.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    _allWorkers();
  }

  /// A function to build the list of all the accounts the user has
  Widget _buildList() {
    if(_workers.length > 0 && _workers.isNotEmpty){
      return ListView.builder(
        itemCount: _workers == null ? 0 : _workers.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 15),
              Container(
                width: SizeConfig.screenWidth - 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Color(0XFFC3D3D4),
                    ),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.account_balance,
                              color: Color(0XFF1E50CF),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${_workers[index].name}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "Bold",
                                    letterSpacing: -0.2,
                                    color: Color(0XFF060D47),
                                  ),
                                ),
                                Text(
                                  '${_workers[index].phoneNumber} - ${_workers[index].type}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Bold",
                                    fontWeight: FontWeight.w500,
                                    color: Color(0XFF7E7E7E)
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: (){
                            _buildDeleteDialog(_workers[index].id, _workers[index].name);
                          },
                          child: Text(
                            'Trash',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0XFFFC1616).withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }
    else if(_workersLength == 0){
      return Container(
        alignment: AlignmentDirectional.center,
        child: Center(
            child: Text(
              "No Workers Yet",
              style: TextStyle(
                fontSize: 20,
                letterSpacing: -0.2,
                color:Color(0xFF061D5C),
              ),
            )),
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

  /// Function to refresh details of the list of all the workers the admin has
  /// similar to [_allWorkers()]
  Future<Null> _refresh() {
    Future<List<Workers>> workers = futureValue.getAllWorkersFromDB();
    return workers.then((value) {
      if(!mounted)return;
      setState(() {
        _workersLength = 0;
        _workers.clear();
      });
      if(value.isEmpty || value.length == 0){
        if(!mounted)return;
        setState(() {
          _workersLength = 0;
          _workers = [];
        });
      } else if (value.length > 0){
        if(!mounted)return;
        setState(() {
          _workers.addAll(value);
          _workersLength = value.length;
        });
      }
    }).catchError((error){
      print(error);
      Constants.showMessage(error.toString());
    });
  }

  /// Function to refresh details of the banks
  /// by calling [_allWorkers()]
  void _refreshData(){
    if (!mounted) return;
    setState(() {
      _allWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF061D5C),
        title: Text('Workers'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        color: Color(0xFF061D5C),
        child: Padding(
          padding: EdgeInsets.fromLTRB(15, 35, 15, 0),
          child: _buildList(),
        ),
      ),
      floatingActionButton: RoundIconButton(
        icon: Icons.add,
        onPressed: (){
          Navigator.pushNamed(context, CreateWorker.id);
        },
      ),
    );
  }

  /// Function that shows a dialog to confirm if you want to delete a worker
  void _buildDeleteDialog(String id, String name){
    showDialog(
      context: context,
      builder: (_) => Dialog(
        elevation: 0.0,
        child: Container(
          width: 337,
          height: 150.0,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 28.0),
                child: Text(
                  "Delete!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Color(0xFFFC1616),
                    fontFamily: 'Bold',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Text(
                  "Are you sure want to delete $name's account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Color(0xFF7E7E7E),
                      fontFamily: 'Regular',
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: (){
                      Navigator.of(context).pop(); // To close the dialog
                    },
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'NO',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black
                        ),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: (){
                      Navigator.of(context).pop(); // To close the dialog
                      _deleteWorker(id);
                    },
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'YES',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function that deletes a worker
  /// [deleteWorker] in the [RestDataSource] class
  Future<void> _deleteWorker(String id) async {
    var api = RestDataSource();
    try {
      await api.deleteWorker(id).then((value) {
        Constants.showMessage('Worker successfully deleted');
        _refreshData();
      }).catchError((error) {
        print(error);
        Constants.showMessage(error.toString());
      });
    } catch (e) {
      print(e);
      Constants.showMessage(e.toString());
    }
  }

}

// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weatherapp/models/singleCityModel.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/views/citiesList.dart';

import '../constans.dart';
import '../views/sngleCityScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> userCities = [
    'London',
    'Barcelona',
    'Amman',
    'New York',
  ];
  Future getUserCities() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? isFirstTime = pref.getBool('isFirstTime');
    if(isFirstTime == true){
        userCities = (pref.getStringList('userCities'))!;
    }else{
      await pref.setStringList('userCities', userCities);
    }
  }
  List<SingleCityModel> myCities = [];

  Future getSingleCityData(String city) async {
    var url =
        'http://api.weatherapi.com/v1/current.json?key=226a4c241b2c4130b97103440222302&q=$city&aqi=yes';
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
    });
    var singleCityModel;
    try {
      var body = jsonDecode(response.body);
      singleCityModel = SingleCityModel.fromJson(body);
      setState(() {
        myCities.add(singleCityModel);
      });
    } catch (e) {}
    return singleCityModel;
  }

  void init() async{
    setState(() {
      loading = true;
    });
    await getUserCities();
    for(var i = 0; i < userCities.length; i++){
      await getSingleCityData(userCities[i]);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    init();
    // TODO: implement initState
    super.initState();

  }
  bool loading = false;

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double myHeight = size.height;
    final double myWidth = size.width;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          myCities.clear();
          init(); },
        child: Icon(Icons.refresh,color: Color(0XFF060622),),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: myHeight,
        width: myWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0XFF060622),
            Color(0XFF060622),
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child:
        loading?
        MyLoading():
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Center(
                    child: Text(
                  'Weather App',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(
                  'Find the area or city that you want to know\nthe detailed weather info at this time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CitiesListScreen()));
                  },
                  child: Container(
                    width: myWidth * 0.8,
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                        child: Text(
                      'Add / Remove Your Cities',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  children: List.generate(myCities.length, (index){
                    return singleCity(
                        myCities[index].location?.name,
                        myCities[index].location?.country,
                        myCities[index].current?.tempC.toString(),
                        myCities[index].current?.condition?.icon,
                        myCities[index].current?.condition?.text,
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget singleCity(String? cityName,String? countryName, String? temp, String? image, String? status) {
    var size = MediaQuery.of(context).size;

    final double myHeight = size.height;
    final double myWidth = size.width;
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleCityScreen(cityName: cityName,)));

      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: myWidth * 0.9,
        height: 100,
        decoration: BoxDecoration(
            color: Color(0xff0D0C2B), borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cityName.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      )),
                  Text(countryName.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis
                      )),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(temp.toString(),
                      style: TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                      )),
                  Text('c',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(child: Image.network('https:' + image.toString())),
                  Text(status!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


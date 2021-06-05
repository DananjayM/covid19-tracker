import 'package:covid_api/app/services/api.dart';
import 'package:covid_api/app/services/api_service.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> _scaffoldKey;
  List<String> data = new List<String>(5);
  List<String> img = [
    'cases',
    'casesSuspected',
    'casesConfirmed',
    'deaths',
    'recovered'
  ];
  List<String> title = [
    'Cases',
    'Suspected cases',
    'Confirmed cases',
    'Deaths',
    'Recovered'
  ];
  List<Color> colors = [
    Color(0xFFFFF492),
    Color(0xFFEEDA28),
    Color(0xFFE99600),
    Color(0xFFE40000),
    Color(0xFF70A901)
  ];
  bool _loading = false;
  String _date, displayDate, displayTime, hr, min, sufx;
  @override
  void initState() {
    _scaffoldKey = GlobalKey();
    super.initState();
    _fetchData(1);
  }

  @override
  void dispose() {
    _scaffoldKey?.currentState?.dispose();
    super.dispose();
  }

  Future<void> _fetchData(int state) async {
    if (state == 1) {
      setState(() {
        _loading = !_loading;
      });
    }
    final apiService = APIService(API.sandbox());
    final accessToken = await apiService.getAccessToken();
    final results = await Future.wait([
      apiService.getEndpointData(
          accessToken: accessToken, endpoint: Endpoint.cases),
      apiService.getEndpointData(
          accessToken: accessToken, endpoint: Endpoint.casesSuspected),
      apiService.getEndpointData(
          accessToken: accessToken, endpoint: Endpoint.casesConfirmed),
      apiService.getEndpointData(
          accessToken: accessToken, endpoint: Endpoint.deaths),
      apiService.getEndpointData(
          accessToken: accessToken, endpoint: Endpoint.recovered),
      apiService.getDateTime(
          accessToken: accessToken, endpoint: Endpoint.cases),
    ]);

    setState(() {
      data[0] = results[0].toString();
      data[1] = results[1].toString();
      data[2] = results[2].toString();
      data[3] = results[3].toString();
      data[4] = results[4].toString();
      _date = results[5];
      if (state == 1) _loading = !_loading;
    });
    displayDate = _date.substring(8, 10) +
        "-" +
        _date.substring(5, 7) +
        "-" +
        _date.substring(0, 4);
    hr = _date.substring(11, 13);
    min = _date.substring(14, 16);
    if (int.parse(hr) >= 12) {
      sufx = " PM";
      hr = int.parse(hr) > 12 ? (int.parse(hr) - 12).toString() : hr;
    } else if (int.parse(hr) == 0) {
      hr = (int.parse(hr) + 12).toString();
      sufx = " AM";
    } else {
      sufx = " AM";
    }
    displayTime = hr + ":" + min + sufx;
    for (int i = 0; i < 5; i++) {
      int cnt = 1;
      int len = data[i].length;
      String temp = "", str = data[i];
      for (int j = len - 1; j >= 0; j--) {
        if ((cnt) % 4 == 0) {
          temp = temp + ",";
          cnt = 1;
          j++;
        } else {
          temp = temp + str[j];
          cnt++;
        }
      }
      temp = temp.split('').reversed.join();
      data[i] = temp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('COVID-19 Tracker'),
        centerTitle: true,
      ),
      body: Center(
          child: RefreshIndicator(
        onRefresh: () => _fetchData(0),
        child: _loading
            ? Container(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey[800],
                    child: Center(
                        child: Text(
                            'Last updated on $displayDate at $displayTime')),
                  ),
                  SizedBox(height: 4),
                  ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title[index],
                                style: TextStyle(
                                    fontSize: 20, color: colors[index]),
                              ),
                              SizedBox(height: 4),
                              SizedBox(
                                height: 52,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/${img[index]}.png',
                                      color: colors[index],
                                    ),
                                    Text(
                                      data[index],
                                      style: TextStyle(
                                          fontSize: 20, color: colors[index]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: data.length != null ? data.length : 0,
                    physics: AlwaysScrollableScrollPhysics(),
                  ),
                ],
              ),
      )),
    );
  }
}

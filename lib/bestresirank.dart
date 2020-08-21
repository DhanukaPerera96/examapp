import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BestResIRank extends StatefulWidget {

  final String paperId;

  BestResIRank({this.paperId});

  @override
  _BestResIRankState createState() => _BestResIRankState();
}

class _BestResIRankState extends State<BestResIRank> {

  List iRankList = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.paperId);
    getBestResIrank(widget.paperId);
  }

  getBestResIrank(pId)async{
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    var url = 'http://rankme.ml/getBestResIRank.php';
    final response = await http.post(Uri.encodeFull(url),headers: {"Accept":"application/json"},
        body: {
          "paperId" : pId,
        }
    );

    if(response.body.toString() != "Error"){
      String jsonDataString = response.body;
      var data = jsonDecode(jsonDataString);


      setState(() {
        iRankList = json.decode(jsonDataString.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Best District Ranks'),
      ),
      body: iRankList.length == 0
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      )
          :Container(
          color: Colors.indigo[100],
          child: iRankList.length == 0
              ? Container(
            child: Center(
              child: Text("No Information Available"),
            ),
          )
              : ListView(
            children: iRankList
                .map((list) => Container(
              width: size.width * 0.85,
              child: Card(
                child: ListTile(
                  title: Text(list['fname']+" "+list['lname']),
                  subtitle: Text("Time "+ list['time']),
                  trailing: Text("Marks "+ list['score']),
                ),
              ),
            )).toList(),
          )
      ),

    );
  }
}

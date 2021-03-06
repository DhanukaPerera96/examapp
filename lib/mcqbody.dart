import 'package:educationapp/ansbody.dart';
import 'package:educationapp/finalres.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_countdown_timer/countdown_timer.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class McqBody extends StatefulWidget {

  final String mcqPprId;
  final String mcqTime;
  final String subId;

  McqBody({this.mcqPprId, this.mcqTime, this.subId});

  @override
  _McqBodyState createState() => _McqBodyState();
}

class _McqBodyState extends State<McqBody> {

  String mcqPprId;
  List mcqQuestions = List();
  List mcqQueAns = List();
  List userData = List();

  final Map<String, int> qAndAList = {};
  List list = List();
  String mcqQuesId;
  String ansOne, ansTwo, ansThree, ansFour, correctAns;
  int ansOneNo, ansTwoNo, ansThreeNo, ansFourNo;
  String qNo, ansNo;
  String selectedNoOne, selectedNoTwo, selectedNoThree, selectedNoFour, selectedNoFive, selectedFinal;
  bool ansOneB = false;
  bool ansTwoB = false;
  bool ansThreeB = false;
  bool ansFourB = false;
  bool ansFiveB = false;
  int endTime;
  int transTime;
  int qNumber;
  int pageNo;
  int quesAmt;
  int correct = 0;
  int wrong = 0;
  double total = 0.0;
  int strtEndT;
  bool isClosed = true;
  String udId;




  int selectedindex = 1;
  List<Widget> listWidget = new List<Widget>();


  int _lowerCount = -1;
  int _upperCount = 1;

  // final List<Widget> _pages = <Widget>[
  //   new Center(child: new Text("-1", style: new TextStyle(fontSize: 60.0))),
  //   new Center(child: new Text("0", style: new TextStyle(fontSize: 60.0))),
  //   new Center(child: new Text("1", style: new TextStyle(fontSize: 60.0)))
  // ];

  // final List<Widget> _pages = List.castFrom<dynamic, Widget>(mcqQuestions);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mcqPprId = widget.mcqPprId;
    int countD = int.parse(widget.mcqTime);
    assert(countD is int);
    getMcqQues(mcqPprId);
    endTime = DateTime.now().millisecondsSinceEpoch + countD * 1000 * 60;
    strtEndT = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
    pageNo = 0;
    getUserData();
  }



  //Getting dynamic subjects
  getMcqQues(mcqPprId)async{
    print("GetSUbPapers called");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    String pprId = mcqPprId;

    var url = 'http://rankme.ml/getMcqPprs.php';
    final response = await http.post(Uri.encodeFull(url),headers: {"Accept":"application/json"},
        body: {
          "mcqPprId" : pprId,
        }
    );

    if(response.body.toString() != "Error") {
      String jsonDataString = response.body;
      var data = jsonDecode(jsonDataString);

      if (this.mounted) {
        setState(() {
          mcqQuestions = json.decode(jsonDataString.toString());
//          print(mcqDetails);
          mcqQuesId = mcqQuestions[0]['id'];
          correctAns = mcqQuestions[0]['answer'];
        });
      }




      // return new Row(children: list);

    }
  }





  Widget _indicator(bool isActive) {
    return Container(
      height: 10,
      child: AnimatedContainer(

        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive
            ? 10:8.0,
        width: isActive
            ? 12:8.0,
        decoration: BoxDecoration(
          boxShadow: [
            isActive
                ? BoxShadow(
              color: Colors.indigo.withOpacity(0.72),
              blurRadius: 4.0,
              spreadRadius: 1.0,
              offset: Offset(
                0.0,
                0.0,
              ),
            )
                : BoxShadow(
              color: Colors.transparent,
            )
          ],
          shape: BoxShape.circle,
          color: isActive ? Colors.indigo : Colors.indigo[300],
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < mcqQuestions.length; i++) {
      list.add(i ==  selectedindex? _indicator(true) : _indicator(false));
    }
    return list;
  }


  Future<Widget> getMcqAns(mcqQId)async{
    print("GetSUbPapers called");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    String mcqQsId = mcqQId;

    var url = 'http://rankme.ml/getMcqQAns.php';
    final response = await http.post(Uri.encodeFull(url),headers: {"Accept":"application/json"},
        body: {
          "mcqQId" : mcqQsId,
        }
    );

    if(response.body.toString() != "Error") {
      String jsonDataString = response.body;
      var data = jsonDecode(jsonDataString);

      if (this.mounted) {
        setState(() {
          mcqQueAns = json.decode(jsonDataString.toString());
        });
      }

    }
    for(var i = 0; i < mcqQueAns.length; i++){
      print(mcqQueAns[0]['text']);
      list.add(new Text(mcqQueAns[0]['text']));
    }
    return new Column(children: list);
  }

  getUserData()async{
    print("getUser called");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    String phoneNo = user.phoneNumber;
    String phoneFinal = phoneNo.replaceAll("+94", "");

    var url = 'http://rankme.ml/getUserData.php';
    final response = await http.post(Uri.encodeFull(url),headers: {"Accept":"application/json"},
        body: {
          "phoneNo" : phoneFinal,
        }
    );
    if(response.body.toString() != "Error") {
      String jsonDataString = response.body;
      var data = jsonDecode(jsonDataString);

      if (this.mounted) {
        setState(() {
          userData = json.decode(jsonDataString.toString());
          udId = userData[0]['id'];

        });
      }
    }
  }
  pauseExit(){
    transTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;

    String uId = udId;
    String subId = widget.subId;
    String ppr = widget.mcqPprId;
    int time = (endTime - transTime)+3000;
    double tot = total;
    int page = 0;

    print(uId);
    print(subId);
    print(ppr);
    print(time);
    print(tot);
    print(page);

  }

  validateAns(ans){

    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are You Sure?",
      desc: "You won't be able to change the answer again!",
      buttons: [
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.red,
        ),
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            setState(() {
              isClosed = false;
            });
            transTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;

            var restTime =  (endTime - transTime)+3000;
            // print(transTime);
            // print(strtEndT);
            // print(restTime);
            // print((endTime * 1000* 60) - transTime);

            if(ans != null) {
              int corAns = int.parse(mcqQuestions[0]['answer']);
              quesAmt = mcqQuestions.length;
              assert(corAns is int);
              int selAns = int.parse(ans);
              assert(selAns is int);
              print(ans);
              print(corAns);
              if (selAns == corAns) {
                print("Question " + mcqQuestions[0]['no'] + " Correct");
                correct = correct + 1;
              }
              else {
                print("Question " + mcqQuestions[0]['no'] + " wrong");
                wrong = wrong + 1;
              }
              setState(() {
                total = (correct / quesAmt) * 100;
                qAndAList["$pageNo"] = selAns;
              });

              Navigator.push(context, MaterialPageRoute(
                  builder: (context) =>
                      AnsBody(
                        quesList: mcqQuestions,
                        pageNo: pageNo + 1,
                        correct: correct,
                        tot: total,
                        ansList: qAndAList,
                        mcqId: mcqPprId,
                        subId : widget.subId,
                        time : restTime,
                        iniTime: strtEndT,
                        setEnd : widget.mcqTime,

                      )
              ));
            }
            else if(ans == null) {

              Navigator.push(context, MaterialPageRoute(
                  builder: (context) =>
                      AnsBody(
                        quesList: mcqQuestions,
                        pageNo: pageNo + 1,
                        correct: correct,
                        tot: total,
                        ansList: qAndAList,
                        mcqId: mcqPprId,
                        subId: widget.subId,
                        time: restTime,
                        iniTime: strtEndT,
                        setEnd : widget.mcqTime,

                      )
              ));
            }
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();



  }

  validateAnsFinal(ans){

    Alert(
      context: context,
      type: AlertType.warning,
      title: "Do You want to Finish the paper?",
      desc: "You won't be able to change the answer again!",
      buttons: [
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            setState(() {
              isClosed = false;
            });

            transTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
            var restTime =  (endTime - transTime)+3000;


            if(ans != null){
              int corAns = int.parse(mcqQuestions[0]['answer']);
              quesAmt = mcqQuestions.length;
              assert(corAns is int);
              int selAns = int.parse(ans);
              assert(selAns is int);
              print(ans);
              print(corAns);
              if(selAns == corAns)
              {
                print("Question "+ mcqQuestions[0]['no'] +" Correct");
                correct =  correct + 1;
              }
              else{
                print("Question "+ mcqQuestions[0]['no'] +" wrong");
                wrong = wrong+1;
              }
              qAndAList["$pageNo"] = selAns ;

              total = (correct/quesAmt)*100;
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => FinalRes(
                    tot : total,
                    ansList: qAndAList,
                    realAns : mcqQuestions,
                    mcqId: mcqPprId,
                    subId : widget.subId,
                    time : restTime,
                    iniTime: strtEndT,
                    setEnd : widget.mcqTime,
                  )
              ));

            }
            else if(ans == null)
            {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => FinalRes(
                    tot : total,
                    ansList: qAndAList,
                    realAns : mcqQuestions,
                    mcqId: mcqPprId,
                    subId : widget.subId,
                    time : restTime,
                    iniTime: strtEndT,
                    setEnd : widget.mcqTime,
                  )
              ));}
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();




  }



  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    bool _allow = false;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(

          title: Text("Quiz Starting"),
        ),
        body: mcqQuestions.length == 0? Container(
          child: Center(
            child: JumpingDotsProgressIndicator(
              fontSize: size.height*0.1,
            ),
          ),
        ): SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: isClosed ?  CountdownTimer(
                  endTime: endTime,
                  hoursTextStyle:GoogleFonts.yesevaOne(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.red
                  ),
                  minTextStyle: GoogleFonts.yesevaOne(
                fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.red
                ),
                  secTextStyle: GoogleFonts.yesevaOne(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent
                  ),


                  onEnd: (){
                    print("Game Over");
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => FinalRes(
                          tot : total,
                        )
                    ));
                  },
                ) : Container(),
              ),
              Container(
                height: size.height*0.8,
                margin: EdgeInsets.symmetric(
                  vertical: 5.0,
                ),
                child: Container(
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Row(
                            children: [

                              Expanded(
                                child: MaterialButton(
                                  elevation: 2,
                                  child: Text('Pause and Exit',
                                    style: TextStyle(
                                        color: Colors.white
                                    ),),
                                  onPressed: null,
                                  color: Colors.redAccent,
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.2,
                              ),
                              Expanded(
                                child: pageNo < mcqQuestions.length-1 ?  MaterialButton(
                                  elevation: 2,
                                  child: Text('Finish'),
                                  onPressed: (){
                                    validateAnsFinal(selectedFinal);

                                  },
                                  color: Colors.indigoAccent,
                                ):
                                MaterialButton(
                                  elevation: 2,
                                  child: Text('Finish'),
                                  onPressed: (){
                                    validateAnsFinal(selectedFinal);
                                    // Navigator.push(context, MaterialPageRoute(
                                    //     builder: (context) => McqBody(
                                    //
                                    //     )
                                    // ));
                                  },
                                  color: Colors.indigoAccent,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.grey,
                          child: Card(

                            child: ListTile(
                              leading: Icon(Icons.library_books),
                              title: Text(mcqQuestions[0]['text']),
                              subtitle: mcqQuestions[0]['image'] != null ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: new BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage("http://rankme.ml/dashbord/dist/"+mcqQuestions[0]['image']),
                                      fit: BoxFit.cover,
                                    ),
                                    color: Colors.redAccent,
                                  ),
                                  height: size.height*0.2,
                                  width: size.width*0.1,
                                ),
                              ): Container(width: 0, height: 0),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            child: ListView(
                              children: <Widget>[

                                CheckboxListTile(

                                    title: Text(mcqQuestions[0]['ans_one']),
                                    value: ansOneB,
                                    onChanged: (val) {
                                      setState(() {
                                        // _onSubSelected(val,list['id']);
                                        // print(mcqQuestions[0]['no']);
                                        // print(mcqQuestions[0]['answer']);
                                        // print(mcqQuestions[0]['ans_one_no']);
                                        // qNo = mcqQuestions[0]['no'];
                                        // ansNo = mcqQuestions[0]['answer'];
                                        // selectedNoOne = mcqQuestions[0]['ans_one_no'];
                                        ansOneB = true;
                                        ansFiveB = false;
                                        ansTwoB = false;
                                        ansThreeB = false;
                                        ansFourB = false;
                                        selectedFinal = mcqQuestions[0]['ans_one_no'];
                                        // qNumber = int.parse(qNo);
                                        // assert(qNumber is int);
                                      });
                                      // print(selectedSubList);
                                    },
                                    subtitle: mcqQuestions[0]['ans_one_img'] != null ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("http://rankme.ml/dashbord/dist/"+mcqQuestions[0]['ans_one_img']),
                                            fit: BoxFit.cover,
                                          ),
                                          color: Colors.redAccent,
                                        ),
                                        height: size.height*0.2,
                                        width: size.width*0.1,
                                      ),
                                    ): Container(width: 0, height: 0)
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                CheckboxListTile(
                                    title: Text(mcqQuestions[0]['ans_two']),
                                    value: ansTwoB,
                                    onChanged: (val) {
                                      setState(() {
                                        // _onSubSelected(val,list['id']);
                                        // print(mcqQuestions[0]['no']);
                                        // print(mcqQuestions[0]['answer']);
                                        // print(mcqQuestions[0]['ans_two_no']);
                                        // qNo = mcqQuestions[0]['no'];
                                        // ansNo = mcqQuestions[0]['answer'];
                                        selectedFinal = mcqQuestions[0]['ans_two_no'];
                                        ansTwoB = true;
                                        ansFiveB = false;
                                        ansOneB = false;
                                        ansThreeB = false;
                                        ansFourB = false;
                                        // qNumber = int.parse(qNo);
                                        // assert(qNumber is int);
                                      });
                                      // print(selectedSubList);

                                    },
                                    subtitle: mcqQuestions[0]['ans_two_img'] != null ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("http://rankme.ml/dashbord/dist/"+mcqQuestions[0]['ans_two_img']),
                                            fit: BoxFit.cover,
                                          ),
                                          color: Colors.redAccent,
                                        ),
                                        height: size.height*0.2,
                                        width: size.width*0.1,
                                      ),
                                    ): Container(width: 0, height: 0)
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                CheckboxListTile(
                                    title: Text(mcqQuestions[0]['ans_three']),
                                    value: ansThreeB,
                                    onChanged: (val) {
                                      setState(() {
                                        // _onSubSelected(val,list['id']);
                                        // print(mcqQuestions[0]['no']);
                                        // print(mcqQuestions[0]['answer']);
                                        // print(mcqQuestions[0]['ans_three_no']);
                                        // qNo = mcqQuestions[0]['no'];
                                        // ansNo = mcqQuestions[0]['answer'];
                                        selectedFinal = mcqQuestions[0]['ans_three_no'];
                                        ansThreeB = true;
                                        ansFiveB = false;
                                        ansOneB = false;
                                        ansTwoB = false;
                                        ansFourB = false;
                                        // qNumber = int.parse(qNo);
                                        // assert(qNumber is int);
                                      });
                                      // print(selectedSubList);
                                    },
                                    subtitle: mcqQuestions[0]['ans_three_img'] != null ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("http://rankme.ml/dashbord/dist/"+mcqQuestions[0]['ans_three_img']),
                                            fit: BoxFit.cover,
                                          ),
                                          color: Colors.redAccent,
                                        ),
                                        height: size.height*0.2,
                                        width: size.width*0.1,
                                      ),
                                    ): Container(width: 0, height: 0)
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                CheckboxListTile(
                                    title: Text(mcqQuestions[0]['ans_four']),
                                    value: ansFourB,
                                    onChanged: (val) {
                                      setState(() {
                                        // _onSubSelected(val,list['id']);
                                        // print(mcqQuestions[0]['no']);
                                        // print(mcqQuestions[0]['answer']);
                                        // print(mcqQuestions[0]['ans_four_no']);
                                        // qNo = mcqQuestions[0]['no'];
                                        // ansNo = mcqQuestions[0]['answer'];
                                        selectedFinal = mcqQuestions[0]['ans_four_no'];
                                        ansFourB = true;
                                        ansFiveB = false;
                                        ansOneB = false;
                                        ansTwoB = false;
                                        ansThreeB = false;
                                        // qNumber = int.parse(qNo);
                                        // assert(qNumber is int);
                                      });
                                      // print(selectedSubList);
                                    },
                                    subtitle: mcqQuestions[0]['ans_four_img'] != null ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("http://rankme.ml/dashbord/dist/"+mcqQuestions[0]['ans_four_img']),
                                            fit: BoxFit.cover,
                                          ),
                                          color: Colors.redAccent,
                                        ),
                                        height: size.height*0.2,
                                        width: size.width*0.1,
                                      ),
                                    ): Container(width: 0, height: 0)
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                (mcqQuestions[0]['ans_five'] != null) ? CheckboxListTile(
                                    title: Text(mcqQuestions[0]['ans_five']),
                                    value: ansFiveB,
                                    onChanged: (val) {
                                      setState(() {
                                        // _onSubSelected(val,list['id']);
                                        // print(mcqQuestions[0]['no']);
                                        // print(mcqQuestions[0]['answer']);
                                        // print(mcqQuestions[0]['ans_five_no']);
                                        // qNo = mcqQuestions[0]['no'];
                                        // ansNo = mcqQuestions[0]['answer'];
                                        selectedFinal = mcqQuestions[0]['ans_five_no'];
                                        ansFiveB = true;
                                        ansOneB = false;
                                        ansTwoB = false;
                                        ansThreeB = false;
                                        ansFourB = false;
                                        // qNumber = int.parse(qNo);
                                        // assert(qNumber is int);
                                      });
                                      // print(selectedSubList);
                                    },
                                    subtitle: mcqQuestions[0]['ans_five_img'] != null ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage("http://rankme.ml/dashbord/dist/"+mcqQuestions[0]['ans_five_img']),
                                            fit: BoxFit.cover,
                                          ),
                                          color: Colors.redAccent,
                                        ),
                                        height: size.height*0.2,
                                        width: size.width*0.1,
                                      ),
                                    ): Container(width: 0, height: 0)
                                ): SizedBox(
                                  height: 1.0,
                                ),



                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Row(
                            children: [

                              // Expanded(
                              //   child: MaterialButton(
                              //     elevation: 2,
                              //     child: Text('Back',
                              //       style: TextStyle(
                              //           color: Colors.white
                              //       ),),
                              //     onPressed: (){},
                              //     color: Colors.redAccent,
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: size.width * 0.2,
                              // ),
                              Expanded(

                                child:
                                MaterialButton(
                                  elevation: 2,
                                  child: Text('Next'),
                                  onPressed: (){

                                    validateAns(selectedFinal);
                                  },
                                  color: Colors.indigoAccent,
                                ),
                              )

                            ],
                          ),
                        )


                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      onWillPop: () {
        return Future.value(_allow); // if true allow back else block it
      },
    );
  }
}


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fortesting/secondPage.dart';
import 'package:http/http.dart' as http;

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {


  // List <dynamic> items = ['item 1','item 2','item 3','item 4','item 5','item 6','item 7',];
  //
  //
  //
  //
  //
  // Future refresh()async{
  //   setState(() => items.clear());
  //   final url = "https://jsonplaceholder.typicode.com/posts";
  //   final response = await http.get(Uri.parse(url));
  //   print(response.body);
  //   if (response!=null){
  //     if(response.statusCode ==  200){
  //       final List<dynamic>newItems = json.decode(response.body);
  //
  //       setState(() {
  //         items = newItems.map<String>((item){
  //           final  number = item['id'];
  //           return 'Item $number';
  //         }).toList();
  //       });
  //     }
  //   }
  //
  // }

///=----------


  int page = 1;
  List<dynamic> infiniteList = [];
  List<dynamic> dataList = [];
 final controller = ScrollController();
  bool hasMore = true;
  bool isLoading = false ;

 @override
  void initState() {
   fetch();
    controller.addListener(() {
      if(controller.position.maxScrollExtent == controller.offset ){
        fetch();
      }
    });
    super.initState();
  }

  Future fetch()async{
   if(isLoading) return;
   isLoading = true;
   const limit = 20;
    final url = "https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page";
    final response = await http.get(Uri.parse(url));


    if (response!=null){
      if(response.statusCode ==  200){
        final List<dynamic>newItems = json.decode(response.body);
        setState(() {
          page++;
          isLoading = false;
          if(newItems.length<limit){
            hasMore = false;
          }
          infiniteList.addAll(newItems);
        });
      }
    }

  }

  Future infiniteRefresh()async{
    setState(() {
      isLoading = false;
      hasMore = true;
      page = 0;
      infiniteList.clear();

    });
    fetch();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>SecondPage()));
          }, child: Text("Second Page",style: TextStyle(color: Colors.white),))
        ],
      ),
      body:  Container(
        width: 600,
        height: 730,
        color: Colors.greenAccent,
        child:
        // items.isEmpty? Center(child: CircularProgressIndicator()):
        // RefreshIndicator(
        //   onRefresh: refresh,
        //   child: ListView.builder(
        //       padding: EdgeInsets.all(8.0),
        //       itemCount: items.length,
        //       itemBuilder: (_,index){
        //         return ListTile(title: Text(items[index]),);
        //       }
        //
        //   ),
        // ),

        RefreshIndicator(
          onRefresh: infiniteRefresh,
          child: ListView.builder(
            controller: controller,
              padding: EdgeInsets.all(8.0),
              itemCount: infiniteList.length+1,
              itemBuilder: (_,index){
                if (index< infiniteList.length) {
                  final item = infiniteList[index];
                  return ListTile(title: Text("ID NO : ${infiniteList[index]['id']}"),);
                }else{
                 return Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Center(child:
                   hasMore?
                   CircularProgressIndicator() :
                       Text("No More Data")

                   ),
                 );
                }
              }

          ),
        )
      ),

    );
  }
}

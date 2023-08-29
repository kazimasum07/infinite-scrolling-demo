import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {


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

  // Future fetch()async{
  //
  //   if(isLoading) return;
  //   isLoading = true;
  //   const limit = 20;
  //   final url = "https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page";
  //   final response =
  //   await http.get(Uri.parse(url));
  //   if (response!=null){
  //     if(response.statusCode ==  200){
  //       final List<dynamic>newItems = json.decode(response.body);
  //       setState(() {
  //         page++;
  //         isLoading = false;
  //         if(newItems.length<limit){
  //           hasMore = false;
  //         }
  //         infiniteList.addAll(newItems);
  //       });
  //     }
  //   }
  //
  // }


  Future<Response<dynamic>?> getApiResponse(
      String url) async {
    try {
      Dio _dio = Dio();
      String Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey"
          "J0b2tlbl90eXBlIjoiYWNjZXNzIiwi"
          "ZXhwIjoxNjkzMzg3ODM5LCJpYXQiOjE2OT"
          "MzMDE0MzksImp0aSI6ImZjN2VjYjc5ZmNkN"
          "zRmNGE5MWQ0Zjg5MGZkNzk1ZTc2IiwidXNlcl"
          "9pZCI6IjNlODJjZjU0LTdhZTEtNDM4YS1hNTI3"
          "LWI2YTFjODZjZjMzNiJ9.-2Ug9-tog6"
          "WBkhXX-JDF2jloY1O3ODLdhsQv0lxiB2Q";

      print("Token is ---> :: ${Token}");
      print("URL :   ${url}");
      var response = await _dio.get(url,
          options: Options(
            headers: {"Authorization": "Bearer ${Token}"},
          )
      );
      print("---------${response}");
      return response;
    } on DioError catch (error) {
      if (error.response != null) {
        return error.response;
      } else {
        print("Errror on dio calling erros is : ----> $error");
      }

      return null;
    }
  }




  List<dynamic> newItems= [];

  getingNextPage(Response response,int limit, List<dynamic> newItems)async{
    String url = response!.data['next'].toString();
    Response<dynamic>? responseNext = await getApiResponse(response.data['next']);

    if (responseNext!.statusCode == 200) {
      final List<dynamic> newItems2 = List.from(response!.data['results']);
      setState(() async{
        if (newItems.length < limit) {
          hasMore = false;
        }
        //print("${newItems2[10]}");
        newItems.addAll(newItems2);

      });

    }
  }



  Future<void> fetch() async {
    if (isLoading) return;
    isLoading = true;
    const limit = 8;
    //final url = "https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page";
    final url = "http://192.168.0.183:6970/admin/api/v1/trips/all/";
    final dio = Dio();
    try {
      // final response = await dio.get(url,
      //   options: Options(
      //   headers: {"Authorization": "Bearer ${Token}"},
      // )
      // );

      Response<dynamic>? response = await getApiResponse(url);
      print('-------${response}');
      if (response!.statusCode == 200) {
        final List<dynamic> newItems = List.from(response!.data['results']);
        print("Next Page Link :  ${response!.data['next']}");
        setState(() {
          page++;
          isLoading = false;
          if (newItems.length < limit) {
            hasMore = false;
          }

          if(response!.data['next'] != null){
            getingNextPage(response, limit, newItems);
            // String url = response!.data['next'].toString();
            // Response<dynamic>? responseNext = await getPaymentSaveCard(response.data['next']);
            //
            // if (responseNext!.statusCode == 200) {
            //   final List<dynamic> newItems2 = List.from(response!.data['results']);
            //   setState(() async{
            //     if (newItems.length < limit) {
            //       hasMore = false;
            //     }
            //     //print("${newItems2[10]}");
            //     newItems.addAll(newItems2);
            //
            //   });
            //
            // }

          }



          infiniteList.addAll(newItems);
        });
      }
    } catch (error ,subTrace) {
      print('Error fetching data: $error, ${subTrace}');
      setState(() {
        isLoading = false;
      });
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
        backgroundColor: Colors.blueGrey,
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
                padding: EdgeInsets.all(8),
                itemCount: infiniteList.length+1,
                itemBuilder: (_,index){
                  if (index< infiniteList.length) {
                    final item = infiniteList[index];
                    return Container(
                        width: 400,
                        height: 150,
                        child: ListTile(title: Text("ID NO : ${infiniteList[index]['id']}"),));
                  }else{
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child:
                      hasMore?
                          Text("Loading...") :
                      // CircularProgressIndicator() :
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


import 'dart:convert';

import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/data/dummy_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widgets/new_item.dart';
import 'package:http/http.dart'as http;

class GroceryList extends StatefulWidget{

  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
   List<GroceryItem>_groceryItems = [];
   var _isloading = true;
   String? error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems()async{
    final url = Uri.https('shopping-8618f-default-rtdb.firebaseio.com','shopping-list.json');

    try {
      final response = await http.get(url);
      if(response.statusCode>=400){

      }

      if(response.body == 'null'){
        setState(() {
          _isloading = false;
        });
        return;
      }
      final Map<String,dynamic> listdata = json.decode(response.body) ;
      print(listdata.length);
      final List<GroceryItem> loadedItems = [];
      for(final item in listdata.entries){
        final category = categories.entries.firstWhere(
                (catItem) => catItem.value.title==item.value['category']).value;
        loadedItems.add(GroceryItem(id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _groceryItems = loadedItems;
        _isloading = false;
      });
    } catch(err){

      setState(() {
        error = 'failed to fetch data. Please try again later';
      });
    }


}

  void addItem() async{
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(
            builder: (ctx)=> const NewItem()
        ),
    );

    if(newItem==null){
      return;
    }

    setState(() {
      _groceryItems.add(newItem);

    });

  }

  void _removeItem(GroceryItem item) async{
    final index  = _groceryItems.indexOf(item);
    final url = Uri.https(
        'shopping-8618f-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode>=400) {
      setState(() {
        _groceryItems.insert(index,item);

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('no items added yet'),);
    if(_isloading){
      content = const Center(child: CircularProgressIndicator());
    }
    if(_groceryItems.isNotEmpty){
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx,index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction){
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color:_groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if(error!=null){
      content = Center(child: Text(error!),);
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
              onPressed: (){
                addItem();
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body:content,
    );
  }
}
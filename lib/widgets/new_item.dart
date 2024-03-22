import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:http/http.dart'as http;

class NewItem extends StatefulWidget{
  const NewItem({super.key});



  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem>{
  final _formkey = GlobalKey<FormState>();
  var _enteredname = '';
  var _enteredquantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem()async{
    if(_formkey.currentState!.validate()){    //peforms vaidator for all textformfield
      _formkey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https('shopping-8618f-default-rtdb.firebaseio.com','shopping-list.json');
      final response = await http.post(url,
        headers: {
          'Content-Type':'application/json',
        },
        body: json.encode({
      'name': _enteredname,
      'quantity': _enteredquantity,
      'category': _selectedCategory.title},
        ),
      );

      final Map<String,dynamic> resData = json.decode(response.body);
       print(response.body);
       print(response.statusCode);
       if(!context.mounted){
         return;
       }
      Navigator.of(context).pop(GroceryItem(
          id: resData['name'], name: _enteredname, quantity: _enteredquantity, category: _selectedCategory));
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Item'),
      ),
      body:Padding(
        padding:const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration:const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value){
                  if(value == null ||value.isEmpty || value.trim().length<=1 || value.trim().length>50)
                 { return 'Must be b/w 1-50';}
                  return null;
                },
                onSaved: (value){
                  _enteredname = value!;
                },
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: _enteredquantity.toString(),
                        validator: (value){
                          if(value == null ||value.isEmpty || int.tryParse(value)==null || int.tryParse(value)!<=0)
                          { return 'Must be a valid positive number';}
                          return null;
                        },
                      onSaved: (value){
                        _enteredquantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8,),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                        items: [
                          for(final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                                child: Row(children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color:category.value.color,                                ),
                                  const SizedBox(width: 6,),
                                  Text(category.value.title)
                                ],
                    
                            ))
                        ],
                        onChanged: (value){
                        setState(() {
                          _selectedCategory= value!;
                        });

                        }),
                  )
                ],
              ),
              const SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end ,
                children: [
                  TextButton(onPressed: _isSending?null:(){
                        _formkey.currentState!.reset();
                  }, child: const Text('reset')),
                  ElevatedButton(onPressed:_isSending?null: (){_saveItem();},
                      child:_isSending?const SizedBox(
                        height: 16,
                        width: 16,
                        child:CircularProgressIndicator(),): const Text('Add Item')),
                ],
              )

            ],
          ),
        ),
      )
    );
  }


}
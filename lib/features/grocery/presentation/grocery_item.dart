import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/constants/color.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/grocery/domain/grocery_bloc/grocery_bloc.dart';
import 'package:todo_list/features/grocery/domain/grocery_title.models/grocery_title.model.dart';
import 'package:todo_list/features/grocery/domain/models/add_grocery.model.dart';
import 'package:todo_list/features/grocery/domain/models/delete_grocery.model.dart';
import 'package:todo_list/features/grocery/domain/title_grocery_bloc/title_grocery_bloc.dart';
import 'package:todo_list/features/grocery/presentation/update_itemgrocery.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.groceryTitleModel});
  final GroceryTitleModel groceryTitleModel;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late GroceryItemBloc _groceryBloc;

  late TitleGroceryBloc _titleGroceryBloc;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late String groceryId;
  late String title;

  @override
  void initState() {
    super.initState();
    //get ID from groceryTitleModel
    groceryId = widget.groceryTitleModel.id;

    _titleGroceryBloc = BlocProvider.of<TitleGroceryBloc>(context);
    _titleGroceryBloc.add(GetTitleGroceryEvent(userId: groceryId));

    //kani gi gamit para sa title kay di makita ang value sa id ingani-on kani pasabot sa ubos
    title = widget.groceryTitleModel.title;

    _groceryBloc = BlocProvider.of<GroceryItemBloc>(context);
    _groceryBloc.add(GetGroceryEvent(titleID: groceryId));
  }

  // int quantity = 0, price = 0, total = 0;
  // totalCounter() {
  //   quantity = int.parse(_quantityController.text);
  //   price = int.parse(_priceController.text);
  //   total = quantity * price;
  //   return total;
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TitleGroceryBloc, TitleGroceryState>(
      bloc: _titleGroceryBloc,
      listener: _titleGroceryListener,
      builder: (context, state) {
        //kani pasabot sa babaw
        // final title =
        //     state.titleGroceryList.where((e) => e.id == groceryId).first.title;
        if (state.stateStatus == StateStatus.loading) {
          return Container(
            color: Colors.transparent,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state.isUpdated) {
          Navigator.pop(context);
          SnackBarUtils.defualtSnackBar(
              'Grocery successfully updated!', context);
        }
        return Scaffold(
          // appBar: AppBar(
          //   centerTitle: true,
          //   // leading: const Icon(Icons.list_sharp),
          //   titleTextStyle: const TextStyle(fontSize: 30, color: textColor),
          //   backgroundColor: textColor,
          //   // title: Text('$title List'),
          // ),
          appBar: AppBar(
            backgroundColor: primaryColor,
            titleSpacing: 00.0,
            centerTitle: true,
            toolbarHeight: 60.2,
            toolbarOpacity: 0.8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
            ),
            elevation: 0.00,
            titleTextStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
            title: Text('$title List'),
          ),
          body: RefreshIndicator(
            onRefresh: () {
              _groceryBloc.add(GetGroceryEvent(titleID: groceryId));
              return Future<void>.delayed(const Duration(milliseconds: 2));
            },
            child: BlocConsumer<GroceryItemBloc, GroceryItemState>(
              listener: _groceryListener,
              builder: (context, groceryState) {
                if (groceryState.stateStatus == StateStatus.loading) {
                  return Container(
                    color: Colors.transparent,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (groceryState.isEmpty) {
                  return const SizedBox(
                    child: Center(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'No items to display',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  );
                }
                if (groceryState.isDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Items deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                  itemCount: groceryState.groceryList.length,
                  itemBuilder: (context, index) {
                    final groceryList = groceryState.groceryList[index];
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) {
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: Text(
                                  'Are you sure you want to delete ${groceryList.productName}?'),
                              actions: <Widget>[
                                ElevatedButton(
                                    onPressed: () {
                                      _deleteItem(context, groceryList.id);
                                    },
                                    child: const Text('Delete')),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'))
                              ],
                            );
                          },
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        child: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Icon(Icons.delete), Text('Delete')],
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: _groceryBloc,
                                child: UpdateGroceryItemPage(
                                  groceryItemModel: groceryList,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            // title: Text(
                            //   groceryList.productName,
                            //   style: const TextStyle(fontSize: 15),
                            // ),
                            title: Text(
                              "ITEM:${groceryList.productName}\nQTY: ${groceryList.quantity}\nPRICE:${groceryList.price}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Text(
                              'Total ₱: ${groceryList.total}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            onPressed: () {
              _displayAddDialog(context);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _groceryListener(
      BuildContext context, GroceryItemState titleGroceryState) {
    if (titleGroceryState.stateStatus == StateStatus.error) {
      Container(
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()));
      SnackBarUtils.defualtSnackBar(titleGroceryState.errorMessage, context);
    }
  }

  void _titleGroceryListener(
      BuildContext context, TitleGroceryState titleGroceryState) {
    if (titleGroceryState.stateStatus == StateStatus.error) {
      Container(
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()));
      SnackBarUtils.defualtSnackBar(titleGroceryState.errorMessage, context);
    }
  }

  Future _displayAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            scrollable: true,
            title: const Text('Add groceries to your list'),
            content: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val) {
                      return Guard.againstEmptyString(val, 'Product Name');
                    },
                    controller: _productNameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal()),
                        labelText: 'Product Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val) {
                      return Guard.againstEmptyString(val, 'Quantity');
                    },
                    keyboardType: TextInputType.number,
                    controller: _quantityController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal()),
                        labelText: 'Quantity'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val) {
                      return Guard.againstEmptyString(val, 'Price');
                    },
                    keyboardType: TextInputType.number,
                    controller: _priceController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal()),
                        labelText: 'Price'),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: textColor,
                ),
                child: const Text('ADD'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addGroceries(context);

                    Navigator.of(context).pop();
                    _productNameController.clear();
                    _quantityController.clear();
                    _priceController.clear();
                  }
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: textColor,
                ),
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  void _addGroceries(BuildContext context) {
    _groceryBloc.add(AddGroceryEvent(
        addGroceryModel: AddGroceryModel(
      productName: _productNameController.text,
      quantity: int.parse(_quantityController.text),
      price: double.parse(_priceController.text),
      total: double.parse(_priceController.text) *
          int.parse(_quantityController.text),
      titleId: groceryId,
    )));
  }

  void _deleteItem(BuildContext context, String id) {
    _groceryBloc.add(
        DeleteGroceryEvent(deleteGroceryModel: DeleteGroceryModel(id: id)));
    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/constants/color.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/grocery/domain/grocery_bloc/grocery_bloc.dart';
import 'package:todo_list/features/grocery/domain/models/grocery.model.dart';
import 'package:todo_list/features/grocery/domain/models/update_grocery.model.dart';

class UpdateGroceryItemPage extends StatefulWidget {
  const UpdateGroceryItemPage({super.key, required this.groceryItemModel});
  final GroceryItemModel groceryItemModel;

  @override
  State<UpdateGroceryItemPage> createState() => _UpdateGroceryItemPageState();
}

class _UpdateGroceryItemPageState extends State<UpdateGroceryItemPage> {
  late String _updateItemId;
  late TextEditingController _updateProductName;
  late TextEditingController _updateQuantity;
  late TextEditingController _updatePrice;
  late GroceryItemBloc _groceryItemBloc;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _groceryItemBloc = BlocProvider.of<GroceryItemBloc>(context);
    widget.groceryItemModel;

    _updateItemId = widget.groceryItemModel.id;
    _updateProductName =
        TextEditingController(text: widget.groceryItemModel.productName);
    _updateQuantity = TextEditingController(
        text: widget.groceryItemModel.quantity.toString());
    _updatePrice =
        TextEditingController(text: widget.groceryItemModel.price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

        leading: const SizedBox(
          height: 10,
          width: 10,
        ),
        // title: const Text('Update Grocery Items'),
      ),
      body: BlocConsumer<GroceryItemBloc, GroceryItemState>(
        bloc: _groceryItemBloc,
        listener: _itemListener,
        builder: (context, state) {
          if (state.stateStatus == StateStatus.loading) {
            return Container(
              color: Colors.transparent,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Center(
                      child: SizedBox(
                        width: 10,
                        height: 60,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(40),
                        //     border: Border.all(color: Colors.blueGrey)),
                        // child: Image.asset('assets/logo.png'),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Update Grocey Item',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    child: SizedBox(
                      width: 600,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          return Guard.againstEmptyString(val, 'Product Name');
                        },
                        controller: _updateProductName,
                        autofocus: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.horizontal()),
                            labelText: 'Product Name'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    child: SizedBox(
                      width: 600,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          return Guard.againstEmptyString(val, 'Quantity');
                        },
                        controller: _updateQuantity,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.horizontal()),
                            labelText: 'Quantity'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    child: SizedBox(
                      width: 600,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          return Guard.againstEmptyString(val, 'Price');
                        },
                        controller: _updatePrice,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.horizontal()),
                            labelText: 'Price'),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: textColor),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _updateItem(context);
                                }
                              },
                              child: const Text('Update')),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 16),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: textColor),
                              onPressed: () {
                                _updateItem(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _itemListener(BuildContext context, GroceryItemState state) {
    if (state.stateStatus == StateStatus.error) {
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
      return;
    }

    if (state.isUpdated) {
      Navigator.pop(context);
      SnackBarUtils.defualtSnackBar('Task successfully updated!', context);
      return;
    }
  }

  void _updateItem(BuildContext context) {
    _groceryItemBloc.add(
      UpdateGroceryEvent(
        updateGroceryModel: UpdateGroceryModel(
            id: _updateItemId,
            productName: _updateProductName.text,
            quantity: int.parse(_updateQuantity.text),
            price: double.parse(_updatePrice.text),
            total: int.parse(_updateQuantity.text) *
                double.parse(_updatePrice.text)),
      ),
    );
  }
}

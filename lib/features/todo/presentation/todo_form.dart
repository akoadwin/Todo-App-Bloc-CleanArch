import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/constants/color.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/todo/domain/models/create_todo.model.dart';
import 'package:todo_list/features/todo/domain/models/update_todo.models.dart';
import 'package:todo_list/features/todo/domain/todo_bloc/todo_bloc.dart';

class MyFormPage extends StatefulWidget {
  const MyFormPage({super.key, required this.todoModel});
  final TodoModel todoModel;

  @override
  State<MyFormPage> createState() => _MyFormPageState();
}

class _MyFormPageState extends State<MyFormPage> {
  late TextEditingController _updatedId;
  late TextEditingController _updateTitleController;
  late TextEditingController _updateDescriptionController;
  late TodoBloc _todoBloc;
    final GlobalKey<FormState> _formKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _todoBloc = BlocProvider.of<TodoBloc>(context);
    widget.todoModel;
    _updateTitleController =
        TextEditingController(text: widget.todoModel.title);
    _updateDescriptionController =
        TextEditingController(text: widget.todoModel.description);
    _updatedId = TextEditingController(text: widget.todoModel.id);
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
        leading: const Icon(
         
          Icons.edit_document,
          size: 30.0,
          color: textColor,
        ),
        automaticallyImplyLeading: false,
       
        actions: const <Widget>[],

        title: const Text('Edit Task'),
        titleTextStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
      ),

      body: BlocConsumer<TodoBloc, TodoState>(
        bloc: _todoBloc,
        listener: _todoListener,
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
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: SizedBox(
                    width: 600,
                    child: TextFormField(
                       autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val) {
                      return Guard.againstEmptyString(val, 'Title');
                    },
                      controller: _updateTitleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal()),
                          labelText: 'Title'),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: SizedBox(
                    width: 600,
                    child: TextFormField(
                       autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val) {
                      return Guard.againstEmptyString(val, 'Description');
                    },
                      controller: _updateDescriptionController,
                      autofocus: true,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal()),
                          labelText: 'Description'),
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
                              foregroundColor: textColor,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()){
                                _updateTask(context);
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
                              foregroundColor: textColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _todoListener(BuildContext context, TodoState state) {
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

  void _updateTask(BuildContext context) {
    _todoBloc.add(
      UpdateTodoEvent(
        updateTodoModel: UpdateTodoModel(
            id: _updatedId.text,
            title: _updateTitleController.text,
            description: _updateDescriptionController.text),
      ),
    );
  }
}

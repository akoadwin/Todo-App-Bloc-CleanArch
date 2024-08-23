import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/constants/color.dart';
import 'package:todo_list/core/dependency_injection/di_container.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/auth/domain/bloc/auth/auth_bloc.dart';
import 'package:todo_list/features/auth/domain/models/auth_user.model.dart';
import 'package:todo_list/features/grocery/domain/grocery_bloc/grocery_bloc.dart';
import 'package:todo_list/features/grocery/domain/title_grocery_bloc/title_grocery_bloc.dart';
import 'package:todo_list/features/grocery/presentation/grocery_title.dart';
import 'package:todo_list/features/auth/presentation/pages/login.dart';
import 'package:todo_list/features/todo/domain/models/add_todo.model.dart';
import 'package:todo_list/features/todo/domain/models/check_model.dart';
import 'package:todo_list/features/todo/domain/models/delete.model.dart';
import 'package:todo_list/features/todo/domain/todo_bloc/todo_bloc.dart';
import 'package:todo_list/features/todo/presentation/todo_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.authUserModel});
  final AuthUserModel authUserModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DIContainer diContainer = DIContainer();
  late AuthBloc _authBloc;
  late TodoBloc _todoBloc;

  late String userId;
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);

    userId = widget.authUserModel.userId;

    _todoBloc.add(GetTodoEvent(userId: userId));
    _authBloc.add(AuthAutoLoginEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: _authBloc,
      listener: _authListener,
      builder: (context, state) {
        if (state.stateStatus == StateStatus.loading) {
          return Container(
            color: Colors.transparent,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return BlocListener<TodoBloc, TodoState>(
          bloc: _todoBloc,
          listener: _todoListener,
          child: BlocBuilder<TodoBloc, TodoState>(
            bloc: _todoBloc,
            builder: (context, todoState) {
              if (todoState.isUpdated) {
                return Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return PopScope(
                canPop: false,
                // onWillPop: () async => false,
                child: Scaffold(
                  drawer: Drawer(
                    backgroundColor: textColor,
                    child: Builder(builder: (context) {
                      final userId = state.authUserModel;
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          DrawerHeader(
                            decoration:
                                const BoxDecoration(color: primaryColor),
                            child: ListView(
                              children: <Widget>[
                                const Icon(
                                  Icons.person,
                                  size: 70,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${userId!.firstName.capitalize()} ${userId.lastName.capitalize()}',
                                      style: const TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      userId.email,
                                      style: const TextStyle(
                                          fontSize: 12, color: textColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            title: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.work_history_outlined),
                                Padding(
                                  padding: EdgeInsets.all(13.0),
                                  child: Text(
                                    'Todo',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shopping_cart_outlined),
                                Padding(
                                  padding: EdgeInsets.all(13.0),
                                  child: Text(
                                    'Grocery',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MultiBlocProvider(
                                    providers: [
                                      BlocProvider<TitleGroceryBloc>(
                                        create: (BuildContext context) =>
                                            diContainer.titleGroceryBloc,
                                      ),
                                      BlocProvider<GroceryItemBloc>(
                                          create: (BuildContext context) =>
                                              diContainer.groceryItemBloc),
                                      BlocProvider.value(
                                        value: _authBloc,
                                      ),
                                    ],
                                    child: GroceryTitlePage(
                                      authUserModel: userId,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                  appBar: AppBar(
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
                    title: const Center(
                      child: Text("Todo List"),
                    ),
                    titleTextStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                    backgroundColor: primaryColor,
                    actions: <Widget>[
                      IconButton(
                          onPressed: _logout,
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.black,
                          ))
                    ],
                  ),
                  body: Builder(builder: (context) {
                    if (todoState.stateStatus == StateStatus.loading) {
                      return Container(
                        color: Colors.transparent,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (todoState.isEmpty) {
                      return const SizedBox(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Text(
                              'No task to display',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () {
                        _todoBloc.add(GetTodoEvent(userId: userId));
                        return Future<void>.delayed(
                            const Duration(milliseconds: 1));
                      },
                      child: ListView.builder(
                        itemCount: todoState.todoList.length,
                        itemBuilder: (context, index) {
                          final item = todoState.todoList[index];
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
                                        'Are you sure you want to delete ${item.title}?'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                          onPressed: () {
                                            _deleteTask(context, item.id);
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
                                  children: [
                                    Icon(Icons.delete),
                                    Text('Delete')
                                  ],
                                ),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: _todoBloc,
                                      child: MyFormPage(
                                        todoModel: item,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Card(
                                  child: ListTile(
                                    title: Text(item.title),
                                    subtitle: Text(item.description),
                                    trailing: Checkbox(
                                        value: item.isChecked,
                                        onChanged: (bool? newIsChecked) {
                                          _checkListener(context, item.id,
                                              newIsChecked ?? false);
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  floatingActionButton: FloatingActionButton(
                    backgroundColor: primaryColor,
                    onPressed: () {
                      _displayAddDialog(context);
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _authListener(BuildContext context, AuthState state) {
    if (state.stateStatus == StateStatus.error) {
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
      return;
    }

    if (state.stateStatus == StateStatus.initial) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MultiBlocProvider(providers: [
              BlocProvider<AuthBloc>(
                  create: (BuildContext context) => diContainer.authBloc),
              BlocProvider<TodoBloc>(
                  create: (BuildContext context) => diContainer.todoBloc)
            ], child: const LoginPage()),
          ),
          ModalRoute.withName('/'));
    }
  }

  void _todoListener(BuildContext context, TodoState state) {
    if (state.stateStatus == StateStatus.error) {
      Container(
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()));
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
    }

    if (state.isDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task successfully deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _logout() {
    _authBloc.add(AuthLogoutEvent());
  }

  Future _displayAddDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Form(
            key: _formKey,
            child: AlertDialog(
              scrollable: true,
              title: const Text('Add a task to your list'),
              content: Column(
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (val) {
                      return Guard.againstEmptyString(val, 'Title');
                    },
                    controller: _titleController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.horizontal()),
                        labelText: 'Title'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) {
                          return Guard.againstEmptyString(val, 'Description');
                        },
                        controller: _descriptionController,
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
                      _addTask(context);
                      Navigator.of(context).pop();
                      _titleController.clear();
                      _descriptionController.clear();
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
        });
  }

  void _addTask(BuildContext context) {
    _todoBloc.add(
      AddTodoEvent(
        addtodoModel: AddTodoModel(
          title: _titleController.text,
          description: _descriptionController.text,
          userId: userId,
        ),
      ),
    );
  }

  void _checkListener(BuildContext context, String id, bool isChecked) {
    _todoBloc.add(
      CheckedEvent(
        checkTodoModel: CheckTodoModel(
          id: id,
          isChecked: isChecked,
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, String id) {
    _todoBloc.add(
      DeleteTodoEvent(
        deleteTaskModel: DeleteTaskModel(id: id),
      ),
    );
    Navigator.of(context).pop();
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

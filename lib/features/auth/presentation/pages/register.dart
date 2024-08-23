import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/constants/color.dart';
import 'package:todo_list/core/dependency_injection/di_container.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/auth/domain/bloc/auth/auth_bloc.dart';
import 'package:todo_list/features/auth/domain/models/register_model.dart';
import 'package:todo_list/features/todo/domain/todo_bloc/todo_bloc.dart';
import 'home.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final DIContainer diContainer = DIContainer();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Registration Page',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
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
        backgroundColor:primaryColor,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: _authBloc,
        listener: _authBlocListener,
        builder: (context, state) {
          if (state.stateStatus == StateStatus.loading) {
            return _loadingWidget();
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
                        width: 120,
                        height: 40,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(40),
                        //     border: Border.all(color: Colors.blueGrey)),
                        // child: Image.asset('assets/logo.png'),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: "Enter your first name",
                        labelText: "First Name",
                        prefixIcon: const Icon(Icons.person),
                        errorStyle: const TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9.0)),
                      ),
                      validator: (val) {
                        return Guard.againstEmptyString(val, 'First Name');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: "Enter your last name",
                        labelText: "Last name",
                        prefixIcon: const Icon(Icons.group),
                        errorStyle: const TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9.0)),
                      ),
                      validator: (val) {
                        return Guard.againstEmptyString(val, 'Last Name');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Enter a valid email",
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_rounded),
                        errorStyle: const TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9.0)),
                      ),
                      validator: (val) {
                        return Guard.againstInvalidEmail(val, 'Email');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password at least 8 characters",
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.key_outlined),
                        errorStyle: const TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9.0)),
                      ),
                      validator: (val) {
                        return Guard.againstEmptyString(val, 'Password');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm your Password",
                        labelText: "Confirm Password",
                        prefixIcon: const Icon(Icons.key_rounded),
                        errorStyle: const TextStyle(fontSize: 12.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9.0)),
                      ),
                      validator: (String? val) {
                        return Guard.againstNotMatch(
                            val, _passwordController.text, 'Password');
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 10.0, 40.0, 5.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 33, 110, 243),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            )),
                        onPressed: () {
                          _register(context);
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 15)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _authBlocListener(BuildContext context, AuthState state) {
    if (state.stateStatus == StateStatus.error) {
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
    }

    if (state.authUserModel != null) {
      SnackBarUtils.defualtSnackBar('Success!', context);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(
                  create: (BuildContext context) => diContainer.authBloc,
                ),
                BlocProvider<TodoBloc>(
                  create: (BuildContext context) => diContainer.todoBloc,
                ),
              ],
              child: HomePage(
                authUserModel: state.authUserModel!,
              ),
            ),
          ),
          ModalRoute.withName('/'));
    }
  }

  Widget _loadingWidget() {
   return Container(
      color: Colors.transparent,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _register(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _authBloc.add(AuthRegisterEvent(
          registerModel: RegisterModel(
              email: _emailController.text,
              password: _passwordController.text,
              confirmPassword: _confirmController.text,
              firstName: _firstNameController.text,
              lastName: _lastNameController.text)));
    }
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  static const name = 'register-screen';

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  DateTime? selectedDate;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
    return picked;
  }

  String formattedDate(DateTime? date) {
    if (date == null) {
      return 'Please select a date';
    } else {
      final formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(date);
    }
  }

  void _showSnackBar(BuildContext scaffoldContext, String message) {
    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldContext = context;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 300, // Ancho deseado
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 300, // Ancho deseado
                child: TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 300, // Ancho deseado
                child: TextField(
                  controller: apellidoController,
                  decoration: const InputDecoration(labelText: 'Lastname'),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 300, // Ancho deseado
                child: TextField(
                  controller: direccionController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 300, // Ancho deseado
                child: TextField(
                  controller: claveController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 300, // Ancho deseado
                child: TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 300, // Ancho deseado
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Birthday Date: ${formattedDate(selectedDate)}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newDate = await _selectDate(context);
                        if (newDate != null) {
                          setState(() {
                            selectedDate = newDate;
                          });
                        }
                      },
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Aquí puedes enviar los datos del formulario a tu backend o realizar otra acción
                  final email = emailController.text;
                  final nombre = nombreController.text;
                  final apellido = apellidoController.text;
                  final direccion = direccionController.text;
                  final clave = claveController.text;
                  final telefono = telefonoController.text;

                  if (email.isNotEmpty &&
                      nombre.isNotEmpty &&
                      apellido.isNotEmpty &&
                      direccion.isNotEmpty &&
                      clave.isNotEmpty &&
                      telefono.isNotEmpty &&
                      selectedDate != null) {
                    final HttpLink httpLink = HttpLink(
                      'http://localhost/graphql?',
                    );
                    // Reemplaza con tu URL GraphQL

                    final GraphQLClient client = GraphQLClient(
                      link: httpLink,
                      cache: GraphQLCache(),
                    );

                    // Define la mutación GraphQL
                    const String createUserMutation = r'''
                      mutation CreateUser($input: UsuarioInput!) {
                        createUsuario(usuario: $input) {
                          email
                          nombre
                          apellido
                          rol
                        }
                      }
                    ''';

                    // Variables para la mutación
                    final Map<String, dynamic> variables = {
                      'input': {
                        'email': email,
                        'nombre': nombre,
                        'apellido': apellido,
                        'direccion': direccion,
                        'clave': clave,
                        'telefono': telefono,
                        'birthday': selectedDate.toString(),
                        'rol': 'user', // Valor fijo del parámetro "rol"
                      },
                    };

                    log(json.encode(variables));
                    // Realiza la mutación
                    final QueryResult result = await client.mutate(
                      MutationOptions(
                        document: gql(createUserMutation),
                        variables: variables,
                      ),
                    );

                    if (result.hasException) {
                      _showSnackBar(scaffoldContext,
                          'Mutation error: ${result.exception.toString()}');
                    } else {
                      _showSnackBar(
                          scaffoldContext, 'User successfully registered');
                    }
                  } else {
                    _showSnackBar(
                        scaffoldContext, 'Please complete all fields.');
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

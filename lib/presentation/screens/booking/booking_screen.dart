import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  static const name = 'booking-screen';
  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  String currenDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController userController = TextEditingController();
  final TextEditingController flightController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  Map<String, dynamic> formData = {};

  final HttpLink httpLink = HttpLink('http://localhost/graphql?');

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<String?> _cargarPreferencias() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('token');
    return action;
  }

  @override
  void initState() {
    super.initState();
    // Llama a la función que deseas ejecutar al cargar el screen
    cargarUsuarioDesdePreferencias();
  }

  // Función para cargar el usuario desde las preferencias
  Future<void> cargarUsuarioDesdePreferencias() async {
    final String? usuario = await _cargarPreferencias();
    Map<String, dynamic>? decodedToken;
    if (usuario != null) {
      decodedToken = JwtDecoder.decode(usuario);
    }
    String? email = decodedToken?['email'];

    if (email != null) {
      userController.text = email;
    } else {
      userController.text = "Default";
    }
  }

  Widget build(BuildContext context) {
    Future<void> getCurrent(BuildContext context) async {
      final DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)));

      if (date != null) {
        setState(() {
          currenDate = DateFormat("yyyy-MM-dd").format(date);
        });
      }
    }

    Future<void> getCurrentTime(BuildContext context) async {
      final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        initialEntryMode: TimePickerEntryMode.dial,
      );
      if (timeOfDay != null) {
        setState(() {
          selectedTime = timeOfDay;
        });
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: flightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Vuelo'),
            ),
            TextField(
              controller: stateController,
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(children: [
                  Text("Fecha: $currenDate"),
                  IconButton(
                      onPressed: () {
                        getCurrent(context);
                      },
                      icon: const Icon(
                        Icons.date_range,
                        size: 35,
                      )),
                ]),
                Row(children: [
                  Text("Hora: ${formatTimeOfDay(selectedTime)}"),
                  IconButton(
                      onPressed: () {
                        getCurrentTime(context);
                      },
                      icon: const Icon(
                        Icons.av_timer,
                        size: 35,
                      )),
                ]),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                formData['booking_user_id'] = userController.text;
                formData['booking_flight_id'] =
                    int.tryParse(flightController.text) ?? 0;
                formData['booking_date'] = currenDate;
                formData['booking_time'] = formatTimeOfDay(selectedTime);
                formData['booking_state'] = stateController.text;
                formData['booking_price'] =
                    int.tryParse(priceController.text) ?? 0;

                // Convierte el mapa a una cadena JSON
                String jsonText = jsonEncode(formData);
                log(jsonText);
                final String? token = await _cargarPreferencias();
                final AuthLink authLink =
                    AuthLink(getToken: () async => 'Bearer $token');
                final Link link = authLink.concat(httpLink);
                final GraphQLClient client = GraphQLClient(
                  link: link,
                  cache: GraphQLCache(),
                );

                // Define la mutación GraphQL
                const String createBookingMutation = r'''
                      mutation CreateReserva($input: ReservaInput!) {
                        createReserva(reserva: $input) {
                          booking_user_id
                          booking_flight_id
                          booking_date
                          booking_time
                          booking_state
                          booking_price
                        }
                      }
                    ''';
                // Variables para la mutación
                final Map<String, dynamic> variables = {
                  'input': {
                    'booking_id': 11,
                    'booking_user_id': formData['booking_user_id'],
                    'booking_flight_id': formData['booking_flight_id'],
                    'booking_date': formData['booking_date'],
                    'booking_time': formData['booking_time'],
                    'booking_state': formData['booking_state'],
                    'booking_price': formData['booking_price'],
                  },
                };
                log('VARIABLES');
                log(json.encode(variables));

                // Realiza la mutación
                String mensaje = "Reserva registrada con éxito";
                Color color = Colors.green;

                try {
                  // ignore: unused_local_variable
                  final QueryResult result = await client.mutate(
                    MutationOptions(
                      document: gql(createBookingMutation),
                      variables: variables,
                    ),
                  );
                } catch (HttpLinkParserException) {
                  mensaje =
                      'Error en la mutación: \n${HttpLinkParserException.toString()}';
                }

                final snackBar = SnackBar(
                  content: Text(mensaje),
                  backgroundColor: color,
                  duration: const Duration(
                      seconds: 5), // Duración del mensaje en segundos
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FlightsCRUD extends StatefulWidget {
  const FlightsCRUD({Key? key}) : super(key: key);
  static const name = 'flights-CRUD';

  @override
  State<FlightsCRUD> createState() => _FlightsCRUD();
}

class _FlightsCRUD extends State<FlightsCRUD> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                //context.pop();
                context.replace('/CreateCountry');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text('Crear Ciudad'),
            ),
          ],
        ),
      ),
    );
  }
}

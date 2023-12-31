import 'package:go_router/go_router.dart';
import 'package:tripster_ma/presentation/screens/flightsCRUD/create_country.dart';
import 'package:tripster_ma/presentation/screens/screens.dart';

final appRouter = GoRouter(initialLocation: '/', routes: [
  GoRoute(
    path: '/',
    name: InitialScreen.name,
    builder: (context, state) => const InitialScreen(),
  ),
  GoRoute(
    path: '/login',
    name: LoginScreen.name,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/register',
    name: RegisterScreen.name,
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: '/home',
    name: HomeScreen.name,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/profile',
    name: ProfileScreen.name,
    builder: (context, state) => const ProfileScreen(),
  ),
  GoRoute(
    path: '/search',
    name: SearchScreen.name,
    builder: (context, state) => const SearchScreen(),
  ),
  GoRoute(
    path: '/booking',
    name: BookingScreen.name,
    builder: (context, state) => const BookingScreen(),
  ),
  GoRoute(
    path: '/FlightsCRUD',
    name: FlightsCRUD.name,
    builder: (context, state) => const FlightsCRUD(),
  ),
  GoRoute(
    path: '/CreateCountry',
    name: CreateCountry.name,
    builder: (context, state) => const CreateCountry(),
  ),
]);

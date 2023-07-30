import 'package:cliff/screens/Admin/add_designs_screen.dart';
import 'package:cliff/screens/Events/event_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cliff/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cliff/widgets/homescreenwidget/buttom_navigation_bar.dart';
import 'package:cliff/screens/Merch/merch_details_screen.dart';
import 'package:cliff/screens/Admin/create_event_screens.dart';
import 'package:cliff/screens/Admin/admin_screen.dart';
import 'package:cliff/screens/Auth/auth_screen.dart';
import 'package:cliff/screens/alumni_screen.dart';
import 'package:cliff/screens/Merch/buy_merch_screen.dart';
import 'package:cliff/screens/Events/event_screen.dart';
import 'package:cliff/screens/history_screen.dart';
import 'package:cliff/screens/Home/home_screen.dart';
import 'package:cliff/screens/Auth/singup_screen.dart';
import 'package:cliff/screens/memories.dart';
import 'package:cliff/screens/polls.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Color brandColor = const Color(0xFF4166f5);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? dark) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        final brightness = MediaQuery.of(context).platformBrightness;

        if (lightDynamic != null && dark != null) {
          lightColorScheme = lightDynamic.harmonized()..copyWith();
          lightColorScheme = lightColorScheme.copyWith(secondary: brandColor);
          darkColorScheme = dark.copyWith(secondary: brandColor);
        } else {
          lightColorScheme = ColorScheme.fromSeed(
              seedColor: brandColor, brightness: Brightness.light);
          darkColorScheme = ColorScheme.fromSeed(
              seedColor: brandColor, brightness: Brightness.dark);
        }

        final colorScheme =
            brightness == Brightness.dark ? darkColorScheme : lightColorScheme;

        return MaterialApp(
          title: 'CLIFF',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: colorScheme,
            useMaterial3: true,
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomePage();
              }
              return const AuthScreen();
            },
          ),
          routes: {
            SignUpScreen.routeName: (ctx) => const SignUpScreen(),
            AuthScreen.routeName: (ctx) => const AuthScreen(),
            EventsScreen.routeName: (ctx) => const EventsScreen(),
            HistoryScreen.routeName: (ctx) => const HistoryScreen(),
            BuyMerchScreen.routeName: (ctx) => const BuyMerchScreen(),
            AlumniScreen.routeName: (ctx) => const AlumniScreen(),
            Memories.routeName: (ctx) => const Memories(),
            Polls.routeName: (ctx) => const Polls(),
            AdminScreen.routeName: (ctx) => const AdminScreen(),
            CreateEventScreen.routeName: (ctx) => const CreateEventScreen(),
            HomeScreen.routeName: (ctx) => const HomeScreen(),
            MerchDetails.routeName: (ctx) {
              final Map<String, dynamic>? args = ModalRoute.of(ctx)!
                  .settings
                  .arguments as Map<String, dynamic>?;
              return MerchDetails(
                merchName: args?['merchName'] ?? 'Default Name',
                merchPrice: args?['merchPrice'] ?? 0,
                merchDesc: args?['merchDesc'] ?? 'Default Description',
                photoUrl: args?['photoUrl'] ?? 'Default Url',
              );
            },
            AddDesignsScreen.routeName: (ctx) => const AddDesignsScreen(),
            EventDetailsScreen.routeName: (ctx) {
              final Map<String, dynamic>? args = ModalRoute.of(ctx)!
                  .settings
                  .arguments as Map<String, dynamic>?;
              return EventDetailsScreen(
                title: args?['title'] ?? 'Default Title',
                eventCode: args?['eventCode'] ?? 'Default Event Code',
                eventDescription:
                    args?['eventDescription'] ?? 'Default Event Description',
                eventFinishDateTime:
                    args?['eventFinishDateTime'] ?? 'Default Date and Time',
                eventImage: args?['eventImage'] ?? 'Default Url',
                eventStartDateTime:
                    args?['eventFinishStartTime'] ?? 'Default Date and Time',
                eventVenue: args?['eventVenue'] ?? 'Default Event Venue',
                clubMembersic1: args?['clubmembersic1'] ?? 'Default Sic',
                clubMembersic2: args?['clubmembersic2'] ?? 'Default Sic',
              );
            },
          },
        );
      },
    );
  }
}

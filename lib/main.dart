import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/firebase_options.dart';
import 'package:bluebird/utils/providers/location_service_provider.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:bluebird/utils/providers/trip_provider.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/utils/services/background_location_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark),
  );
  runApp(const BlueBirdApp());
}

class BlueBirdApp extends StatefulWidget {
  const BlueBirdApp({Key? key}) : super(key: key);

  @override
  State<BlueBirdApp> createState() => _BlueBirdAppState();
}

class _BlueBirdAppState extends State<BlueBirdApp> {
  @override
  void initState() {
    var updater = GetStorage().read('locationUpdate');
    if (updater != null) {
      var tripId = GetStorage().read('activeTrip');
      BackgroundLocationService().startLocationPosting(tripId);
    }
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PhoneNumberAuth>(create: (BuildContext context) => PhoneNumberAuth()),
        ChangeNotifierProvider<AuthenticationInfoProvider>(create: (BuildContext context) => AuthenticationInfoProvider()),
        ChangeNotifierProvider<AuthenticationDataProvider>(create: (BuildContext context) => AuthenticationDataProvider()),
        ChangeNotifierProvider<RegisterUserProvider>(create: (BuildContext context) => RegisterUserProvider()),
        ChangeNotifierProvider<DetailsAddProvider>(create: (BuildContext context) => DetailsAddProvider()),
        ChangeNotifierProvider<IdentityProvider>(create: (BuildContext context) => IdentityProvider()),
        ChangeNotifierProvider<IdentityFormProvider>(create: (BuildContext context) => IdentityFormProvider()),
        ChangeNotifierProvider<UploadFilesProvider>(create: (BuildContext context) => UploadFilesProvider()),
        ChangeNotifierProvider<LocationProvider>(create: (BuildContext context) => LocationProvider()),
        ChangeNotifierProvider<TripProvider>(create: (BuildContext context) => TripProvider()),
      ],
      child: DismissKeyboard(
        child: GetMaterialApp(
          title: 'BlueBird',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            dividerColor: AppColors.colorGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Palette.kPrimarySwatch).copyWith(background: AppColors.fullWhite),
          ),
          initialRoute: AuthenticationService().userLoggedIn(),
          onGenerateRoute: RouteGenerator.generateRoute,
        ),
      ),
    );
  }
}

class Palette {
  static const MaterialColor kPrimarySwatch = MaterialColor(0xFF224769, <int, Color>{
    50: Color(0x00385978),
    100: Color(0x004e6c87),
    200: Color(0x00647e96),
    300: Color(0x007a91a5),
    400: Color(0x0091a3b4),
    500: Color(0x00a7b5c3),
    600: Color(0x00bdc8d2),
    700: Color(0x00d3dae1),
    800: Color(0x00e9edf0),
    900: Color(0x00ffffff),
  });
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;
  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}

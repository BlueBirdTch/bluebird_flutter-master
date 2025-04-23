import 'package:bluebird/screens/auth_checker/auth_checker.dart';
import 'package:bluebird/screens/authentication/register/documents/aadhar_page.dart';
import 'package:bluebird/screens/authentication/register/documents/details_page.dart';
import 'package:bluebird/screens/authentication/register/documents/driving_license_page.dart';
import 'package:bluebird/screens/authentication/register/documents/identity_details.dart';
import 'package:bluebird/screens/authentication/register/documents/pan_card_page.dart';
import 'package:bluebird/screens/authentication/register/documents/rca_page.dart';
import 'package:bluebird/screens/authentication/register/documents/selfie_page.dart';
import 'package:bluebird/screens/authentication/register/documents/trade_license.dart';
import 'package:bluebird/screens/authentication/register/select_account_type.dart';
import 'package:bluebird/screens/home_page/driver/search_page.dart';
import 'package:bluebird/screens/home_page/home_page.dart';
import 'package:bluebird/screens/authentication/otp_page.dart';
import 'package:bluebird/screens/authentication/phone_number.dart';
import 'package:bluebird/screens/home_page/transporter/add_trip/add_trip_details.dart';
import 'package:bluebird/screens/settings/settings_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const authChecker = 'authChecker';
  static const homePage = 'homePage';
  static const phoneNumberPage = 'phoneNumberPage';
  static const otpPage = 'otpPage';
  static const selectAccount = 'selectAccount';
  static const selfiePage = 'selfiePage';
  static const detailsPage = 'detailsPage';
  static const identityDetails = 'identityDetails';
  static const aadharPage = 'aadharPage';
  static const panCardPage = 'panCardPage';
  static const drivingLicensePage = 'drivingLicensePage';
  static const rcaPage = 'rcaPage';
  static const tradeLicensePage = 'tradeLicensePage';
  static const settings = 'settings';
  static const addTrip = 'addTrip';
  static const searchPage = 'searchPage';
}

class RouteGenerator {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homePage:
        return MaterialPageRoute(builder: (_) => const Homepage());
      case AppRoutes.authChecker:
        return MaterialPageRoute(builder: (_) => const AuthChecker());
      case AppRoutes.phoneNumberPage:
        return MaterialPageRoute(builder: (_) => PhoneNumberPage());
      case AppRoutes.otpPage:
        return MaterialPageRoute(builder: (_) => const OTPPage());
      case AppRoutes.selectAccount:
        return MaterialPageRoute(builder: (_) => const AccountCreation());
      case AppRoutes.selfiePage:
        return MaterialPageRoute(builder: (_) => const SelfiePage());
      case AppRoutes.detailsPage:
        return MaterialPageRoute(builder: (_) => const DetailsPage());
      case AppRoutes.identityDetails:
        return MaterialPageRoute(builder: (_) => const IdentityDetailsForm());
      case AppRoutes.aadharPage:
        return MaterialPageRoute(builder: (_) => const AadharPage());
      case AppRoutes.panCardPage:
        return MaterialPageRoute(builder: (_) => const PANCard());
      case AppRoutes.drivingLicensePage:
        return MaterialPageRoute(builder: (_) => const DrivingLicensePage());
      case AppRoutes.rcaPage:
        return MaterialPageRoute(builder: (_) => const RCAPage());
      case AppRoutes.tradeLicensePage:
        return MaterialPageRoute(builder: (_) => const TradeLicensePage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppRoutes.addTrip:
        return MaterialPageRoute(builder: (_) => const AddTripDetails());
      case AppRoutes.searchPage:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return const Scaffold(
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}

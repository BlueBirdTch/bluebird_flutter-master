import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:bluebird/screens/home_page/transporter/add_trip/cargo_search.dart';
import 'package:bluebird/utils/providers/location_service_provider.dart';
import 'package:bluebird/utils/providers/trip_provider.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConfirmTrip extends StatefulWidget {
  const ConfirmTrip({
    Key? key,
    required this.distance,
    required this.source,
    required this.destination,
  }) : super(key: key);
  final double distance;
  final Map<String, dynamic> source;
  final Map<String, dynamic> destination;

  @override
  State<ConfirmTrip> createState() => _ConfirmTripState();
}

class _ConfirmTripState extends State<ConfirmTrip> {
  final TextEditingController _source = TextEditingController();
  final TextEditingController _dest = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _truck = TextEditingController();
  final TextEditingController _type = TextEditingController();
  final TextEditingController _duration = TextEditingController();
  final TextEditingController _payment = TextEditingController();
  String paymentType = '', advancePayment = '';
  LocationProvider? location;
  TripProvider? trip;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    location = Provider.of<LocationProvider>(context, listen: false);
    trip = Provider.of<TripProvider>(context, listen: false);
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.fullWhite,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 26),
            child: Text('Confirm Trip Details', style: AppTextStyles.fontBoldBlue24),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Distance: ', style: AppTextStyles.fontBoldBlue20),
                  TextSpan(text: '${widget.distance.toStringAsFixed(3)} KM', style: AppTextStyles.fontBoldBlue20.copyWith(color: AppColors.statusOK)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              primary: true,
              children: [
                const SizedBox(height: 16),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26.0), child: Text('Cargo Details', style: AppTextStyles.fontBoldBlue20)),
                const SizedBox(height: 16),
                AppTextField(
                  textController: _type,
                  hintText: 'Enter Cargo Type',
                  labelText: 'Cargo Type',
                  autoFocus: false,
                  textInput: TextInputType.none,
                  onTapAction: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: AppColors.fullWhite,
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: const CargoSearch(isMaterial: true),
                        );
                      },
                    );
                    if (trip!.cargo.isNotEmpty) {
                      _type.text = trip!.cargo;
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  textController: _weight,
                  hintText: 'Enter Cargo Weight in Tonnes',
                  labelText: 'Cargo Weight',
                  autoFocus: false,
                  textInput: TextInputType.number,
                  onChangedAction: (value) => setState(() => false),
                ),
                const SizedBox(height: 16),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Trip Expiration:', style: AppTextStyles.fontBlue16)),
                const SizedBox(height: 8),
                AppTextField(
                  textController: _duration,
                  hintText: 'Trip Expiration Date',
                  labelText: 'Expiration Date',
                  autoFocus: false,
                  textInput: TextInputType.none,
                  onTapAction: () {
                    var lastDate = DateTime.now().add(const Duration(days: 3));
                    var firstDate = DateTime.now();
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: firstDate,
                      lastDate: lastDate,
                      initialDatePickerMode: DatePickerMode.day,
                    ).then((date) {
                      var formattedDate = DateFormat('dd/MM/yyyy').format(date as DateTime);
                      setState(() {
                        _duration.text = formattedDate;
                      });
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'After the trip has expired, BlueBird will try to contact you regarding the trip and help you find a driver.',
                    style: AppTextStyles.fontGrey14,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26.0), child: Text('Payment Details', style: AppTextStyles.fontBoldBlue20)),
                const SizedBox(height: 16),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Payment Type', style: AppTextStyles.fontBlue16)),
                const SizedBox(height: 8),
                Container(
                  width: width,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    primary: false,
                    padding: EdgeInsets.zero,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            paymentType = 'tonne';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: paymentType == 'tonne' ? AppColors.baseColor : AppColors.fullWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1.0, color: AppColors.baseColor),
                          ),
                          child: Text(
                            'per Tonne',
                            style: paymentType == 'tonne' ? AppTextStyles.fontWhite16 : AppTextStyles.fontBlue16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            paymentType = 'truck';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: paymentType == 'truck' ? AppColors.baseColor : AppColors.fullWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1.0, color: AppColors.baseColor),
                          ),
                          child: Text(
                            'per Truck',
                            style: paymentType == 'truck' ? AppTextStyles.fontWhite16 : AppTextStyles.fontBlue16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                paymentType == 'truck' ? const SizedBox(height: 16) : Container(),
                paymentType == 'truck'
                    ? AppTextField(
                        textController: _truck,
                        hintText: 'Number of Trucks',
                        labelText: 'No. of Trucks',
                        autoFocus: false,
                        textInput: TextInputType.number,
                        onChangedAction: (value) => setState(() => false),
                        suffix: paymentType.isNotEmpty
                            ? Text(
                                'per $paymentType',
                                style: AppTextStyles.fontGrey16,
                              )
                            : null,
                      )
                    : Container(),
                const SizedBox(height: 16),
                AppTextField(
                  textController: _amount,
                  hintText: 'Expected Amount',
                  labelText: 'Trip Amount',
                  autoFocus: false,
                  textInput: TextInputType.number,
                  onChangedAction: (value) => setState(() => false),
                  suffix: paymentType.isNotEmpty
                      ? Text(
                          'per $paymentType',
                          style: AppTextStyles.fontGrey16,
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                _weight.text.isNotEmpty && paymentType == 'tonne' && _amount.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Text('Total Payment: ₹ ${(double.parse(_weight.text) * double.parse(_amount.text)).toStringAsFixed(0)}', style: AppTextStyles.fontBlue16),
                      )
                    : _weight.text.isNotEmpty && paymentType == 'truck' && _amount.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 26),
                            child: Text('Total Payment: ₹ ${(double.parse(_truck.text) * double.parse(_amount.text)).toStringAsFixed(0)}', style: AppTextStyles.fontBlue16),
                          )
                        : Container(),
                const SizedBox(height: 8),
                Container(
                  width: width,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    primary: false,
                    padding: EdgeInsets.zero,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            advancePayment = 'percent';
                            _payment.text = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: advancePayment == 'percent' ? AppColors.baseColor : AppColors.fullWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1.0, color: AppColors.baseColor),
                          ),
                          child: Text(
                            'Percentage',
                            style: advancePayment == 'percent' ? AppTextStyles.fontWhite16 : AppTextStyles.fontBlue16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            advancePayment = 'fixed';
                            _payment.text = '';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: advancePayment == 'fixed' ? AppColors.baseColor : AppColors.fullWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1.0, color: AppColors.baseColor),
                          ),
                          child: Text(
                            'Fixed',
                            style: advancePayment == 'fixed' ? AppTextStyles.fontWhite16 : AppTextStyles.fontBlue16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  textController: _payment,
                  hintText: 'Advance Amount',
                  labelText: 'Advance Amount Cut',
                  autoFocus: false,
                  textInput: TextInputType.number,
                  onChangedAction: (value) => setState(() => false),
                  suffix: advancePayment.isNotEmpty
                      ? Text(
                          advancePayment,
                          style: AppTextStyles.fontGrey16,
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                advancePayment == 'fixed' && _payment.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Text('Advance Amount: ₹ ${_payment.text}', style: AppTextStyles.fontBlue16),
                      )
                    : advancePayment == 'percent' && _payment.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 26),
                            child: Text(
                                paymentType == 'tonne'
                                    ? 'Advance Amount: ₹ ${(double.parse(_payment.text) * (double.parse(_weight.text) * double.parse(_amount.text) / 100)).toStringAsFixed(0)}'
                                    : 'Advance Amount: ₹ ${(double.parse(_payment.text) * (double.parse(_truck.text) * double.parse(_amount.text) / 100)).toStringAsFixed(0)}',
                                style: AppTextStyles.fontBlue16),
                          )
                        : Container(),
                const SizedBox(height: 16),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 26.0), child: Text('Address Details', style: AppTextStyles.fontBoldBlue20)),
                const SizedBox(height: 16),
                AppTextField(
                  textController: _source,
                  hintText: 'Enter Loading Address',
                  labelText: 'Complete Loading Address',
                  autoFocus: false,
                  textInput: TextInputType.text,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  textController: _dest,
                  hintText: 'Enter Unloading Address',
                  labelText: 'Complete Unloading Address',
                  autoFocus: false,
                  textInput: TextInputType.text,
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 26, right: 26, top: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
            child: Consumer<TripProvider>(
              builder: (context, trip, child) {
                return AppButtonConsumer(
                  clickAction: () => createTrip(context, trip),
                  childWidget: TripProvider.loading == false ? const Text('Submit', style: AppTextStyles.fontBoldWhite20) : const Center(child: CircularProgressIndicator(color: AppColors.fullWhite)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void createTrip(context, trip) async {
    Map<String, dynamic> data = {};
    if (paymentType == 'tonne' &&
        (_type.text.isNotEmpty &&
            _weight.text.isNotEmpty &&
            _duration.text.isNotEmpty &&
            _amount.text.isNotEmpty &&
            advancePayment.isNotEmpty &&
            _payment.text.isNotEmpty &&
            _source.text.isNotEmpty &&
            _dest.text.isNotEmpty)) {
      data = {
        'uid': AuthenticationService().getCurrentuserUID(),
        'cargoType': _type.text,
        'weight': int.parse(_weight.text),
        'expiration_date': _duration.text,
        'paymentType': paymentType,
        'totalAmount': double.parse(_weight.text) * double.parse(_amount.text),
        'advanceType': advancePayment,
        'advanceAmount': advancePayment == 'fixed' ? _payment.text : double.parse(_payment.text) * (double.parse(_weight.text) * double.parse(_amount.text) / 100),
        'loadingAddress': _source.text,
        'loadingPointDetails': widget.source,
        'unloadingAddress': _dest.text,
        'unloadingPointDetails': widget.destination,
        'status': 'NOT_ASSIGNED',
        'createdAt': DateTime.now(),
      };
      bool response = await trip.createTrip(data);
      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().shoeMessageSnackbar('Trip created successfully') as SnackBar);
        Navigator.pushNamed(context, AppRoutes.homePage);
      }
    } else if (paymentType == 'truck' &&
        (_type.text.isNotEmpty &&
            _weight.text.isNotEmpty &&
            _duration.text.isNotEmpty &&
            _amount.text.isNotEmpty &&
            _truck.text.isNotEmpty &&
            advancePayment.isNotEmpty &&
            _payment.text.isNotEmpty &&
            _source.text.isNotEmpty &&
            _dest.text.isNotEmpty)) {
      data = {
        'uid': AuthenticationService().getCurrentuserUID(),
        'cargoType': _type.text,
        'weight': int.parse(_weight.text),
        'expiration_date': _duration.text,
        'paymentType': paymentType,
        'totalAmount': double.parse(_truck.text) * double.parse(_amount.text),
        'advanceType': advancePayment,
        'advanceAmount': advancePayment == 'fixed' ? _payment.text : double.parse(_payment.text) * (double.parse(_weight.text) * double.parse(_amount.text) / 100),
        'loadingAddress': _source.text,
        'loadingPointDetails': widget.source,
        'unloadingAddress': _dest.text,
        'unloadingPointDetails': widget.destination,
        'status': 'NOT_ASSIGNED',
        'createdAt': DateTime.now(),
        'trucks': int.parse(_truck.text),
      };
      bool response = await trip.createTrip(data);
      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().shoeMessageSnackbar('Trip created successfully') as SnackBar);
        Navigator.pushNamed(context, AppRoutes.homePage);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please enter all the details.') as SnackBar);
    }
  }
}

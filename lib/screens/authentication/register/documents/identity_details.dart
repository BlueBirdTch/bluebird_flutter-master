// ignore_for_file: prefer_is_empty, unnecessary_null_comparison

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/config/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:bluebird/utils/providers/providers.dart';
import 'package:provider/provider.dart';

class IdentityDetailsForm extends StatefulWidget {
  const IdentityDetailsForm({Key? key}) : super(key: key);

  @override
  State<IdentityDetailsForm> createState() => _IdentityDetailsFormState();
}

class _IdentityDetailsFormState extends State<IdentityDetailsForm> {
  List<String> models = [];
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _dlController = TextEditingController();
  final TextEditingController _tlController = TextEditingController();
  final List<TextEditingController> _rcaControllers = [TextEditingController()];
  final List<TextEditingController> _modelController = [TextEditingController()];
  final List<TextEditingController> _bodyTypeController = [TextEditingController()];
  final List<TextEditingController> _categoryController = [TextEditingController()];
  final List<TextEditingController> _vehicleNumberController = [TextEditingController()];
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.fullWhite,
        body: _body(height, width, context),
      ),
    );
  }

  List<Widget> _vehicleCards() {
    List<Widget> cards = [];
    for (var i = 0; i < _rcaControllers.length; i++) {
      cards.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.fullWhite,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Color.fromARGB(209, 216, 216, 216), spreadRadius: 4, blurRadius: 4, offset: Offset(4, 0))],
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: Text('Vehicle ${i + 1}', style: AppTextStyles.fontBoldBlue20),
            subtitle: Text('Add details for Vehicle ${i + 1}', style: AppTextStyles.fontBlue16),
            initiallyExpanded: false,
            children: [
              AppTextField(textController: _rcaControllers[i], hintText: 'RC Number for vehicle', labelText: 'RC Number', autoFocus: false, textInput: TextInputType.text, width: 10),
              const SizedBox(height: 12),
              AppTextField(textController: _modelController[i], hintText: 'Ashok Leyland', labelText: 'Vehicle Model', autoFocus: false, textInput: TextInputType.text, width: 10),
              const SizedBox(height: 12),
              AppTextField(textController: _vehicleNumberController[i], hintText: 'TSXXXXXXXXX', labelText: 'Vehicle Number', autoFocus: false, textInput: TextInputType.text, width: 10),
              const SizedBox(height: 12),
              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('common').doc('vehicles').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<String> types = [];
                      List<dynamic> modelObjects = [];

                      for (var element in snapshot.data?.get(FieldPath(const ['bodyTypes']))) {
                        types.add(element);
                      }
                      for (var element in snapshot.data?.get(FieldPath(const ['models']))) {
                        modelObjects.add(element);
                      }
                      return Column(
                        children: [
                          AppTextField(
                            textController: _bodyTypeController[i],
                            hintText: 'Select Body Type',
                            labelText: 'Body Type',
                            autoFocus: false,
                            textInput: TextInputType.none,
                            width: 10,
                            onTapAction: () async {
                              models = [];
                              setState(() {});
                              await bodyTypeSelect(context, i, types);
                              var temp = modelObjects.where((element) => element['bodyType'] == _bodyTypeController[i].text);
                              for (var element in temp) {
                                models.add(element['description']);
                              }
                              _categoryController[i].text = '';
                              setState(() {});
                            },
                          ),
                          _bodyTypeController[i].text.isNotEmpty ? const SizedBox(height: 12) : Container(),
                          _bodyTypeController[i].text.isNotEmpty
                              ? AppTextField(
                                  textController: _categoryController[i],
                                  hintText: 'Select Sub Category',
                                  labelText: 'Sub Category',
                                  autoFocus: false,
                                  textInput: TextInputType.none,
                                  width: 10,
                                  onTapAction: () async {
                                    await modelTypeSelect(context, i, models);
                                  },
                                )
                              : Container(),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator(
                        color: AppColors.baseColor,
                      );
                    }
                  }),
              const SizedBox(height: 12),
              AppTextButton(text: 'Delete', clickAction: () => removeVehicle(i)),
            ],
          ),
        ),
      );
    }
    cards.add(Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.add_circle_rounded, size: 32, color: AppColors.baseColor),
            onPressed: () => addVehicle(),
          ),
        )));
    return cards;
  }

  Future<dynamic> bodyTypeSelect(BuildContext context, int i, List<String> types) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'Select Body Type',
                    style: AppTextStyles.fontBoldBlue24,
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 30,
                    onSelectedItemChanged: (index) {
                      if (index != 0) {
                        _bodyTypeController[i].text = types[index - 1];
                      }
                    },
                    children: List.generate(
                      types.length + 1,
                      (index) => index == 0
                          ? const Text('-', style: AppTextStyles.fontBlack14)
                          : Text(
                              types[index - 1],
                              style: AppTextStyles.fontBlack14,
                            ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 20),
                  child: AppButton(
                    clickAction: () => Navigator.pop(context),
                    text: 'CONFIRM',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> modelTypeSelect(BuildContext context, int i, List<String> models) {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 26),
                  child: Text(
                    'Select Sub-Category Type',
                    style: AppTextStyles.fontBoldBlue24,
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 30,
                    onSelectedItemChanged: (index) {
                      if (index != 0) {
                        _categoryController[i].text = models[index - 1];
                      }
                    },
                    children: List.generate(
                      models.length + 1,
                      (index) => index == 0
                          ? const Text('-', style: AppTextStyles.fontBlack14)
                          : Text(
                              models[index - 1],
                              style: AppTextStyles.fontBlack14,
                            ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 20),
                  child: AppButton(
                    clickAction: () => Navigator.pop(context),
                    text: 'CONFIRM',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void removeVehicle(int index) {
    if (_rcaControllers.length > 1) {
      _rcaControllers.removeAt(index);
      _modelController.removeAt(index);
      _bodyTypeController.removeAt(index);
      _categoryController.removeAt(index);
      _vehicleNumberController.removeAt(index);
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().shoeMessageSnackbar('Atleast 1 vehicle needs to be present.') as SnackBar);
    }
  }

  void addVehicle() {
    if (_rcaControllers.length < 5) {
      _rcaControllers.add(TextEditingController());
      _modelController.add(TextEditingController());
      _bodyTypeController.add(TextEditingController());
      _categoryController.add(TextEditingController());
      _vehicleNumberController.add(TextEditingController());
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().shoeMessageSnackbar('Only 5 vehicles can be added during registration') as SnackBar);
    }
  }

  Widget _body(height, width, context) {
    return SizedBox(
      height: height,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              primary: false,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: height * 0.14),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Identification Proof',
                    style: AppTextStyles.fontBoldBlue27,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 26),
                  child: const Text(
                    'Please provide your Identification Details as provided by the government.',
                    style: AppTextStyles.fontBlack16,
                  ),
                ),
                SizedBox(height: height * 0.029),
                AppTextField(
                  textController: _aadharController,
                  hintText: 'XXXX XXXX XXXX',
                  labelText: 'Aadhar Card number',
                  maxLength: 12,
                  autoFocus: false,
                  textInput: TextInputType.number,
                ),
                const SizedBox(height: 15),
                AppTextField(
                  textController: _panController,
                  hintText: 'XXPR1234X',
                  labelText: 'PAN Card number',
                  maxLength: 10,
                  autoFocus: false,
                  textInput: TextInputType.text,
                ),
                const SizedBox(height: 15),
                AuthenticationDataProvider().getRole() == 'driver'
                    ? AppTextField(
                        textController: _dlController,
                        hintText: 'DL1118901324567',
                        labelText: 'Driving License number',
                        maxLength: 16,
                        autoFocus: false,
                        textInput: TextInputType.text,
                      )
                    : AppTextField(
                        textController: _tlController,
                        hintText: 'XXXXXXXXXXXXXX',
                        labelText: 'GSTIN number',
                        maxLength: 15,
                        autoFocus: false,
                        textInput: TextInputType.text,
                      ),
                const SizedBox(height: 28),
                AuthenticationDataProvider().getRole() == 'driver'
                    ? Container(
                        width: width,
                        margin: const EdgeInsets.symmetric(horizontal: 26),
                        child: const Text('Vehicle Details', style: AppTextStyles.fontBlue24),
                      )
                    : Container(),
                const SizedBox(height: 15),
                AuthenticationDataProvider().getRole() == 'driver'
                    ? Theme(
                        data: ThemeData(dividerColor: Colors.transparent),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _vehicleCards(),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: MediaQuery.of(context).padding.bottom + 30),
            child: Consumer<IdentityProvider>(
              builder: (context, identity, child) {
                return AppButtonConsumer(
                  clickAction: () => clickAction(identity, context),
                  childWidget: IdentityProvider.loading == false
                      ? const Text(
                          'Next',
                          style: AppTextStyles.fontBoldWhite20,
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.fullWhite,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void clickAction(identity, context) async {
    if ((AuthenticationDataProvider().getRole() == 'driver' && _aadharController.text.isNotEmpty && _panController.text.isNotEmpty && _dlController.text.isNotEmpty) ||
        (AuthenticationDataProvider().getRole() == 'transporter' && _aadharController.text.isNotEmpty && _panController.text.isNotEmpty && _tlController.text.isNotEmpty)) {
      bool valid = true;
      List<Map<String, dynamic>> vehicleData = [];
      for (var i = 0; i < _rcaControllers.length; i++) {
        if (AuthenticationDataProvider().getRole() == 'driver' &&
            (_rcaControllers[i].text.isEmpty ||
                _modelController[i].text.isEmpty ||
                _bodyTypeController[i].text.isEmpty ||
                _categoryController[i].text.isEmpty ||
                _vehicleNumberController[i].text.isEmpty)) {
          valid = false;
          break;
        }
      }
      if (valid) {
        for (var i = 0; i < _rcaControllers.length; i++) {
          vehicleData.add({
            "vehicle_rc": _rcaControllers[i].text,
            "vehicle_name": _modelController[i].text,
            "vehicle_number": _vehicleNumberController[i].text,
            "bodyType": _bodyTypeController[i].text,
            "category": _categoryController[i].text,
          });
        }
        Map<String, dynamic> data = AuthenticationDataProvider().getRole() == 'driver'
            ? {
                "details": {
                  "aadhar": {"id": _aadharController.text, "verified": false, "comments": ''},
                  "pan": {"id": _panController.text, "verified": false, "comments": ''},
                  "driving_license": {"id": _dlController.text, "verified": false, "comments": ''},
                  "vehicleData": vehicleData,
                },
                "verificationDocuments": {
                  "selfie": [],
                  "aadhar": [],
                  "pan_card": [],
                  "driving_license": [],
                },
              }
            : {
                "details": {
                  "aadhar": {"id": _aadharController.text, "verified": false, "comments": ''},
                  "pan": {"id": _panController.text, "verified": false, "comments": ''},
                  "trade_license": {"id": _tlController.text, "verified": false, "comments": ''},
                },
                "verificationDocuments": {
                  "selfie": [],
                  "aadhar": [],
                  "pan_card": [],
                  "trade_license": [],
                },
              };
        var response = await identity.postIdentityDetails(data);
        if (response) {
          Navigator.pushNamed(context, AppRoutes.selfiePage);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please enter all the details') as SnackBar);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please enter all the details') as SnackBar);
    }
  }
}

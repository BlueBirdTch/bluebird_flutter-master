// ignore_for_file: use_build_context_synchronously

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/utils/services/authentication_services.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final TextEditingController _rcaControllers = TextEditingController();

  final TextEditingController _modelController = TextEditingController();

  final TextEditingController _bodyTypeController = TextEditingController();

  final TextEditingController _categoryController = TextEditingController();

  final TextEditingController _vehicleNumberController = TextEditingController();

  List<dynamic> selectedModel = [];

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.fullWhite,
      appBar: _appBar(context),
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                primary: true,
                children: [
                  Theme(
                    data: ThemeData(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: const Text("Add new Vehicle", style: AppTextStyles.fontBoldBlue20),
                      subtitle: const Text("Tap here to add a new vehicle", style: AppTextStyles.fontBlue14),
                      trailing: const Icon(Icons.add_circle, color: AppColors.baseColor, size: 32),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      expandedAlignment: Alignment.topLeft,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 26),
                      children: [
                        const SizedBox(height: 12),
                        AppTextField(textController: _modelController, hintText: 'Ashok Leyland', labelText: 'Vehicle Make', autoFocus: false, textInput: TextInputType.text),
                        const SizedBox(height: 12),
                        AppTextField(textController: _vehicleNumberController, hintText: 'TSXXXXXXXX', labelText: 'Vehicle Number', autoFocus: false, textInput: TextInputType.text),
                        const SizedBox(height: 12),
                        AppTextField(textController: _rcaControllers, hintText: 'Enter your RC number', labelText: 'RCA', autoFocus: false, textInput: TextInputType.text),
                        const SizedBox(height: 12),
                        AppTextField(
                          textController: _bodyTypeController,
                          hintText: 'Select Body Type',
                          labelText: 'Body Type',
                          autoFocus: false,
                          textInput: TextInputType.none,
                          onTapAction: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Container(
                                    width: width,
                                    height: height * 0.45,
                                    padding: const EdgeInsets.symmetric(horizontal: 26),
                                    decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(30)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 26),
                                        const Text("Select Vehicle Body Type", textAlign: TextAlign.center, style: AppTextStyles.fontBoldBlue20),
                                        const SizedBox(height: 13),
                                        FutureBuilder<DocumentSnapshot>(
                                          future: FirebaseFirestore.instance.collection('common').doc('vehicles').get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Expanded(
                                                child: Center(child: CircularProgressIndicator(color: AppColors.baseColor)),
                                              );
                                            } else if (snapshot.connectionState == ConnectionState.done && snapshot.data!.exists) {
                                              return Expanded(
                                                child: CupertinoPicker(
                                                  itemExtent: 33,
                                                  onSelectedItemChanged: (ind) {
                                                    selectedModel.clear();
                                                    List<dynamic> models = snapshot.data!['models'];
                                                    _bodyTypeController.text = ind == 0 ? '' : snapshot.data!['bodyTypes'][ind - 1];
                                                    for (var model in models) {
                                                      if (model['bodyType'] == _bodyTypeController.text) {
                                                        selectedModel.add(model);
                                                      }
                                                    }
                                                  },
                                                  children: List.generate(
                                                    snapshot.data!['bodyTypes'].length + 1,
                                                    (index) => index == 0
                                                        ? const Text('-', style: AppTextStyles.fontBlack14)
                                                        : Text(
                                                            snapshot.data!['bodyTypes'][index - 1],
                                                            style: AppTextStyles.fontBlack14,
                                                          ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return const Expanded(
                                                child: Center(child: CircularProgressIndicator(color: AppColors.baseColor)),
                                              );
                                            }
                                          },
                                        ),
                                        AppButton(
                                            text: 'Confirm',
                                            clickAction: () {
                                              setState(() {});
                                              Navigator.pop(context);
                                            }),
                                        SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          textController: _categoryController,
                          hintText: 'Select Category',
                          labelText: 'Category',
                          autoFocus: false,
                          textInput: TextInputType.none,
                          onTapAction: () async {
                            if (_bodyTypeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(AppSnackbars().showerrorSnackbar('Please select a Body Type first') as SnackBar);
                            } else {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Container(
                                      width: width,
                                      height: height * 0.45,
                                      decoration: BoxDecoration(color: AppColors.fullWhite, borderRadius: BorderRadius.circular(30)),
                                      padding: const EdgeInsets.symmetric(horizontal: 26),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 26),
                                          const Text("Select Vehicle Category and Weight", textAlign: TextAlign.center, style: AppTextStyles.fontBoldBlue20),
                                          const SizedBox(height: 13),
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 33,
                                              onSelectedItemChanged: (ind) {
                                                _categoryController.text = ind == 0 ? '' : selectedModel[ind - 1]['description'];
                                              },
                                              children: List.generate(
                                                selectedModel.length + 1,
                                                (index) =>
                                                    index == 0 ? const Text('-', style: AppTextStyles.fontBlack14) : Text(selectedModel[index - 1]['description'], style: AppTextStyles.fontBlack14),
                                              ),
                                            ),
                                          ),
                                          AppButton(
                                              text: 'Confirm',
                                              clickAction: () {
                                                setState(() {});
                                                Navigator.pop(context);
                                              }),
                                          SizedBox(height: MediaQuery.of(context).padding.bottom + 30),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: AppButton(
                            text: 'Add Vehicle',
                            clickAction: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: AppColors.baseColor)));
                                  });
                              await FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('vehicles').add({
                                "bodyType": _bodyTypeController.text,
                                "category": _categoryController.text,
                                "vehicle_name": _modelController.text,
                                "vehicle_number": _vehicleNumberController.text,
                                "vehicle_rc": _rcaControllers.text,
                              });
                              Navigator.pop(context);
                              Get.showSnackbar(const GetSnackBar(title: "Success", message: "Vehicle Added Successfully", duration: Duration(seconds: 3), backgroundColor: AppColors.statusOK));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26),
                    child: Text('Your Vehicles', style: AppTextStyles.fontBoldBlack20),
                  ),
                  const SizedBox(height: 13),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(AuthenticationService().getCurrentuserUID()).collection('vehicles').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 26),
                            child: const CircularProgressIndicator(color: AppColors.baseColor),
                          ),
                        );
                      } else if (snapshot.connectionState == ConnectionState.active && snapshot.data?.size != 0) {
                        return Column(
                          children: List.generate(
                            snapshot.data!.size,
                            (index) => Theme(
                              data: ThemeData(dividerColor: Colors.transparent),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 26),
                                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.colorGrey, width: 0.8))),
                                child: ExpansionTile(
                                  title: Text('${snapshot.data!.docs[index]['vehicle_name']}', style: AppTextStyles.fontBlue16.copyWith(fontSize: 18)),
                                  subtitle: Text('${snapshot.data!.docs[index]['vehicle_number']}', style: AppTextStyles.fontBoldBlack14),
                                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                  expandedAlignment: Alignment.topLeft,
                                  childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                                  children: [
                                    Text('Name: ${snapshot.data!.docs[index]['vehicle_name']}', style: AppTextStyles.fontBlue14),
                                    Text('Vehicle N/o: ${snapshot.data!.docs[index]['vehicle_number']}', style: AppTextStyles.fontBlue14),
                                    Text('RCA N/o: ${snapshot.data!.docs[index]['vehicle_rc']}', style: AppTextStyles.fontBlue14),
                                    Text('Body Type: ${snapshot.data!.docs[index]['bodyType']}', style: AppTextStyles.fontBlue14),
                                    Text('Category: ${snapshot.data!.docs[index]['category']}', style: AppTextStyles.fontBlue14),
                                    SizedBox(
                                      width: width,
                                      child: Center(
                                        child: TextButton(
                                          onPressed: () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: AppColors.baseColor)));
                                                });
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(AuthenticationService().getCurrentuserUID())
                                                .collection('vehicles')
                                                .doc(snapshot.data!.docs[index].id)
                                                .delete();
                                            Navigator.pop(context);
                                            Get.showSnackbar(
                                                const GetSnackBar(title: "Success", message: "Vehicle Deleted Successfully", duration: Duration(seconds: 3), backgroundColor: AppColors.errorRed));
                                          },
                                          child: Text('Delete Vehicle', style: AppTextStyles.fontBoldBlue16.copyWith(color: AppColors.errorRed)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.connectionState == ConnectionState.active && snapshot.data?.size == 0) {
                        return const Center(child: Text('Looks like you do not have any saved addresses', style: AppTextStyles.fontBlack14));
                      } else {
                        return const Center(child: Text('An unknown error has occurred', style: AppTextStyles.fontBlack14));
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.fullWhite,
      elevation: 0,
      title: const Text('Your Vehicles', style: AppTextStyles.fontBoldBlue20),
      centerTitle: true,
      actions: [
        TextButton(
          child: const Text('Back', style: AppTextStyles.fontBlack16),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
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
                        _bodyTypeController.text = types[index - 1];
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
                        _categoryController.text = models[index - 1];
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
}

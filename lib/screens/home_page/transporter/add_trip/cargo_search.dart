import 'dart:async';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/utils/providers/trip_provider.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CargoSearch extends StatefulWidget {
  const CargoSearch({Key? key, required this.isMaterial}) : super(key: key);
  final bool isMaterial;
  @override
  State<CargoSearch> createState() => _CargoSearchState();
}

class _CargoSearchState extends State<CargoSearch> {
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _debounce;
  String? searched = '';
  TripProvider? trip;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    trip = Provider.of<TripProvider>(context, listen: false);
    return Container(
      width: width,
      height: height,
      color: AppColors.fullWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 40),
          Container(
            margin: const EdgeInsets.only(left: 26),
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.fullBlack,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: width,
            child: AppTextSearchField(
              textController: _textEditingController,
              hintText: widget.isMaterial ? 'Search for cargo type' : "Search for Goods Weight",
              labelText: null,
              autoFocus: true,
              textInput: TextInputType.text,
              onChangedAction: (text) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(seconds: 1), () async {
                  setState(() {
                    searched = text;
                  });
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('common').doc('loads').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> items = snapshot.data?.get(widget.isMaterial ? 'subcategories' : 'categories');
                  items.retainWhere((element) => element.toString().toLowerCase().contains(searched!.toLowerCase()));
                  return Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      primary: true,
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: List.generate(
                        items.length,
                        (index) => cargoCard(
                          width,
                          items[index],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.baseColor,
                      ),
                    ),
                  );
                }
              })
        ],
      ),
    );
  }

  Widget cargoCard(double width, String name) {
    return GestureDetector(
      onTap: () {
        widget.isMaterial ? trip!.cargo = name : trip!.type = name;
        Navigator.pop(context);
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.moonGrey, width: 1.0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          name,
          style: AppTextStyles.fontBlack14,
        ),
      ),
    );
  }
}

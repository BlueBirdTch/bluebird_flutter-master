// ignore_for_file: prefer_is_empty

import 'dart:async';

import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/utils/providers/location_service_provider.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';

class LocationSearch extends StatefulWidget {
  const LocationSearch({
    Key? key,
    required this.destination,
    required this.soure,
    required this.hintText,
  }) : super(key: key);
  final bool destination;
  final bool soure;
  final String hintText;

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  static const googleMapsAPIKey = 'AIzaSyCpC9tVsMDJOk4tRR1Q4774Vw87hDKDgnA';
  final TextEditingController _textEditingController = TextEditingController();
  TextSearchResponse? results;
  var googlePlaces = GooglePlace(googleMapsAPIKey);
  bool searched = false;
  LocationProvider? location;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    location = Provider.of<LocationProvider>(context, listen: false);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
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
              hintText: widget.hintText,
              labelText: null,
              autoFocus: true,
              textInput: TextInputType.text,
              onChangedAction: (text) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(seconds: 1), () async {
                  setState(() {
                    searched = false;
                  });
                  results = await googlePlaces.search.getTextSearch(text);
                  setState(() {
                    searched = true;
                  });
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          searched
              ? Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    primary: true,
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: results?.results!.length != 0 || results?.results != null
                        ? List.generate(
                            results!.results!.length,
                            (index) => returnAddressCard(
                                width,
                                results!.results![index].name as String,
                                results!.results![index].placeId as String,
                                LatLng(results!.results![index].geometry!.location!.lat as double, results!.results![index].geometry!.location!.lng as double),
                                results!.results![index].formattedAddress as String),
                          )
                        : [],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget returnAddressCard(double width, String name, String id, LatLng coordinates, String address) {
    return GestureDetector(
      onTap: () {
        if (widget.soure) {
          location!.setSourceLocation(id, name, address, coordinates);
          Navigator.pop(context);
        } else if (widget.destination) {
          location!.setDestinationLocation(id, name, address, coordinates);
          Navigator.pop(context);
        }
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.moonGrey, width: 1.0),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.fmd_good_rounded,
              color: AppColors.colorGrey,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                '$name, $address',
                style: AppTextStyles.fontBlack14,
              ),
            )
          ],
        ),
      ),
    );
  }
}

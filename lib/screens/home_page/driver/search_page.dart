import 'package:bluebird/config/res/app_colors.dart';
import 'package:bluebird/config/res/app_themes.dart';
import 'package:bluebird/screens/trips/trip_details.dart';
import 'package:bluebird/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchText = '';
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 24),
            AppTextSearchField(
              textController: _searchController,
              hintText: 'Trip Amount, cargo, location',
              labelText: 'Search for trips',
              autoFocus: true,
              textInput: TextInputType.text,
              onChangedAction: (value) {
                setState(() => searchText = value);
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('trips').where('status', whereIn: ['NOT_ASSIGNED', 'CANCEL_TRIP_START']).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data?.size != 0) {
                    List<DocumentSnapshot> filteredData = [];
                    if (searchText.isEmpty) {
                      for (var index = 0; index < snapshot.data!.size; index++) {
                        filteredData.add(snapshot.data!.docs[index]);
                      }
                    } else {
                      for (var index = 0; index < snapshot.data!.size; index++) {
                        if (snapshot.data!.docs[index]['loadingPointDetails']['name'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['loadingPointDetails']['address'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['unloadingPointDetails']['name'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['unloadingPointDetails']['address'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['unloadingAddress'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['loadingAddress'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['cargoType'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['weight'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                            snapshot.data!.docs[index]['totalAmount'].toString().toLowerCase().contains(searchText.toLowerCase())) {
                          filteredData.add(snapshot.data!.docs[index]);
                        }
                      }
                    }
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      physics: const BouncingScrollPhysics(),
                      primary: true,
                      shrinkWrap: true,
                      children: List.generate(
                        filteredData.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TripDetails(document: filteredData[index], transporter: false)),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.baseColor, width: 1.0)),
                            title: Text(
                              '${filteredData[index]['loadingPointDetails']['name']}--->${filteredData[index]['unloadingPointDetails']['name']}',
                              style: AppTextStyles.fontBoldBlue14,
                            ),
                            trailing: const Icon(Icons.info_outline, color: AppColors.moonGrey, size: 28),
                            subtitle: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${filteredData[index]['cargoType']} - ${filteredData[index]['weight']} tonnes\n',
                                    style: AppTextStyles.fontBlack14,
                                  ),
                                  TextSpan(
                                    text: 'Payment - per ${filteredData[index]['paymentType']}\n',
                                    style: AppTextStyles.fontBlack14,
                                  ),
                                  TextSpan(
                                    text: 'Total Payment - ₹ ${filteredData[index]['totalAmount'].toStringAsFixed(0)}',
                                    style: AppTextStyles.fontBoldBlue16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.baseColor));
                  } else {
                    return Center(
                      child: Lottie.asset('assets/images/search.json', width: 150),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

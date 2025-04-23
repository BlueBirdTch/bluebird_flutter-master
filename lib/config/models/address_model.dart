//Create a class which is a response model with fromJson factory constructor method and a toJson method with return type as Map<String, dynamic>, the fields of the class are: primary, address_id, address_line, landmar, city_state, pincode.

class AddressModel {
  final String primary;
  final String addressId;
  final String addressLine;
  final String landmark;
  final String cityState;
  final String pincode;

  AddressModel({
    required this.primary,
    required this.addressId,
    required this.addressLine,
    required this.landmark,
    required this.cityState,
    required this.pincode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      primary: json['primary'],
      addressId: json['address_id'],
      addressLine: json['address_line'],
      landmark: json['landmark'],
      cityState: json['city_state'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'address_id': addressId,
      'address_line': addressLine,
      'landmark': landmark,
      'city_state': cityState,
      'pincode': pincode,
    };
  }
}

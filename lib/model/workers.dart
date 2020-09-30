/// A class to hold my [Workers] model
class Workers {

  /// Setting constructor for [Workers] class
  Workers({
    this.id,
    this.name,
    this.phoneNumber,
    this.type,
  });

  /// A string variable to hold my id
  String id;

  /// A string variable to hold my name
  String name;

  /// A string variable to hold my phone number
  String phoneNumber;

  /// A string variable to hold my user type
  String type;

  /// Creating a method to map my JSON values to the model details accordingly
  factory Workers.fromJson(Map<String, dynamic> json) {
    return Workers(
      id: json["_id"].toString(),
      name: json["name"].toString(),
      phoneNumber: json["phone"].toString(),
      type: json["type"].toString(),
    );
  }

}
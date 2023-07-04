import 'package:showmaker/database/entity.dart';

class User1 implements Entity<User1> {
  String? _id;
  String firebaseId;
  String name;
  String pfpUrl;

  User1(this.firebaseId, this.name, this.pfpUrl, [this._id]);

  static User1 fromDatabase(Map<String, dynamic> data) {
    return User1(data['firebaseId'], data['name'], data['pfpUrl']);
  }

  @override
  Map<String, dynamic> toDatabase() {
    return {'firebaseId': firebaseId, 'name': name, 'pfpUrl': pfpUrl};
  }

  @override
  void setId(String id) {
    _id = id;
  }

  @override
  String? getId() => _id;
}

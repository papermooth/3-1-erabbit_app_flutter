/// 用户模型
class UserModel {
  /// 用户id
  final String? id;

  /// 昵称
  final String? nickname;

  /// token
  final String? token;

  /// 账号
  final String? account;

  /// 头像
  final String? avatar;

  /// 性别
  final String? gender;

  /// 生日
  final String? birthday;

  /// 所在城市
  final String? fullLocation;

  /// 职业
  final String? profession;

  UserModel({
    this.id,
    this.nickname,
    this.token,
    this.account,
    this.avatar,
    this.gender,
    this.birthday,
    this.fullLocation,
    this.profession,
  });

  factory UserModel.fromjson(Map json) {
    return UserModel(
      id: json['id'],
      nickname: json['nickname'],
      token: json['token'],
      account: json['account'],
      avatar: json['avatar'],
      gender: json['gender'],
      birthday: json['birthday'],
      fullLocation: json['fullLocation'],
      profession: json['profession'],
    );
  }
}

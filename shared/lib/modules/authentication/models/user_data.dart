class UserData {
  String id;
  String Employee;
  String EmpCode;
  String EmpRole;
  String profilePic;



  UserData({this.id, this.Employee,this.EmpCode,this.EmpRole,this.profilePic});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['pkEmpId'];
    Employee = json['Employee'];
    EmpCode=json['EmpCode'];
    EmpRole=json['EmpRole'];
    profilePic=json['profilePic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkEmpId'] = this.id;
    data['Employee'] = this.Employee;
    data['EmpCode'] = this.EmpCode;

    data['EmpRole'] = this.EmpRole;

    data['profilePic'] = this.profilePic;


    return data;
  }
}
class Token {
  String attendance;




  Token({this.attendance});

  Token.fromJson(Map<String, dynamic> json) {

    attendance=json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['success'] = this.attendance;


    return data;
  }
}

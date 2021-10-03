class Token2 {
  String token2;



  Token2({this.token2});

  Token2.fromJson(Map<String, dynamic> json) {
    token2 = json['success'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.token2;



    return data;
  }
}

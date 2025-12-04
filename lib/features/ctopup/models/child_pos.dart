class ChildPos {
  final int slNo;
  final String childCtop; // ctopupno
  final String parentCtop;
  final String posName;
  final String dealerType;
  final String dealerId;
  final String cscCode;
  final String cityName;
  final String circle;
  final String ssa;
  final String dealerAddress;
  final String cirCode;
  final String ssaCode;
  final String createdAt;

  ChildPos({
    required this.slNo,
    required this.childCtop,
    required this.parentCtop,
    required this.posName,
    required this.dealerType,
    required this.dealerId,
    required this.cscCode,
    required this.cityName,
    required this.circle,
    required this.ssa,
    required this.dealerAddress,
    required this.cirCode,
    required this.ssaCode,
    required this.createdAt,
  });

  factory ChildPos.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => int.tryParse(v.toString()) ?? 0;
    String parseString(dynamic v) => v?.toString() ?? '';

    return ChildPos(
      slNo: parseInt(json['sl_no']),
      childCtop: parseString(json['ctopupno']),
      parentCtop: parseString(json['parent_ctop']),
      posName: parseString(json['pos_name']),
      dealerType: parseString(json['dealer_type']),
      dealerId: parseString(json['dealer_id']),
      cscCode: parseString(json['csc_code']),
      cityName: parseString(json['city_name']),
      circle: parseString(json['circle']),
      ssa: parseString(json['ssa']),
      dealerAddress: parseString(json['dealer_address']),
      cirCode: parseString(json['cir_code']),
      ssaCode: parseString(json['ssa_code']),
      createdAt: parseString(json['created_at']),
    );
  }
}

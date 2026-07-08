class PartnerCustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? joinDate;

  const PartnerCustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.joinDate,
  });

  factory PartnerCustomerModel.fromJson(Map<String, dynamic> json) {
    return PartnerCustomerModel(
      id: (json['customerId'] ?? json['CustomerId'] ?? json['id'] ?? json['Id'] ?? json['userId'] ?? json['UserId'] ?? '').toString(),
      name: (json['name'] ?? json['Name'] ?? json['fullName'] ?? json['FullName'] ?? 'Hội viên').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      phone: (json['phone'] ?? json['Phone'] ?? json['phoneNumber'] ?? json['PhoneNumber'] ?? 'N/A').toString(),
      joinDate: DateTime.tryParse((json['joinDate'] ?? json['JoinDate'] ?? json['createdAt'] ?? json['CreatedAt'] ?? '').toString()),
    );
  }
}

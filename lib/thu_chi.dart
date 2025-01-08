class ThuChi {
  final String date;
  final double amount;
  final String type;
  final String description;
  final String category;
  final String note;

  ThuChi({
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    required this.category,
    required this.note,
  });

  // Chuyển đổi đối tượng ThuChi thành Map để lưu vào cơ sở dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'amount': amount,
      'type': type,
      'description': description,
      'category': category,
    };
  }

  // Chuyển đổi Map thành đối tượng ThuChi
  factory ThuChi.fromMap(Map<String, dynamic> map) {
    return ThuChi(
      date: map['date'],
      amount: map['amount'],
      type: map['type'],
      description: map['description'],
      category: map['category'],
      note:'',
    );
  }
}
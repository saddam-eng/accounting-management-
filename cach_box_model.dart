class CaschBox {
  final String id;

  final String name;

  final Map<String, dynamic> report;
  final Map<String, dynamic> receipts;

  final Map<String, dynamic> bills;

  CaschBox({
    required this.report,
    required this.bills,
    required this.id,
    required this.name,
    required this.receipts,
  });

  factory CaschBox.fromMap(Map<String, dynamic> map) {
    return CaschBox(
      bills: map['bills']??{},
      id: map['id'],
      name: map['name'],
      receipts: map['receipts']??{},
      report: map['report']??{},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'receipts': receipts,
      'bills': bills,
      'report': report,
    };
  }
}

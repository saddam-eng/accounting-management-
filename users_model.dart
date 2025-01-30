

double getOnHimTotal(
    Map<String, dynamic> saleInvoices,
    Map<String, dynamic> buyReturns
    ,Map<String, dynamic> bills) {
  double total = 0.0;

  for (String key in bills.keys) {
    Map<String, dynamic> bill = bills[key];

    if (bill.containsKey('amount') && bill['amount'] is num&&bill['status']=='مرحل') {
      total += bill['amount']?? 0.0;
    }
  }
  for (String key in saleInvoices.keys) {
    Map<String, dynamic> saleInvoice = saleInvoices[key];

    if (saleInvoice.containsKey('amount') && saleInvoice['amount'] is num&& saleInvoice['paymentType']=='اجل'&&saleInvoice['status']=='مرحل') {
      total += saleInvoice['amount']?? 0.0;
    }
  }
  for (String key in buyReturns.keys) {
    Map<String, dynamic> buyReturn = buyReturns[key];

    if (buyReturn.containsKey('amount') && buyReturn['amount'] is num&&buyReturn['paymentType']=='اجل'&&buyReturn['status']=='مرحل') {
      total += buyReturn['amount']?? 0.0;
    }
  }

  return total;
}
double getForHimTotal(
    Map<String, dynamic> receipts,
    Map<String, dynamic> buyInvoices,
    Map<String, dynamic> saleReturns) {
  double total = 0.0;
  for (String key in saleReturns.keys) {
    Map<String, dynamic> saleReturn = saleReturns[key];

    if (saleReturn.containsKey('amount') && saleReturn['amount'] is num&&saleReturn['paymentType']=='اجل'&&saleReturn['status']=='مرحل') {
      total += saleReturn['amount']?? 0.0;
    }
  }
  for (String key in receipts.keys) {
    Map<String, dynamic> receipt = receipts[key];

    if (receipt.containsKey('amount') && receipt['amount'] is num&&receipt['status']=='مرحل') {
      total += receipt['amount']?? 0.0;
    }
  }
  for (String key in buyInvoices.keys) {
    Map<String, dynamic> buyInvoice = buyInvoices[key];

    if (buyInvoice.containsKey('amount') && buyInvoice['amount'] is num&&buyInvoice['paymentType']=='اجل'&&buyInvoice['status']=='مرحل') {
      total += buyInvoice['amount']?? 0.0;
    }
  }

  return total;
}

class User {
  final String id;

  final String name;
  final String address;
  final String phone;
  final String email;
  final String password;
  final String status;
  final String type;
  final double balance;
  final Map<String, dynamic> saleInvoices;
  final Map<String, dynamic> buyInvoices;
  final Map<String, dynamic> report;
  final Map<String, dynamic>  receipts;
  final Map<String, dynamic>  saleReturns;
  final Map<String, dynamic>  buyReturns;
  final Map<String, dynamic>  bills;
  final double onHim;
  final double forHim;

  User( {required this.report,required this.bills,required this.saleReturns,
    required this.id,
    required this.buyReturns,

    required this.type,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.password,
    required this.status,
    required this.balance,
    required this.saleInvoices,
    required this.buyInvoices,
    required this.receipts,
    required this.onHim,
    required this.forHim,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      saleReturns:map['saleReturns'],
      buyReturns:map['buyReturns'],
      bills: map['bills'],

      type: map['type'],
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      password: map['password'],
      status: map['status'],
      balance:  0.0,
      saleInvoices: map['saleInvoices'],
      receipts: map['receipts'],
      onHim: getOnHimTotal(map['saleInvoices'],map['buyReturns'],map['bills']),
      forHim: getForHimTotal(map['receipts'],map['buyInvoices'],map['saleReturns']),
      report: map['report'], buyInvoices: map['buyInvoices'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'type': type,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'password': password,
      'status': status,
      'balance': balance,
      'saleInvoices': saleInvoices,
      'buyInvoices': buyInvoices,
      'receipts': receipts,
      'saleReturns': saleReturns,
      'buyReturns': buyReturns,
      'bills': bills,
      'report': report,
      'onHim': onHim,
      'forHim': forHim,
    };
  }
}

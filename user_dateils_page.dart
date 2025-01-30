
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../consts/string.dart';
import '../models/users_model.dart';
import 'customer_receipts_view.dart';
import 'invoices_page.dart';

class UserDaitelsPage extends StatefulWidget {
  final User  customer;
  final int saleInvTotalNum;

  final int buyInvTotalNum;
  final int receiptTotalNum;
  final int billTotalNum;
  final int buyReturnsTotalNum;
  final int saleReturnsTotalNum;

  const UserDaitelsPage({super.key,required this.customer, required this.saleInvTotalNum, required this.buyInvTotalNum, required this.receiptTotalNum, required this.billTotalNum, required this.buyReturnsTotalNum, required this.saleReturnsTotalNum});


  @override
  _UserDaitelsPageState createState() => _UserDaitelsPageState();
}


class _UserDaitelsPageState extends State<UserDaitelsPage> {
  late List<Widget> tapList=[];
  late List<Widget> tapViewList=[];
  void v(){
    widget.customer.type=='1'? tapList=[Text(buyerInvoices),    Text(bills),   Text(buyerInvoicesReturn),]:
     tapList= [Text(salesInvoices),

    Text(receipts),

    Text(salesInvoicesReturn),];

  }
  void vi(){
    widget.customer.type=='1'? tapViewList=[
      InvoicesPage(customer: widget.customer,tableName: 'buyInvoices',invNum:  widget.buyInvTotalNum),
      CustomerReceiptsPage(customer: widget.customer,receiptType: widget.customer.bills,tableName: 'bills',receiptNum: widget.billTotalNum),
      InvoicesPage(customer: widget.customer,tableName: 'buyReturns',invNum:  widget.buyReturnsTotalNum),


    ]:
     tapViewList= [
      InvoicesPage(customer: widget.customer,tableName: 'saleInvoices',invNum:  widget.saleInvTotalNum,),
      CustomerReceiptsPage(customer: widget.customer,receiptType: widget.customer.receipts,tableName: 'receipts',receiptNum: widget.receiptTotalNum,),
      InvoicesPage(customer: widget.customer,tableName: 'saleReturns',invNum:  widget.saleReturnsTotalNum),



    ];

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    v();
    vi();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            bottom:  PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: tapList
                    )
                  ],
                )),
            leading:   IconButton(onPressed: (){
              setState(() {

              });
            }, icon: const Icon(Icons.search)),
            centerTitle: true,
            title:  Text(widget.customer.name),
          ),

          body: TabBarView(children: tapViewList,) ,

        ),
      ),
    );
  }
}
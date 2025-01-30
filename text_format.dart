
import 'package:intl/intl.dart'as t;
class FormatText{

  dateFormat(date){
    return t.DateFormat('yyyy-MM-dd').format(date);
  }
  currency(num){
    return t.NumberFormat.currency(symbol: " ",decimalDigits: 0).format(num);
  }
}
import 'package:flutter/material.dart';

class CompanyIdProvider with ChangeNotifier {
  int? _companyId;

  int? get companyId => _companyId;

  set companyId(int? newCompanyId) {
    _companyId = newCompanyId;
    debugPrint('CompanyIdProvider - companyId set to: $_companyId'); // Agregar un print
    notifyListeners(); // Notificar a los listeners cuando el companyId cambia
  }
}

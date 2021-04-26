import 'package:sohbetapp/screens/contacts/contacts_page.dart';
import 'package:sohbetapp/viewmodels/base_model.dart';

class MainModel extends BaseModel {
  Future<void> navigateToContacts() {
    return navigatorService.navigateTo(ContactsPage());
  }
}

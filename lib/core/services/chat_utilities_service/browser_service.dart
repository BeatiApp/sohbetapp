import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserService {
  void bindUrl(WebViewController controller, String conversationID) {
    var ref = FirebaseFirestore.instance.collection("conversations");
    ref.doc(conversationID).snapshots().listen((event) async {
      if (event.data()['browserState'] == true) {
        String url = event.data()['browserURL'];

        print('FROM BIND URL: $url');

        // load only if the URLs are different
        String currentUrl = await controller.currentUrl();
        if (currentUrl != url) controller.loadUrl(url);
      }
    });
  }

  Future setBrowserUrl(String url, String convID) async {
    FirebaseFirestore.instance
        .doc("conversations/$convID")
        .update({"browserURL": url});
  }
}

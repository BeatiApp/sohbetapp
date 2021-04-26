class Validator {
  String validateName(String value) {
    String pattern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "İsim alanı gereklidir.";
    } else if (!regExp.hasMatch(value)) {
      return "İsim şu karakterleri içerebilir: a-z and A-Z";
    }
    return null;
  }

  String validateMobile(String value) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Telefon Numarası Gereklidir";
    } else if (value.length != 10) {
      return "Telefon numarası 10 karakter uzunluğunda olmalıdır";
    } else if (!regExp.hasMatch(value)) {
      return "Geçersiz Telefon Numarası";
    }
    return null;
  }

  String validatePasswordLength(String value) {
    if (value.length == 0) {
      return "Şifre bölümünü boş bırakmayınız";
    } else if (value.length < 6) {
      return "Şifre 6 karakter veya daha fazla olmalıdır.";
    }
    return null;
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Mail Aresi Gereklidir";
    } else if (!regExp.hasMatch(value)) {
      return "Geçersiz mail adresi";
    } else {
      return null;
    }
  }
}

class Validate {
  ///Password Validation
  static String? password(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Please Provide A Password";
    } else if (val.length < 6) {
      return "Password Must Be At Least 6 Characters";
    }
    else if (!_containsUpperCase(val)) {
      return "Password Must Contain One Uppercase Letter";
    } else if (!_containsNumber(val)) {
      return "Password Must Contain One Number";
    } else if (!_containsSpecialCharacter(val)) {
      return "Password Must Contain One Special Character";
    }
    return null;
  }

  static String? loginPassword(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Please Provide A Password";
    } else if (val.length < 6) {
      return "Password Must Be At Least 6 Characters";
    }
    return null;
  }

  static bool _containsUpperCase(String val) {
    return val.contains(RegExp(r'[A-Z]'));
  }

  static bool _containsNumber(String val) {
    return val.contains(RegExp(r'[0-9]'));
  }

  static bool _containsSpecialCharacter(String val) {
    return val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  ///Confirm Password Validation
  static String? confirmPassword(val, String? pass) {
    if (val!.trim().isEmpty) {
      return "Please Provide A Password";
    } else if (val != pass) {
      return "Password Does Not Match";
    }
    return null;
  }

  ///Email Validation
  static String? email(val) {
    bool emailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(val);
    if (val.isEmpty) {
      return "Please Provide Email";
    } else if (!emailValid) {
      return "Invalid Email";
    }
    return null;
  }

  ///Name validation
  static String? name(String? val) {
    if (val!.isEmpty) {
      return 'Please Add A Name';
    }
    return null;
  }

  static String? empty(String? val) {
    if (val!.isEmpty) {
      return "Field is Required";
    }
    if(val!.isNotEmpty){
      if(val == '.' || val.length < 2 ){
        return "Please Enter Valid Data";
      }
    }
    return null;
  }

  static String? phone(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Phone Number Required";
    }
    if (RegExp(r'[^0-9\-x]').hasMatch(val)) {
      return "Invalid Phone Number";
    }
    final digits = val.replaceAll(RegExp(r'[-x]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return "Invalid Phone Number";
    }
    return null;
  }

  ///Description Validation
  static String? descriptions(v) {
    if (v!.isEmpty) {
      return 'Please Enter a Description';
    }
    return null;
  }

  ///This may be title, subject, heading
  ///must be at least 50 Alphabets
  static String? subject(String? v) {
    if (v!.isEmpty) {
      return 'Please Enter a Description';
    }
    if (v.length < 50) {
      return 'Please Enter at Least 50 Alphabets';
    }
    return null;
  }

  static String? rangeDescriptions(v) {
    if (v!.isEmpty) {
      return 'Please Enter a Description';
    } else if (v.toString().length < 500 || v.toString().length > 1500) {
      return 'Descriptions Must Be Between 500 and 1500 Characters';
    }
    return null;
  }

  static String? priceTo(String min, String max) {
    if (max.isEmpty) {
      return 'Please Enter a Maximum Price';
    } else if (double.parse(min == "" ? "0" : min) > double.parse(max)) {
      return 'This Value Must Be Max';
    }
    if (double.parse(min == "" ? "0" : min) == double.parse(max)) {
      return "Both Values Cannot Be The Same";
    }
    return null;
  }

  static String? priceFrom(String min, String max) {
    if (min.isEmpty) {
      return 'Please Enter a Minimum Price';
    } else if (double.parse(min) > double.parse(max == "" ? "0" : max)) {
      return 'This Value Must Be Less';
    }
    if (double.parse(min) == double.parse(max == "" ? "0" : max)) {
      return "Both Values Cannot Be The Same";
    }
    return null;
  }

  ///Kilometer (KMs) Driven
  static String? kmDriven(String? v) {
    if (v!.isEmpty) {
      return 'Please Enter KMs Driven';
    }
    return null;
  }

  ///Total Number of Seats in a Vehicle
  static String? noOfSeats(String? v) {
    if (v!.isEmpty) {
      return 'Please Enter the Number of Seats';
    }
    return null;
  }

  ///Total Mileage
  static String? mileAge(String? v) {
    if (v!.isEmpty) {
      return 'Please Enter Mileage';
    }
    return null;
  }

  ///Engine Type / CC
  static String? engineType(String? v) {
    if (v!.isEmpty) {
      return 'Please Enter Engine Type/CC';
    }
    return null;
  }

  ///Company / Manufacturer Name
  static String? companyName(String? v) {
    if (v!.isEmpty) {
      return 'Please Enter Company/Manufacturer Name';
    }
    return null;
  }

  ///Area
  static String? area(String? v) {
    if (v!.isEmpty) {
      return 'Please Enter Area';
    }
    return null;
  }

  ///DOB
  static String? dob(String? v) {
    return null;
  }

  ///Category
  static String? categorySelection(String? v) {
    if (v!.isEmpty) {
      return 'Please Select a Category';
    }
    return null;
  }

  ///Domain URL
  static String? url(String? v) {
    RegExp regExp = RegExp(r"^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (v!.isEmpty) {
      return 'Please Enter a Domain';
    }

    if (!regExp.hasMatch(v)) {
      return 'Invalid Domain Format';
    }

    return null;
  }

  static String? emptyCheck(String? val, String? messageToShow) {
    if (val == null || val!.isEmpty) {
      return messageToShow ?? "Field is Required";
    }
  }
}

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Name is required";
  }
  if (value.length < 3) {
    return "Name must be at least 3 characters";
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Email is required";
  }
  Pattern pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern.toString());
  if (!regex.hasMatch(value)) {
    return "Enter a valid email";
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Phone number is required";
  }

  Pattern pattern = r'^03\d{9}$';
  RegExp regex = RegExp(pattern.toString());

  if (!regex.hasMatch(value)) {
    return "Enter a valid Pakistani phone number (e.g., 03001234567)";
  }

  return null;
}

String? validateAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Address is required";
  }
  if (value.length < 20) {
    return "Address must be at least 20 characters";
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Password is required";
  }

  Pattern pattern = r'^[A-Za-z0-9]{8}$';
  RegExp regex = RegExp(pattern.toString());

  if (!regex.hasMatch(value)) {
    return "Password must be exactly 8 characters long and contain only digits and alphabets";
  }

  return null;
}

String? validateField(String? value, String fieldType) {
  if (value == null || value.trim().isEmpty) {
    return "$fieldType is required";
  }

  if (fieldType == "Phone") {
    Pattern phonePattern =
        r'^03\d{9}$'; // Pakistani phone numbers start with 03
    RegExp phoneRegex = RegExp(phonePattern.toString());

    if (!phoneRegex.hasMatch(value)) {
      return "Enter a valid Pakistani phone number (03XXXXXXXXX)";
    }
  }

  return null;
}

String? validateProductName(String? value) {
  if (value == null || value.isEmpty) {
    return "Product Name is required";
  }
  return null;
}

String? validateProductDescription(String? value) {
  if (value == null || value.isEmpty) {
    return "Product Description is required";
  }
  return null;
}

String? validatePrice(String? value) {
  if (value == null || value.isEmpty) {
    return "Enter Product Price";
  }
  if (double.tryParse(value) == null || double.parse(value) <= 0) {
    return "Enter a valid price";
  }
  if (value.length > 10) {
    return "Price cannot exceed 4 digits";
  }
  return null;
}

String? validateQuantity(String? value) {
  if (value == null || value.isEmpty) {
    return "Enter Quantity";
  }
  if (int.tryParse(value) == null || int.parse(value) <= 0) {
    return "Enter a valid quantity";
  }
  if (value.length > 4) {
    return "Quantity cannot exceed 4 digits";
  }
  return null;
}

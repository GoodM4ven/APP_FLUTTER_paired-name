class HelperString {
  static String toTitleCase(String input) {
    if (input.isEmpty) {
      throw ArgumentError("The input string cannot be empty.");
    }

    return input[0].toUpperCase() + input.substring(1);
  }
}

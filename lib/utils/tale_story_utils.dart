class TaleStoryUtils {
  static String validateInput(String value) {
    if (value == null || value.isEmpty) {
      return "You must have an interesting JCS story, enter it!";
    }

    if (value.length < 18 || value.split(" ").length < 8) {
      return "Come on, put some effort into the story";
    }

    return null;
  }
}

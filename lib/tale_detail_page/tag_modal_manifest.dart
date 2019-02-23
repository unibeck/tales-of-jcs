class TagModalManifest {
  static final String _chipHeroTag = "chipHeroTag";
  static final String _chipAddIconHeroTag = "chipAddIconHeroTag";

  static String getChipHeroTagFromTaleTag(String taleTag) {
    return "$taleTag-$_chipHeroTag";
  }

  static String getChipAddIconHeroTagFromTaleTag(String taleTag) {
    return "$taleTag-$_chipAddIconHeroTag";
  }

  static String getNewChipHeroTag() {
    return "new-$_chipHeroTag";
  }

  static String getNewChipAddIconHeroTag() {
    return "new-$_chipAddIconHeroTag";
  }
}
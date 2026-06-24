extension MonthExtension on int {
  int monthDays(int year) {
    // if (this == 12) {
    //   return DateTime(year + 1, 1).day - 1;
    // }
    // return DateTime(year, this + 1, 0).day;
    switch (this) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return DateTime(year, this + 1, 0).day;
      default:
        return 31;
    }
  }
}

extension ToOpacity on double {
  int get toOpacity => (this * 255).round();
}

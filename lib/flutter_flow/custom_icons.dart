import 'package:flutter/widgets.dart';

class FFIcons {
  FFIcons._();

  static const String _mtgFamily = 'Mtg';
  static const String _cardsFamily = 'Cards';
  static const String _crewmatesFamily = 'Crewmates';
  static const String _trophyFamily = 'Trophy';
  static const String _countersFamily = 'Counters';
  static const String _calendarsFamily = 'Calendars';
  static const String _refreshFamily = 'Refresh';
  static const String _editFamily = 'Edit';
  static const String _centaurFamily = 'Centaur';

  // mtg
  static const IconData kblack = IconData(0xe900, fontFamily: _mtgFamily);
  static const IconData kblue = IconData(0xe902, fontFamily: _mtgFamily);
  static const IconData kred = IconData(0xe904, fontFamily: _mtgFamily);
  static const IconData kwhite = IconData(0xe906, fontFamily: _mtgFamily);
  static const IconData kgreen = IconData(0xe908, fontFamily: _mtgFamily);

  // cards
  static const IconData kcards = IconData(0xe900, fontFamily: _cardsFamily);

  // crewmates
  static const IconData kcrewmates =
      IconData(0xe900, fontFamily: _crewmatesFamily);

  // trophy
  static const IconData ktrophyEmpty =
      IconData(0xe900, fontFamily: _trophyFamily);
  static const IconData ktrophyFull =
      IconData(0xe901, fontFamily: _trophyFamily);

  // counters
  static const IconData ke = IconData(0xe900, fontFamily: _countersFamily);
  static const IconData kp = IconData(0xe901, fontFamily: _countersFamily);
  static const IconData kticket = IconData(0xe902, fontFamily: _countersFamily);

  // calendars
  static const IconData knounCalendar466130FFFFFF =
      IconData(0xe906, fontFamily: _calendarsFamily);
  static const IconData knounCalendar5835988FFFFFF =
      IconData(0xe907, fontFamily: _calendarsFamily);
  static const IconData knounCalendar5867165FFFFFF =
      IconData(0xe908, fontFamily: _calendarsFamily);

  // refresh
  static const IconData krefresh = IconData(0xe900, fontFamily: _refreshFamily);

  // edit
  static const IconData kedit1 = IconData(0xe900, fontFamily: _editFamily);
  static const IconData kedit2 = IconData(0xe901, fontFamily: _editFamily);

  // centaur
  static const IconData kcentaur = IconData(0xe900, fontFamily: _centaurFamily);
}

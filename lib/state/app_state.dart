import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/gems.dart';
import 'badges.dart';

/// Global app state: visited states, visited gems, locale. Persisted locally.
class AppState extends ChangeNotifier {
  static const _kStates = 'visited_states';
  static const _kGems = 'visited_gems';
  static const _kLocale = 'locale';
  static const _kName = 'user_name';

  Set<String> visitedStates = {};
  Set<String> visitedGems = {};
  String locale = 'en';
  String userName = '';
  bool ready = false;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    visitedStates = (p.getStringList(_kStates) ?? <String>[]).toSet();
    visitedGems = (p.getStringList(_kGems) ?? <String>[]).toSet();
    locale = p.getString(_kLocale) ?? 'en';
    userName = p.getString(_kName) ?? '';
    ready = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kStates, visitedStates.toList());
    await p.setStringList(_kGems, visitedGems.toList());
    await p.setString(_kLocale, locale);
    await p.setString(_kName, userName);
  }

  Future<void> toggleState(String name) async {
    if (visitedStates.contains(name)) {
      visitedStates.remove(name);
    } else {
      visitedStates.add(name);
    }
    await _save();
    notifyListeners();
  }

  Future<void> toggleGem(String id) async {
    if (visitedGems.contains(id)) {
      visitedGems.remove(id);
    } else {
      visitedGems.add(id);
    }
    await _save();
    notifyListeners();
  }

  Future<void> setLocale(String l) async {
    locale = l;
    await _save();
    notifyListeners();
  }

  Future<void> setUserName(String n) async {
    userName = n;
    await _save();
    notifyListeners();
  }

  int get statesCount => visitedStates.length;
  int get gemsCount => visitedGems.length;

  // --- badges ---------------------------------------------------------------
  List<Badge> badges() {
    const ne = {
      'Arunachal Pradesh', 'Assam', 'Manipur', 'Meghalaya',
      'Mizoram', 'Nagaland', 'Sikkim', 'Tripura'
    };
    return [
      Badge('first', 'Pehla Kadam', 'पहला कदम', 'Visit your first state',
          'अपना पहला राज्य घूमें', visitedStates.isNotEmpty),
      Badge('five', 'Paanch ka Punch', 'पांच का पंच', 'Visit 5 states',
          '5 राज्य घूमें', visitedStates.length >= 5),
      Badge('ten', 'Dus ka Dum', 'दस का दम', 'Visit 10 states',
          '10 राज्य घूमें', visitedStates.length >= 10),
      Badge('half', 'Half Bharat', 'आधा भारत', 'Visit 18 states — half the country',
          '18 राज्य — आधा देश', visitedStates.length >= 18),
      Badge('full', 'Bharat Vijay', 'भारत विजय', 'Visit all 36 states & UTs',
          'सभी 36 राज्य और केंद्र शासित प्रदेश', visitedStates.length >= 36),
      Badge('northeast', 'Northeast Explorer', 'नॉर्थईस्ट एक्सप्लोरर',
          'Visit all 8 Northeastern states', 'सभी 8 पूर्वोत्तर राज्य घूमें',
          ne.every(visitedStates.contains)),
      Badge('desert', 'Desert Trail', 'रेगिस्तान ट्रेल', 'Rajasthan + Gujarat',
          'राजस्थान + गुजरात',
          visitedStates.contains('Rajasthan') &&
              visitedStates.contains('Gujarat')),
      Badge('islands', 'Island Hopper', 'द्वीप यात्री',
          'Andaman & Nicobar + Lakshadweep', 'अंडमान-निकोबार + लक्षद्वीप',
          visitedStates.contains('Andaman and Nicobar') &&
              visitedStates.contains('Lakshadweep')),
      Badge('gems5', 'Gems Hunter', 'रत्न शिकारी', 'Visit 5 hidden gems',
          '5 छिपे हुए रत्न देखें', visitedGems.length >= 5),
      Badge('plains', 'Ganga Plains', 'गंगा मैदान',
          'UP + Bihar + West Bengal', 'उत्तर प्रदेश + बिहार + पश्चिम बंगाल',
          visitedStates.contains('Uttar Pradesh') &&
              visitedStates.contains('Bihar') &&
              visitedStates.contains('West Bengal')),
    ];
  }

  // --- traveler title (share card personality) -------------------------------
  String travelerTitle() {
    final v = visitedStates;
    const ne = {
      'Arunachal Pradesh', 'Assam', 'Manipur', 'Meghalaya',
      'Mizoram', 'Nagaland', 'Sikkim', 'Tripura'
    };
    const desert = {'Rajasthan', 'Gujarat'};
    const coast = {'Goa', 'Kerala', 'Karnataka', 'Tamil Nadu'};
    const mountains = {
      'Himachal Pradesh', 'Uttarakhand', 'Jammu and Kashmir', 'Ladakh', 'Sikkim'
    };
    if (v.length >= 36) return locale == 'hi' ? 'भारत विजेता' : 'Bharat Conqueror';
    if (v.isNotEmpty) {
      if (v.where(ne.contains).length >= 3) {
        return locale == 'hi' ? 'नॉर्थईस्ट एक्सप्लोरर' : 'Northeast Explorer';
      }
      if (v.where(mountains.contains).length >= 3) {
        return locale == 'hi' ? 'पहाड़ प्रेमी' : 'Mountain Seeker';
      }
      if (v.where(desert.contains).length == 2) {
        return locale == 'hi' ? 'रेगिस्तान यात्री' : 'Desert Drifter';
      }
      if (v.where(coast.contains).length >= 3) {
        return locale == 'hi' ? 'तटीय घुमक्कड़' : 'Coastal Wanderer';
      }
    }
    if (v.length >= 24) return locale == 'hi' ? 'भारत दिग्गज' : 'Bharat Veteran';
    if (v.length >= 12) return locale == 'hi' ? 'देश दर्शन' : 'Desh Darshan';
    if (v.length >= 5) return locale == 'hi' ? 'भारत एक्सप्लोरर' : 'Bharat Explorer';
    if (v.isNotEmpty) return locale == 'hi' ? 'नया सफ़र' : 'Naya Safar';
    return locale == 'hi' ? 'सपनों का मुसाफ़िर' : 'Sapno ka Musafir';
  }

  List<HiddenGem> gemsForStates(Set<String> states) => states.isEmpty
      ? hiddenGems
      : hiddenGems.where((g) => states.contains(g.state)).toList();
}

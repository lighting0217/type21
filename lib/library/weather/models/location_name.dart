/// A class representing location name data.
///
/// This class contains information about a location's name, local names, latitude, longitude, country, and state.
class LocationNameData {
  final String name;
  final Map<String, String> localNames;
  final double lat;
  final double lon;
  final String country;
  final String state;

  /// Creates a new instance of [LocationNameData].
  ///
  /// The [name], [localNames], [lat], [lon], [country], and [state] parameters are required.
  const LocationNameData({
    required this.name,
    required this.localNames,
    required this.lat,
    required this.lon,
    required this.country,
    required this.state,
  });

  /// Creates a new instance of [LocationNameData] from a JSON map.
  ///
  /// The [json] parameter must not be null.
  factory LocationNameData.fromJson(Map<String, dynamic> json) =>
      LocationNameData(
        name: json['name'] as String,
        localNames: Map<String, String>.from(json['local_names']),
        lat: json['lat'] as double,
        lon: json['lon'] as double,
        country: json['country'] as String,
        state: _translateStateToThai(json['state'] as String),
      );

  /// Translates the state name to Thai.
  ///
  /// The [state] parameter is the name of the state to be translated.
  static String _translateStateToThai(String state) {
    final Map<String, String> stateNamesToThai = {
      "Bangkok": "กรุงเทพมหานคร",
      "Chiang Mai Province": "จังหวัดเชียงใหม่",
      "Chiang Rai Province": "จังหวัดเชียงราย",
      "Mae Hong Son Province": "จังหวัดแม่ฮ่องสอน",
      "Lampang Province": "จังหวัดลำปาง",
      "Lamphun Province": "จังหวัดลำพูน",
      "Phayao Province": "จังหวัดพะเยา",
      "Phrae Province": "จังหวัดแพร่",
      "Uttaradit Province": "จังหวัดอุตรดิตถ์",
      "Bueng Kan Province": "จังหวัดบึงกาฬ",
      "Buriram Province": "จังหวัดบุรีรัมย์",
      "Nan Province": "จังหวัดน่าน",
      "Kalasin Province": "จังหวัดกาฬสินธุ์",
      "Khon Kaen Province": "จังหวัดขอนแก่น",
      "Chaiyaphum Province": "จังหวัดชัยภูมิ",
      "Mukdahan Province": "จังหวัดมุกดาหาร",
      "Yasothon Province": "จังหวัดยโสธร",
      "Roi Et Province": "จังหวัดร้อยเอ็ด",
      "Loei Province": "จังหวัดเลย",
      "Surin Province": "จังหวัดสุรินทร์",
      "Sisaket Province": "จังหวัดศรีสะเกษ",
      "Nong Khai Province": "จังหวัดหนองคาย",
      "Udon Thani Province": "จังหวัดอุดรธานี",
      "Chai Nat Province": "จังหวัดชัยนาท",
      "Phichit Province": "จังหวัดพิจิตร",
      "Nonthaburi Province": "จังหวัดนนทบุรี",
      "Phetchabun Province": "จังหวัดเพชรบูรณ์",
      "Lopburi Province": "จังหวัดลพบุรี",
      "Sing Buri Province": "จังหวัดสิงห์บุรี",
      "Sukhothai Province": "จังหวัดสุโขทัย",
      "Saraburi Province": "จังหวัดสระบุรี",
      "Ang Thong Province": "จังหวัดอ่างทอง",
      "Chonburi Province": "จังหวัดชลบุรี",
      "Trat Province": "จังหวัดตราด",
      "Rayong Province": "จังหวัดระยอง",
      "Sa Kaeo Province": "จังหวัดสระแก้ว",
      "Tak Province": "จังหวัดตาก",
      "Ratchaburi Province": "จังหวัดราชบุรี",
      "Krabi Province": "จังหวัดกระบี่",
      "Chumphon Province": "จังหวัดชุมพร",
      "Trang Province": "จังหวัดตรัง",
      "Songkhla Province": "จังหวัดสงขลา",
      "Narathiwat Province": "จังหวัดนราธิวาส",
      "Pattani Province": "จังหวัดปัตตานี",
      "Phang Nga Province": "จังหวัดพังงา",
      "Phuket Province": "จังหวัดภูเก็ต",
      "Ranong Province": "จังหวัดระนอง",
      "Satun Province": "จังหวัดสตูล",
      "Yala Province": "จังหวัดยะลา",
      "Phatthalung Province": "จังหวัดพัทลุง",
      "Kanchanaburi Province": "จังหวัดกาญจนบุรี",
      "Prachinburi Province": "จังหวัดปราจีนบุรี",
      "Phitsanulok Province": "จังหวัดพิษณุโลก",
      "Samut Prakan Province": "จังหวัดสมุทรปราการ",
      "Samut Sakhon Province": "จังหวัดสมุทรสาคร",
      "Uthai Thani Province": "จังหวัดอุทัยธานี",
      "Chanthaburi Province": "จังหวัดจันทบุรี",
      "Chachoengsao Province": "จังหวัดฉะเชิงเทรา",
      "Phetchaburi Province": "จังหวัดเพชรบุรี",
      "Surat Thani Province": "จังหวัดสุราษฎร์ธานี",
      "Nakhon Nayok Province": "จังหวัดนครนายก",
      "Nakhon Sawan Province": "จังหวัดนครสวรรค์",
      "Pathum Thani Province": "จังหวัดปทุมธานี",
      "Suphan Buri Province": "จังหวัดสุพรรณบุรี",
      "Sakon Nakhon Province": "จังหวัดสกลนคร",
      "Nakhon Phanom Province": "จังหวัดนครพนม",
      "Nakhon Pathom Province": "จังหวัดนครปฐม",
      "Amnat Charoen Province": "จังหวัดอำนาจเจริญ",
      "Maha Sarakham Province": "จังหวัดมหาสารคาม",
      "Kamphaeng Phet Province": "จังหวัดกำแพงเพชร",
      "Nong Bua Lamphu Province": "จังหวัดหนองบัวลำภู",
      "Samut Songkhram Province": "จังหวัดสมุทรสงคราม",
      "Ubon Ratchathani Province": "จังหวัดอุบลราชธานี",
      "Nakhon Ratchasima Province": "จังหวัดนครราชสีมา",
      "Prachuap Khiri Khan Province": "จังหวัดประจวบคีรีขันธ์",
      "Nakhon Si Thammarat Province": "จังหวัดนครศรีธรรมราช",
      "Phra Nakhon Si Ayutthaya Province": "จังหวัดพระนครศรีอยุธยา",
    };
    return stateNamesToThai[state] ?? state;
  }
}

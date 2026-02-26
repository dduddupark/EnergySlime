// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Energy Slime';

  @override
  String get noDataMsg => '걸음 수 데이터가 없습니다.\n삼성 헬스 또는 구글 피트니스와 연동해주세요.';

  @override
  String get connect => '연결하기';

  @override
  String get todayRecord => '오늘의 기록';

  @override
  String get calories => 'Calories';

  @override
  String get activeTime => 'Active Time';

  @override
  String steps(String steps) {
    return '$steps 걸음';
  }

  @override
  String get stepsUnit => '보';

  @override
  String progressSteps(String current, String target) {
    return '$current / $target 걸음';
  }

  @override
  String get trackingSteps => '걸음 수 기록 중...';

  @override
  String get testingTitle => '테스트: 걸음 수 설정';

  @override
  String stepsSetMessage(int steps) {
    return '걸음수가 $steps보로 설정되었습니다!';
  }

  @override
  String get noHealthDataWarning =>
      '데이터를 가져올 수 없습니다. 삼성 헬스앱을 동기화하거나 권한을 확인해주세요.';

  @override
  String get settings => '설정';

  @override
  String get myInfo => '내 정보';

  @override
  String get checkHistory => '기록 확인';

  @override
  String get historySubtitle => '날짜별 걸음 수와 슬라임 성장도를 확인합니다.';

  @override
  String get themeSettings => '테마 설정';

  @override
  String get darkTheme => '다크 테마 사용';

  @override
  String get darkThemeSubtitle => '앱의 배경을 어둡게 설정합니다.';

  @override
  String get goalFullText => '10,000보 기준 (가득 참)';

  @override
  String get kcalInfoText => '날짜 아래 숫자는 소모 kcal 입니다';

  @override
  String slimeSpeechHungry(int remaining) {
    return '배고파서 움직일 힘이 없어...\n($remaining보 남음)';
  }

  @override
  String get slimeSpeechActive => '조금만 더!\n몸이 가벼워지고 있어!';

  @override
  String get slimeSpeechParty => '오늘 최고야!\n나는 이제 무적의 슬라임!';

  @override
  String stepUnit(int count) {
    return '$count 보';
  }

  @override
  String purchasedItem(String itemName) {
    return '$itemName을(를) 구매했습니다!';
  }

  @override
  String get notEnoughPoints => '포인트가 부족합니다! 걷기를 통해 물방울을 모아보세요.';

  @override
  String get shopTitle => '상점';

  @override
  String get earnPointRule => '100 걸음당 1 물방울이 적립됩니다!';

  @override
  String get unequipBtn => '장착 해제';

  @override
  String get equipBtn => '착용하기';

  @override
  String get buyBtn => '구매';

  @override
  String get purchaseHistoryTitle => '구매 내역';

  @override
  String get noPurchasedItems => '아직 구매한 아이템이 없습니다.';

  @override
  String get categoryBg => '배경';

  @override
  String get categoryFace => '얼굴 꾸미기';

  @override
  String get categoryHead => '모자';

  @override
  String get statusEquipped => '착용 중';

  @override
  String get statusStored => '보관 중';

  @override
  String get add100Points => '100 포인트 추가';

  @override
  String get add100PointsSuccess => '💧 테스트용: 100 포인트 지급 완료! 💧';

  @override
  String get initStepData => '걸음 수 데이터를 초기화 중입니다...';

  @override
  String recentDaysHistory(Object days, Object title) {
    return '최근 $days일 $title';
  }

  @override
  String dday_n(Object days) {
    return 'D-$days';
  }

  @override
  String get today => 'Today';

  @override
  String get hat_red => '빨간 캡모자';

  @override
  String get hat_crown => '작은 왕관';

  @override
  String get hat_straw => '밀짚모자';

  @override
  String get hat_wizard => '마법사 모자';

  @override
  String get hat_party => '파티 모자';

  @override
  String get face_glasses => '선글라스';

  @override
  String get face_mustache => '콧수염';

  @override
  String get face_blush => '발그레';

  @override
  String get face_mask => '마스크';

  @override
  String get bg_forest => '숲속 배경';

  @override
  String get bg_space => '우주 배경';

  @override
  String get bg_beach => '해변 배경';

  @override
  String get bg_city => '도시 배경';

  @override
  String get bg_snow => '눈밭 배경';
}

// 1. 함수 퀴즈: Named Parameters & Default Values
// Mission: 아래 함수를 구현하고 main에서 호출해 보세요.
// 조건 1: 'name'은 반드시 입력받아야 하는 Named Parameter입니다 (required)
// 조건 2: 'steps'는 선택 사항이며 기본값은 0입니다. (default value)
// 조건 3: 'isHappy'는 Nullable 불리언 값입니다. (null safety)

void updateSlimeStatus({required String? name, int steps = 0, bool? isHappy}) {
  // 출력 예시: "슬라임 [이름]의 걸음 수는 [걸음수] 입니다. 행복한가요? [여부]"
  print("슬라임 $name의 걸음 수는 $steps 입니다. 행복한가요? $isHappy");
}

// 2. 생성자 퀴즈: Named & Factory Constructors
// Mission: 'Slime' 클래스에 'fromJson'이라는 이름의 생성자를 만들어 보세요.
// Kotlin에서는 'companion object'나 'secondary constructor'로 구현하던 패턴입니다.

class Slime {
  final String name;
  final int level;

  Slime({required this.name, required this.level});

  // Mission: 여기서 JSON 형태의 'Map<String, dynamic>'을 받아서 Slime 객체를 반환하는
  // 'fromJson' Named Constructor를 만들어 보세요.
  Slime.fromJson({required Map<String, dynamic> json})
      : name = json['name'] ?? 'Unknown',
        level = json['level'] ?? 1;
}

// 3. 컬렉션 퀴즈: Collection if/for (Flutter UI 필수 문법)
// Mission: 'items' 리스트를 만드는데, 'isVIP'가 true일 때만 'Golden Crown'을 추가해 보세요.
// Dart에서는 List 안에서 if문을 바로 쓸 수 있습니다! (Collection If)

void testCollectionIf(bool isVIP) {
  var inventory = [
    'Red Hat',
    'Blue Glasses',
    if (isVIP) 'Golden Crown',
    // <-- 여기에 Collection If를 사용하여 'Golden Crown'을 추가해 보세요.
  ];
  print('Inventory: $inventory');
}

// 4. 비동기 퀴즈: Future & Async/Await (Kotlin Coroutines 대응)
// Mission: 2초 뒤에 서버에서 에너지를 가져오는 가상 함수를 만드세요.
// 키워드: Future, async, await, Duration

Future<int> fetchEnergyFromServer() async {
  // <-- 여기에 2초 대기(delay) 후 100을 반환하는 코드를 작성해 보세요.
  await Future.delayed(const Duration(seconds: 2));
  return 100;
}

// 5. 믹스인 퀴즈: Mixins (다중 상속의 보완책)
// Mission: 'Healer' 기능을 하는 mixin을 만들고 'MedSlime'에 적용해 보세요.
// 키워드: mixin, with

mixin Healer {
  void heal() => print('체력을 회복합니다! ✨');
}

// Slime을 상속받고 Healer 기능을 추가한 MedSlime을 정의해 보세요.
class MedSlime extends Slime with Healer {
  MedSlime({required super.name, required super.level});
  // 여기에 mixin을 적용하는 문법을 추가해 보세요.
  @override
  void heal() => print('체력을 회복합니다! 💖');
}

void main() {
  print('--- Quiz Start ---');

  // 1번 호출 테스트
  updateSlimeStatus(name: '구루미', steps: 10, isHappy: true);

  // 2번 호출 테스트
  var mySlime = Slime.fromJson(json: {'name': '구루미', 'level': 5});
  print('Slime: ${mySlime.name}, Lv.${mySlime.level}');

  // 3번 호출 테스트
  testCollectionIf(true);
  testCollectionIf(false);

  print('\n--- Advanced Quiz ---');

  // 4번 호출 테스트 (비동기)
  print('에너지 충전 중...');
  fetchEnergyFromServer().then((value) => print('충전 완료: $value'));

  // 5번 호출 테스트 (믹스인)
  var healer = MedSlime(name: '힐링슬라임', level: 10);
  healer.heal();
}

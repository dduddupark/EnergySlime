import 'package:flutter/material.dart';

// 1. 단순한 인사말 위젯 (Stateless)
// Android의 단순한 뷰 구성과 비슷합니다.
class HelloSlime extends StatelessWidget {
  const HelloSlime({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '어서와, 슬라임 월드는 처음이지?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10), // Android의 margin/padding 대신 쓰는 간격 위젯
        Text('아래 버튼을 눌러 에너지를 채워봐!'),
      ],
    );
  }
}

// 2. 에너지가 차오르는 위젯 (Stateful)
// 상태(Energy)가 변할 때 화면을 다시 그리는 예제입니다.
class EnergyCounter extends StatefulWidget {
  const EnergyCounter({super.key});

  @override
  State<EnergyCounter> createState() => _EnergyCounterState();
}

class _EnergyCounterState extends State<EnergyCounter> {
  int energy = 0;

  void _chargeEnergy() {
    // setState()가 호출되면 build()가 다시 실행됩니다.
    setState(() {
      energy += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '현재 에너지: $energy',
          style: const TextStyle(
              fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _chargeEnergy,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('에너지 충전!'),
        ),
      ],
    );
  }
}

// 3. 미션: 슬라임 이름표 (직접 완성해 보세요!)
class SlimeNameTag extends StatelessWidget {
  final String name;

  const SlimeNameTag({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          name,
        ),
      ),
    );
  }
}

// 메인 화면 구조
class BasicScreen extends StatelessWidget {
  const BasicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 기초 맛보기'),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HelloSlime(),
              Divider(height: 60, thickness: 2),
              EnergyCounter(),
              SizedBox(height: 40),
              SlimeNameTag(name: '구루미'),
            ],
          ),
        ),
      ),
    );
  }
}

// 로컬에서 이 화면만 테스트하고 싶을 때 사용하는 main 함수
void main() {
  runApp(const MaterialApp(
    home: BasicScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

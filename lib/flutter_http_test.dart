import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// Dio 인스턴스 생성 및 설정
final dio = Dio()
  ..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

Future<String> fetchDogImage() async {
  try {
    // dio.get은 Uri.parse 없이 문자열로 바로 사용 가능합니다.
    final response = await dio.get('https://dog.ceo/api/breeds/image/random');

    // dio는 응답 데이터를 자동으로 Map으로 변환해주므로 jsonDecode가 필요 없습니다.
    final data = response.data;

    // dog.ceo API는 'status' 필드가 'success'일 때 성공입니다.
    if (data['status'] == 'success') {
      // 1. 데이터 형식이 맞는지, 필요한 키가 있는지 확인
      if (data.containsKey('message') && data['message'] is String) {
        return data['message'];
      } else {
        throw Exception('데이터 형식이 올바르지 않습니다.');
      }
    } else {
      throw Exception('서버 응답 에러: ${response.statusCode}');
    }
  } catch (e) {
    // 2. 네트워크 연결 끊김 등 예상치 못한 모든 에러 처리
    throw Exception('이미지를 불러오지 못했습니다: $e');
  }
}

class DogImageScreen extends StatefulWidget {
  const DogImageScreen({super.key});

  @override
  State<DogImageScreen> createState() => _DogImageScreenState();
}

class _DogImageScreenState extends State<DogImageScreen> {
  late Future<String> _dogImageFuture;

  @override
  void initState() {
    super.initState();
    _dogImageFuture = fetchDogImage();
  }

  void _refreshDog() {
    setState(() {
      _dogImageFuture = fetchDogImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('random dog'), centerTitle: true),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias, // 카드 모서리에 맞춰 이미지 자르기
                child: FutureBuilder<String>(
                    future: _dogImageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 250,
                          width: 300,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 500, // 웹 브라우저에서도 일정 크기 이상 커지지 않게 제한
                          ),
                          child: Image.network(
                            snapshot.data!,
                            width: double.infinity,
                            fit: BoxFit.fitWidth, // 가로 너비에 맞춰서 리사이징
                          ),
                        );
                      }
                      return const Text('No data');
                    }),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                  onPressed: _refreshDog,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DogImageScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Dio 인스턴스 설정
final dio = Dio()
  ..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

// ---------------------------------------------------------
// 2. Riverpod Providers (ViewModel 역할)
// ---------------------------------------------------------

// API 호출 결과를 관리하는 FutureProvider
// ref.invalidate(self)를 호출하면 이 로직이 다시 실행됩니다.
final dogImageProvider = FutureProvider<String>((ref) async {
  try {
    final response = await dio.get('https://dog.ceo/api/breeds/image/random');
    final data = response.data;

    if (data['status'] == 'success' && data['message'] is String) {
      return data['message'];
    } else {
      throw Exception('데이터 형식이 올바르지 않습니다.');
    }
  } on DioException catch (e) {
    throw Exception('네트워크 에러: ${e.message}');
  }
});

// ---------------------------------------------------------
// 3. UI Widgets (ConsumerWidget 사용)
// ---------------------------------------------------------

class RiverpodDogScreen extends ConsumerWidget {
  const RiverpodDogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // dogImageProvider의 상태를 '관찰'합니다.
    // AsyncValue 타입이 반환되어 loading, error, data 처리가 매우 간편해집니다.
    final dogAsync = ref.watch(dogImageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Dog Test'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(dogImageProvider), // 데이터 새로고침
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                // AsyncValue의 .when 사용 (가장 중요한 부분!)
                child: dogAsync.when(
                  data: (imageUrl) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Error: $err'),
                  ),
                  loading: () => const SizedBox(
                    height: 250,
                    width: 300,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(dogImageProvider), // 데이터 새로고침
                icon: const Icon(Icons.refresh),
                label: const Text('새로운 강아지 불러오기'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. Main Entry Point (ProviderScope 필수)
// ---------------------------------------------------------
void main() {
  runApp(
    // Riverpod을 사용하려면 반드시 ProviderScope로 감싸야 합니다. (DI 컨테이너 역할)
    const ProviderScope(
      child: MaterialApp(
        home: RiverpodDogScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwkvcommon/reference_count.dart';
import 'package:rwkvcommon/reference_model.dart';
import 'package:rwkvcommon/rwkvcommon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  var text1 = ''.obs;
  var text2 = ''.obs;
  var references = <ReferenceModel>[].obs;
  var referencount = 0.obs;
  final ScrollController _scrollController = ScrollController();
  TextEditingController textEditingController =
      TextEditingController(text: '深圳旅游最佳必去十大景点');
  var isShowThink = false.obs;

  MyHomePage({super.key});
  void searchAction(String prompt) {
    RwkvCommon.getWebSearchData(
      '',
      prompt,
      (onReasonData) {
        debugPrint('onReasonData==$onReasonData');
        text1.value = text1.value + onReasonData;
        scrollAction();
        isShowThink.value = true;
      },
      (onData) {
        debugPrint('onData==$onData');
        text2.value = text2.value + onData;
        scrollAction();
      },
      (onFinish) {
        debugPrint('onFinish==$onFinish');
      },
      (onReferences) {
        debugPrint('onReferences==$onReferences');
        references.addAll(onReferences);
        referencount.value = references.length;
      },
    ); //hi，你有什么能力呢
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('联网搜索'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: '请输入搜索内容',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 10), // 两者之间间距
                ElevatedButton(
                  onPressed: () {
                    // resetData();
                    searchAction(textEditingController.text);
                  },
                  child: Text('搜索'),
                ),
              ],
            ),
            Obx(() => referencount.value > 0
                ? ReferenceCount(
                    references: references,
                  )
                : SizedBox.shrink()),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Obx(
                      () => isShowThink.value
                          ? Text(
                              '思考结果:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                    Obx(
                      () => Text(
                        text1.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Obx(
                      () => Text(
                        text2.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollAction() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void resetData() {
    text1 = ''.obs;
    text2 = ''.obs;
    references = <ReferenceModel>[].obs;
    referencount = 0.obs;
    isShowThink = false.obs;
    // _scrollController = ScrollController();
  }
}

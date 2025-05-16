import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rwkvcommon/reference_model.dart';

class RwkvCommon {
  static Future<void> getWebSearchData(
      String token,
      String prompt,
      Function(String) onReasonData,
      Function(String) onData,
      Function(bool) onFinish,
      Function(List<ReferenceModel>) onReferences) async {
    final dio = Dio();
    final regReason = RegExp(r'"reasoning_content"\s*:\s*"((?:[^"\\]|\\.)*)"');
    final regContent = RegExp(r'"content"\s*:\s*"((?:[^"\\]|\\.)*)"');
    final regReferences = RegExp(r'"references"\s*:\s*(\[[\s\S]*?\])');
    StringBuffer choices = StringBuffer();
    final List<ReferenceModel> references = [];
    // 设置请求头
    dio.options.headers = {
      'Authorization': token, // 替换为你的实际 token
      'Content-Type': 'application/json',
    };

    // 构造请求数据
    final data = {
      "model": "bot-20250218182311-kq7vj", // 替换为实际的模型ID
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "stream": true,
    };

    try {
      // 发送 POST 请求
      final response = await dio.post(
        'https://ark.cn-beijing.volces.com/api/v3/bots/chat/completions',
        data: data,
        options: Options(
          responseType: ResponseType.stream, // 使用流式响应
        ),
      );

      // 获取响应流
      final stream = response.data.stream;

      // 将字节流转换为字符串流
      await for (var chunk in stream) {
        final decodedChunk = utf8.decode(chunk);
        // debugPrint('Received chunk: $decodedChunk');
        if (decodedChunk.contains('"references"') ||
            decodedChunk.contains('}}]}')) {
          debugPrint('has references');
          choices.write(decodedChunk);
          if (decodedChunk.contains('}}]}')) {
            final match = regReferences.firstMatch(choices.toString());
            if (match != null) {
              final referencesJson = match.group(1);
              final List<dynamic> decoded = json.decode(referencesJson!);
              // debugPrint('references==$decoded'); // 这是 List<dynamic>

              for (var item in decoded) {
                if (item is Map<String, dynamic>) {
                  references.add(ReferenceModel.fromJson(item));
                } else {
                  debugPrint('Invalid reference item: $item');
                }
              }
              onReferences(references);
            }
          }
        } else if (decodedChunk.contains('"content":""')) {
          //Reasoning内容
          final matches = regReason.allMatches(decodedChunk);
          for (final match in matches) {
            final content = match.group(1);
            if (content != null) {
              final decoded = _decodeJsonString(content);
              onReasonData(decoded);
            }
          }
        } else {
          final matches = regContent.allMatches(decodedChunk);
          for (final match in matches) {
            final content = match.group(1);
            if (content != null) {
              final decoded = _decodeJsonString(content);
              onData(decoded);
            }
          }
        }
        if (decodedChunk.contains('data:[DONE]')) {
          onFinish(true);
        }
      }
    } catch (e) {
      // 错误处理
      debugPrint(e.toString());
      throw Exception('Error: $e');
    }
  }

  static String _decodeJsonString(String input) {
    return json.decode('"$input"'); // 自动处理转义字符
  }
}

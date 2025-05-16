import 'dart:convert';
import 'dart:typed_data';
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
    Function(List<ReferenceModel>) onReferences,
  ) async {
    final dio = Dio();
    final regReason = RegExp(r'"reasoning_content"\s*:\s*"((?:[^"\\]|\\.)*)"');
    final regContent = RegExp(r'"content"\s*:\s*"((?:[^"\\]|\\.)*)"');
    final regReferences = RegExp(r'"references"\s*:\s*(\[[\s\S]*?\])');

    StringBuffer choices = StringBuffer();
    bool hasReferences = false;
    final List<ReferenceModel> references = [];

    dio.options.headers = {
      'Authorization': token,
      'Content-Type': 'application/json',
    };

    final data = {
      "model": "bot-20250218182311-kq7vj",
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "stream": true,
    };

    try {
      final response = await dio.post(
        'https://ark.cn-beijing.volces.com/api/v3/bots/chat/completions',
        data: data,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      final List<int> buffer = [];

      await for (var chunk in stream) {
        // 追加字节数据到缓冲区
        if (chunk is List<int>) {
          buffer.addAll(chunk);
        } else if (chunk is Uint8List) {
          buffer.addAll(chunk.toList());
        }

        // 尝试解码：找出最大的合法 UTF-8 子串
        int validUpTo = _findValidUtf8Prefix(buffer);
        if (validUpTo > 0) {
          final String decodedChunk = utf8.decode(buffer.sublist(0, validUpTo));
          debugPrint('Decoded chunk: $decodedChunk');

          // 剩余不完整部分保留
          buffer.removeRange(0, validUpTo);

          // 流式解析内容
          if (decodedChunk.contains('"references"') ||
              decodedChunk.contains('}}]}') ||
              hasReferences) {
            hasReferences = true;
            choices.write(decodedChunk);
            if (decodedChunk.contains('}}]}')) {
              hasReferences = false;
              final match = regReferences.firstMatch(choices.toString());
              if (match != null) {
                final referencesJson = match.group(1);
                final List<dynamic> decoded = json.decode(referencesJson!);
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
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Error: $e');
    }
  }

  static String _decodeJsonString(String input) {
    return json.decode('"$input"'); // 处理转义
  }

  /// 查找 UTF-8 缓冲区中前缀的最大合法长度
  static int _findValidUtf8Prefix(List<int> buffer) {
    for (int i = buffer.length; i > 0; i--) {
      try {
        utf8.decode(buffer.sublist(0, i));
        return i;
      } catch (_) {}
    }
    return 0;
  }
}

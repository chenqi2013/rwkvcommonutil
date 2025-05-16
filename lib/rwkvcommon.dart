import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    final regReferences = RegExp(r'"references"\s*:\s*(\[(?:[\s\S]*?\}\])\s*)');

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

  ///统计上报日活数据
  static Future<void> reportStatistics(
      BuildContext context, String website, String hostname) async {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    Dio dio = Dio();
    String url = 'https://analytics.rwkv.cn/api/send';
    Map<String, dynamic> data = {
      "type": "event",
      "payload": {
        "website": website,
        "hostname": hostname,
        "screen": "${screenWidth.toInt()}x${screenHeight.toInt()}",
        "language": PlatformDispatcher.instance.locale.toString(),
        "url": "/"
      }
    };
    String userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36';
    String secChUa =
        '"Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"';
    String secChUaMobile = '?0';
    String secChUaPlatform = 'Windows';
    if (Platform.isAndroid) {
      userAgent =
          'Mozilla/5.0 (Linux; Android 13; SM-S908B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36';
      secChUa =
          '"Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"';
      secChUaMobile = '?1';
      secChUaPlatform = 'Android';
    } else if (Platform.isIOS) {
      userAgent =
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1';
      secChUa = '"Safari";v="17", "Not-A.Brand";v="8"';
      secChUaMobile = '?1';
      secChUaPlatform = 'iOS';
    } else if (Platform.isLinux) {
      userAgent =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36';
      secChUa =
          '"Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"';
      secChUaMobile = '?0';
      secChUaPlatform = 'Linux';
    }
    // 设置 headers
    dio.options.headers = {
      'Accept': '*/*',
      'Accept-Language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
      'User-Agent': userAgent,
      'sec-ch-ua': secChUa,
      'sec-ch-ua-mobile': secChUaMobile,
      'sec-ch-ua-platform': secChUaPlatform,
    };
    try {
      Response response = await dio.post(url, data: data);
      var statusCode = response.statusCode!;
      debugPrint('statusCode=$statusCode');
      debugPrint('Response data:${response.data}');
    } catch (e) {
      print('reportStatistics Error: $e');
    }
  }
}

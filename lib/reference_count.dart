import 'package:flutter/material.dart';
import 'package:rwkvcommon/reference_model.dart';
import 'package:rwkvcommon/reference_page.dart';

class ReferenceCount extends StatelessWidget {
  const ReferenceCount({super.key, required this.references});
  final List<ReferenceModel> references;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        children: [
          Text(
            '已经搜索到${references.length}个网页',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReferencePage(
              references: references,
            ),
          ),
        );
      },
    );
  }
}

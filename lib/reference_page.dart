import 'package:flutter/material.dart';
import 'package:rwkvcommon/reference_model.dart';
import 'package:rwkvcommon/webview_page.dart';

class ReferencePage extends StatelessWidget {
  ReferencePage({super.key, required this.references});
  final List<ReferenceModel> references;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: ListView.builder(
        itemCount: references.length,
        itemBuilder: (BuildContext context, int index) {
          ReferenceModel model = references[index];
          var siteName = '';
          var siteNames = model.siteName.split('-');
          if (siteNames.length > 1) {
            siteName = siteNames[1];
          } else {
            siteName = siteNames[0];
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(
                    url: model.url,
                  ),
                ),
              );
            },
            child: Container(
              margin:
                  EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 5),
              height: 115,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        siteName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        model.publishTime.split(' ')[0],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    model.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    model.summary,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

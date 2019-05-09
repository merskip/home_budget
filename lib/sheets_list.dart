import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import 'google_http_client.dart';
import 'main.dart';

class SheetsListPage extends StatefulWidget {
  SheetsListPage({Key key}) : super(key: key);

  @override
  _SheetsListState createState() => _SheetsListState();
}

class _SheetsListState extends State<SheetsListPage> {
  FileList files = FileList();
  Map<String, String> authHeaders;

  @override
  void initState() {
    super.initState();

    _fetchFiles().then((files) {
      setState(() {
        this.files = files;
      });
    });
  }

  Future<FileList> _fetchFiles() async {
    authHeaders = await googleSignIn.currentUser.authHeaders;
    final httpClient = GoogleHttpClient(authHeaders);

    return await DriveApi(httpClient).files.list(
      corpora: 'user',
      $fields: 'files(id,name,hasThumbnail,thumbnailLink)',
      q: "mimeType = 'application/vnd.google-apps.spreadsheet'");
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("Choose sheet"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(files.files?.length ?? 0, (index) {
          final file = files.files[index];
          return _buildFileItem(file);
        })
      )
    );

  _buildFileItem(File file) =>
    Stack(
      children: <Widget>[
        file.hasThumbnail
          ? Image.network(
          file.thumbnailLink, headers: authHeaders, fit: BoxFit.fill)
          : Text("No image"),

        Container(
          alignment: Alignment.bottomLeft,
          child: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(file.name),
          )
        )
      ]
    );
}

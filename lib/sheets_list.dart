import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'main.dart';

class SheetsListPage extends StatefulWidget {
  SheetsListPage({Key key}) : super(key: key);

  @override
  _SheetsListState createState() => _SheetsListState();
}

class _SheetsListState extends State<SheetsListPage> {
  FileList files = FileList();

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
    return await DriveApi(httpClient).files.list(
      corpora: 'user',
      $fields: 'files(id,name,hasThumbnail,thumbnailLink)',
      q: "mimeType = 'application/vnd.google-apps.spreadsheet'");
  }

  _onSelectedFile(File file) {
    Navigator.pushNamed(
      context,
      "/budget_preview",
      arguments: {"file": file}
    );
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
    InkWell(
      onTap: () {
        _onSelectedFile(file);
      },
      child: Stack(
        children: <Widget>[
          file.hasThumbnail
            ? Image.network(
            file.thumbnailLink, headers: httpHeaders, fit: BoxFit.fill)
            : Text("No image"),

          Container(
            alignment: Alignment.bottomLeft,
            child: GridTileBar(
              backgroundColor: Colors.black54,
              title: Text(file.name),
            )
          )
        ]
      )
    );
}
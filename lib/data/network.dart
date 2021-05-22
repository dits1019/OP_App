import 'package:http/http.dart' as http;
// json 파싱을 위해
import 'dart:convert';

class Network {
  final String uri;
  Network(this.uri);

  Future<dynamic> getJsonData() async {
    // Uri는 Url의 한 종류라고 할 수 있음
    var url = Uri.parse(uri);
    http.Response response = await http.get(url);
    // response.statusCode는 상태를 코드로 가져옴(Ex. 404, 200 ...)
    // 200은 정상
    if (response.statusCode == 200) {
      // response.body는 본문 전체를 가져오기
      String jsonData = response.body;
      var parsingData = jsonDecode(jsonData);
      return parsingData;
    }
  }
}

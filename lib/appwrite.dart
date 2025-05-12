import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class Appwrite {
  Client client = Client()
      .setEndpoint('https://fra.cloud.appwrite.io/v1')
      .setProject('682113260027b8cdb786');

  final String databaseId = '6821152300373fbe00a9';
  final String collectionId = '6821154b000bf63a1742';
  final String bucketId = '68220b430001f0931a4a';

  Future<Map<String, Map<String, dynamic>>> fetchDocuments() async {
    Databases databases = Databases(client);
    DocumentList result = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
    );
    Map<String, Map<String, dynamic>> documents = {};
    for (var document in result.documents) {
      documents[document.$id] = document.data;
    }
    return documents;
  }

  String getFileUrl(String fileId) {
    return "https://fra.cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=682113260027b8cdb786";
  }
}

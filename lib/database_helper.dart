import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'thu_chi.dart';

class DatabaseHelper {
  static late Database _database;

  // Phương thức khởi tạo cơ sở dữ liệu
  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'thu_chi.db');  // Tạo đường dẫn cơ sở dữ liệu
    _database = await openDatabase(path, version: 1, onCreate: (db, version) async {
      // Tạo bảng thu_chi
      await db.execute('''
        CREATE TABLE thu_chi(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          amount REAL,
          type TEXT,
          description TEXT,
          category TEXT
        )
      ''');
    });
  }

  // Phương thức thêm giao dịch vào cơ sở dữ liệu
  static Future<void> insertThuChi(ThuChi thuChi) async {
    await _database.insert(
      'thu_chi',
      thuChi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Phương thức lấy danh sách giao dịch từ cơ sở dữ liệu
  static Future<List<ThuChi>> getThuChiList() async {
    final List<Map<String, dynamic>> maps = await _database.query('thu_chi');
    return List.generate(maps.length, (i) {
      return ThuChi.fromMap(maps[i]);
    });
  }
}
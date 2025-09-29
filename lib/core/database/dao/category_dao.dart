import '../../../shared/models/models.dart';
import 'abstract_dao.dart';

/// Category Data Access Object interface
/// Converted from CategoryDao.java
abstract class CategoryDao extends AbstractDao<CategoryEntity> {
  static const String table = 'tb_category';
  
  static const List<String> columns = [
    'pk_category',
    'ds_category', 
    'yn_cancel',
    'dt_included'
  ];
  
  /// Get table creation SQL
  static String getCreateTableSql() {
    return '''
      CREATE TABLE $table (
        pk_category  INTEGER  NOT NULL,
        ds_category  TEXT     NOT NULL,
        yn_cancel    INTEGER  NOT NULL DEFAULT 0,
        dt_included  DATETIME NOT NULL,
        CONSTRAINT ctt_category_pk PRIMARY KEY (pk_category)
      )
    ''';
  }
  
  /// Delete all categories
  Future<void> deleteAll();
  
  /// Get last inserted ID
  Future<int?> getLastId();
}

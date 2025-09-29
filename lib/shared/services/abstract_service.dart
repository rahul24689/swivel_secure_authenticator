/// Abstract service interface for common CRUD operations
/// Converted from AbstractBusiness.java
abstract class AbstractService<T> {
  /// Delete an entity
  Future<void> delete(T entity);

  /// Insert an entity
  Future<void> insert(T entity);

  /// List all entities
  Future<List<T>> list();
}

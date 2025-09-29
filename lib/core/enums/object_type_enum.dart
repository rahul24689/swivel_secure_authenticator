/// Object type enumeration for different data types
/// Converted from ObjectTypeEn.java
enum ObjectType {
  boolean,
  string,
  integer;

  /// Get the Dart type for this object type
  Type get dartType {
    switch (this) {
      case ObjectType.boolean:
        return bool;
      case ObjectType.string:
        return String;
      case ObjectType.integer:
        return int;
    }
  }
}

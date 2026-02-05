/// Lista de los 32 estados de México según INEGI.
/// 
/// Usado para validación y selección en formularios de registro de predios.
class EstadosMexico {
  static const List<Map<String, String>> estados = [
    {'codigo': '01', 'nombre': 'Aguascalientes'},
    {'codigo': '02', 'nombre': 'Baja California'},
    {'codigo': '03', 'nombre': 'Baja California Sur'},
    {'codigo': '04', 'nombre': 'Campeche'},
    {'codigo': '05', 'nombre': 'Chiapas'},
    {'codigo': '06', 'nombre': 'Chihuahua'},
    {'codigo': '07', 'nombre': 'Ciudad de México'},
    {'codigo': '08', 'nombre': 'Coahuila'},
    {'codigo': '09', 'nombre': 'Colima'},
    {'codigo': '10', 'nombre': 'Durango'},
    {'codigo': '11', 'nombre': 'Guanajuato'},
    {'codigo': '12', 'nombre': 'Guerrero'},
    {'codigo': '13', 'nombre': 'Hidalgo'},
    {'codigo': '14', 'nombre': 'Jalisco'},
    {'codigo': '15', 'nombre': 'México'},
    {'codigo': '16', 'nombre': 'Michoacán'},
    {'codigo': '17', 'nombre': 'Morelos'},
    {'codigo': '18', 'nombre': 'Nayarit'},
    {'codigo': '19', 'nombre': 'Nuevo León'},
    {'codigo': '20', 'nombre': 'Oaxaca'},
    {'codigo': '21', 'nombre': 'Puebla'},
    {'codigo': '22', 'nombre': 'Querétaro'},
    {'codigo': '23', 'nombre': 'Quintana Roo'},
    {'codigo': '24', 'nombre': 'San Luis Potosí'},
    {'codigo': '25', 'nombre': 'Sinaloa'},
    {'codigo': '26', 'nombre': 'Sonora'},
    {'codigo': '27', 'nombre': 'Tabasco'},
    {'codigo': '28', 'nombre': 'Tamaulipas'},
    {'codigo': '29', 'nombre': 'Tlaxcala'},
    {'codigo': '30', 'nombre': 'Veracruz'},
    {'codigo': '31', 'nombre': 'Yucatán'},
    {'codigo': '32', 'nombre': 'Zacatecas'},
  ];

  /// Obtiene la lista de nombres de estados.
  static List<String> get nombres => estados.map((e) => e['nombre']!).toList();

  /// Obtiene el código de un estado por su nombre.
  static String? getCodigoPorNombre(String nombre) {
    try {
      return estados.firstWhere((e) => e['nombre'] == nombre)['codigo'];
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el nombre de un estado por su código.
  static String? getNombrePorCodigo(String codigo) {
    try {
      return estados.firstWhere((e) => e['codigo'] == codigo)['nombre'];
    } catch (e) {
      return null;
    }
  }
}





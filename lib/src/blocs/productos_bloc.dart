import 'dart:io';
import 'package:rxdart/rxdart.dart';

import 'package:formavalidation/src/providers/productos_provider.dart';
import 'package:formavalidation/src/models/producto_model.dart';

import '../models/producto_model.dart';

class ProductosBloc {
  final _productosController = new BehaviorSubject<List<ProductoModel>>();
  final _cargandoController = new BehaviorSubject<bool>();

  final _productosProvider = new ProductosProvider();

  Stream<List<ProductoModel>> get productosStream =>
      _productosController.stream;
  Stream<bool> get cargando => _cargandoController.stream;

  void cargarProductos() async {
    final productos = await _productosProvider.cargarProductos();

    _productosController.sink.add(productos);
  }

  void agregarProducto(ProductoModel producto) async {
    _cargandoController.sink.add(true);
    await _productosProvider.crearProducto(producto);
    cargarProductos();
    _cargandoController.sink.add(false);
  }

  void editarProducto(ProductoModel producto) async {
    await _productosProvider.editarProducto(producto);
    cargarProductos();
  }

  void borrarProducto(String id) async {
    _cargandoController.sink.add(true);
    await _productosProvider.borrarProducto(id);
    _cargandoController.sink.add(false);
  }

  Future<String> subirFoto(File imagen) async {
    _cargandoController.sink.add(true);
    final fotoUrl = await _productosProvider.subirImagen(imagen);
    _cargandoController.sink.add(false);

    return fotoUrl;
  }

  dispose() {
    _productosController?.close();
    _cargandoController?.close();
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:formavalidation/src/models/producto_model.dart';
import 'package:formavalidation/src/providers/productos_provider.dart';
import 'package:formavalidation/src/utils/utils.dart' as utils;

class ProductoPage extends StatefulWidget {
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  File foto;

  @override
  Widget build(BuildContext context) {
    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;
    if (prodData != null) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _uploading(),
                _crearBoton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: 'Producto'),
      onSaved: (value) => producto.titulo = value,
      validator: (value) {
        if (value.length < 3) {
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Precio'),
      onSaved: (value) => producto.valor = double.parse(value),
      validator: (value) {
        if (utils.isNumeric(value)) {
          return null;
        } else {
          return 'Solo numeros';
        }
      },
    );
  }

  Widget _crearDisponible() {
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState(() {
        producto.disponible = value;
      }),
    );
  }

  Widget _uploading() {
    if (_guardando) {
      if (foto != null) {
        return Image(
          image: AssetImage('assets/uploading.gif'),
          height: 200.0,
          fit: BoxFit.cover,
        );
      } else {
        return Image(
          image: AssetImage('assets/loading.gif'),
          height: 200.0,
          fit: BoxFit.cover,
        );
      }
    } else {
      return Container();
    }
  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.deepPurple,
      textColor: Colors.white,
      icon: Icon(Icons.save),
      label: Text('Guardar'),
      onPressed: (_guardando ? null : _submit),
    );
  }

  void _submit() async {
    if (!formKey.currentState.validate()) return;

    formKey.currentState.save();

    setState(() {
      _guardando = true;
    });

    print('Todo OK!');
    print('Producto: ${producto.titulo}');
    print('Precio: ${producto.valor}');

    final productoProvider = new ProductosProvider();

    if (foto != null) {
      producto.fotoUrl = await productoProvider.subirImagen(foto);
    }

    if (producto.id == null) {
      final FormatResult resCrear =
          await productoProvider.crearProducto(producto);
      if (resCrear.ok) {
        producto.id = resCrear.id;
      }
    } else {
      final FormatResult resEditar =
          await productoProvider.editarProducto(producto);
    }

    setState(() {
      _guardando = false;
    });

    mostrarSnackbar('Registro Guardado');

    Navigator.pop(context);
  }

  void mostrarSnackbar(String mensaje) {
    final SnackBar snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _mostrarFoto() {
    if (producto.fotoUrl != null) {
      return FadeInImage(
          image: NetworkImage(producto.fotoUrl),
          placeholder: AssetImage('assets/jar-loading.gif'),
          height: 300.0,
          width: double.infinity,
          fit: BoxFit.cover);
    } else {
      return Image(
        image: AssetImage(foto?.path ?? 'assets/no-image.png'),
        height: 200.0,
        fit: BoxFit.cover,
      );
    }
  }

  _seleccionarFoto() async {
    _obtenerImagen(ImageSource.gallery);
  }

  _tomarFoto() async {
    _obtenerImagen(ImageSource.camera);
  }

  _obtenerImagen(ImageSource origen) async {
    foto = await ImagePicker.pickImage(source: origen);

    if (foto != null) {
      producto.fotoUrl = null;
    }

    setState(() {});
  }
}

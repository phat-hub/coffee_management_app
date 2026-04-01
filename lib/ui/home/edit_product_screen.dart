import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../manager/product_manager.dart';
import '../../model/product.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _priceController;

  File? _imageFile;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.product?.title ?? '');

    _priceController = TextEditingController(
      text: widget.product != null
          ? widget.product!.price.toInt().toString()
          : '',
    );

    _imageUrl = widget.product?.imageUrl ?? '';
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _imageFile = File(image.path);
    });
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null && _imageUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ảnh')));
      return;
    }

    final product = Product(
      id: widget.product?.id,
      title: _titleController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      imageFile: _imageFile,
      imageUrl: _imageUrl,
    );

    final manager = context.read<ProductManager>();

    try {
      if (widget.product == null) {
        await manager.createProduct(product);
      } else {
        await manager.updateProduct(product);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
        actions: [
          IconButton(onPressed: saveProduct, icon: const Icon(Icons.save)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : _imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(_imageUrl, fit: BoxFit.cover),
                        )
                      : const Center(child: Icon(Icons.add_a_photo, size: 50)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Không được để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Giá',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Không được để trống';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

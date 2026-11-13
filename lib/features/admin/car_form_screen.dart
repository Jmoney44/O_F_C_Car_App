import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config.dart';
import '../../core/validators.dart';
import '../../models/car.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';
import '../orders/my_orders_screen.dart';

/// Adds a new car ([carId] null) or edits an existing one.
class CarFormScreen extends ConsumerStatefulWidget {
  const CarFormScreen({super.key, this.carId});

  final String? carId;

  @override
  ConsumerState<CarFormScreen> createState() => _CarFormScreenState();
}

class _NewPhoto {
  _NewPhoto(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

class _CarFormScreenState extends ConsumerState<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _price = TextEditingController();
  final _mileage = TextEditingController();
  final _color = TextEditingController();
  final _description = TextEditingController();

  BodyType _bodyType = BodyType.sedan;
  FuelType _fuelType = FuelType.petrol;
  Transmission _transmission = Transmission.automatic;
  CarCondition _condition = CarCondition.used;
  CarStatus _status = CarStatus.available;
  bool _featured = false;

  List<String> _savedPhotos = [];
  final List<_NewPhoto> _newPhotos = [];

  late final String _carId;
  Car? _original;
  bool _saving = false;

  bool get _isNew => widget.carId == null;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(repositoriesProvider).cars;
    _carId = widget.carId ?? repository.newCarId();
    final car = _isNew ? null : ref.read(carProvider(_carId)).value;
    if (car != null) _fill(car);
  }

  void _fill(Car car) {
    _original = car;
    _make.text = car.make;
    _model.text = car.model;
    _year.text = '${car.year}';
    _price.text = '${car.price}';
    _mileage.text = '${car.mileageKm}';
    _color.text = car.color;
    _description.text = car.description;
    _bodyType = car.bodyType;
    _fuelType = car.fuelType;
    _transmission = car.transmission;
    _condition = car.condition;
    _status = car.status;
    _featured = car.featured;
    _savedPhotos = [...car.imageUrls];
  }

  @override
  void dispose() {
    for (final controller in [
      _make,
      _model,
      _year,
      _price,
      _mileage,
      _color,
      _description,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      final files = await ImagePicker().pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
      );
      final photos = [
        for (final file in files)
          _NewPhoto(file.name, await file.readAsBytes()),
      ];
      if (mounted) setState(() => _newPhotos.addAll(photos));
    } on PlatformException {
      if (mounted) {
        showMessage(context, 'Could not open your photos. Check permissions.');
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repository = ref.read(repositoriesProvider).cars;
    final ok = await runGuarded(context, () async {
      final uploaded = [
        for (final photo in _newPhotos)
          await repository.uploadPhoto(
            carId: _carId,
            bytes: photo.bytes,
            fileName: photo.name,
          ),
      ];
      await repository.saveCar(
        Car(
          id: _carId,
          make: _make.text.trim(),
          model: _model.text.trim(),
          year: parseInt(_year.text),
          price: parseInt(_price.text),
          mileageKm: parseInt(_mileage.text),
          bodyType: _bodyType,
          fuelType: _fuelType,
          transmission: _transmission,
          condition: _condition,
          color: _color.text.trim(),
          description: _description.text.trim(),
          imageUrls: [..._savedPhotos, ...uploaded],
          status: _status,
          featured: _featured,
          createdAt: _original?.createdAt,
        ),
      );
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) return;
    if (_isNew) {
      // Straight to the label so it can be printed and put on the car.
      context.pushReplacement('/admin/cars/$_carId/qr');
    } else {
      showMessage(context, 'Car updated');
      context.pop();
    }
  }

  Future<void> _delete() async {
    final yes = await confirmAction(
      context,
      title: 'Delete this car?',
      message:
          'It will be removed from the app and its QR code will stop working. '
          'To keep a record, mark it as sold instead.',
      confirmLabel: 'Delete',
    );
    if (!yes || !mounted) return;
    final ok = await runGuarded(
      context,
      () => ref.read(repositoriesProvider).cars.deleteCar(_carId),
    );
    if (ok && mounted) context.go('/admin/cars');
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> options,
    required String Function(T) text,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(text(option))),
      ],
      onChanged: (next) {
        if (next != null) setState(() => onChanged(next));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Opened by link before the stock list arrived: fill in once it does.
    if (!_isNew && _original == null) {
      final car = ref.watch(carProvider(_carId));
      if (car.value != null) {
        _fill(car.value!);
      } else {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit car')),
          body: AsyncView<Car?>(
            value: car,
            data: (_) => const EmptyState(
              icon: Icons.no_crash_outlined,
              title: 'This car no longer exists',
            ),
          ),
        );
      }
    }

    const gap = SizedBox(height: 14);
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Add a car' : 'Edit car'),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: 'Delete car',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PhotoStrip(
              saved: _savedPhotos,
              added: _newPhotos,
              onAdd: _pickPhotos,
              onRemoveSaved: (url) => setState(() => _savedPhotos.remove(url)),
              onRemoveAdded: (photo) =>
                  setState(() => _newPhotos.remove(photo)),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _make,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => Validators.required(value, 'Make'),
                    decoration: const InputDecoration(labelText: 'Make'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _model,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => Validators.required(value, 'Model'),
                    decoration: const InputDecoration(labelText: 'Model'),
                  ),
                ),
              ],
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    validator: Validators.year,
                    decoration: const InputDecoration(labelText: 'Year'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _color,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => Validators.required(value, 'Colour'),
                    decoration: const InputDecoration(labelText: 'Colour'),
                  ),
                ),
              ],
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    validator: (value) =>
                        Validators.positiveInt(value, 'Price'),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '${AppConfig.currencySymbol} ',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mileage,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    validator: (value) =>
                        Validators.nonNegativeInt(value, 'Mileage'),
                    decoration: const InputDecoration(
                      labelText: 'Mileage',
                      suffixText: 'km',
                    ),
                  ),
                ),
              ],
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: _dropdown<BodyType>(
                    label: 'Body type',
                    value: _bodyType,
                    options: BodyType.values,
                    text: (value) => value.label,
                    onChanged: (value) => _bodyType = value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown<FuelType>(
                    label: 'Fuel',
                    value: _fuelType,
                    options: FuelType.values,
                    text: (value) => value.label,
                    onChanged: (value) => _fuelType = value,
                  ),
                ),
              ],
            ),
            gap,
            Row(
              children: [
                Expanded(
                  child: _dropdown<Transmission>(
                    label: 'Transmission',
                    value: _transmission,
                    options: Transmission.values,
                    text: (value) => value.label,
                    onChanged: (value) => _transmission = value,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown<CarCondition>(
                    label: 'Condition',
                    value: _condition,
                    options: CarCondition.values,
                    text: (value) => value.label,
                    onChanged: (value) => _condition = value,
                  ),
                ),
              ],
            ),
            gap,
            _dropdown<CarStatus>(
              label: 'Status',
              value: _status,
              options: CarStatus.values,
              text: (value) => value.label,
              onChanged: (value) => _status = value,
            ),
            gap,
            TextFormField(
              controller: _description,
              maxLines: 5,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Feature on the home screen'),
              value: _featured,
              onChanged: (value) => setState(() => _featured = value),
            ),
            const SizedBox(height: 12),
            LoadingButton(
              label: _isNew ? 'Save and create QR code' : 'Save changes',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.saved,
    required this.added,
    required this.onAdd,
    required this.onRemoveSaved,
    required this.onRemoveAdded,
  });

  final List<String> saved;
  final List<_NewPhoto> added;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemoveSaved;
  final ValueChanged<_NewPhoto> onRemoveAdded;

  Widget _thumb({required Widget image, required VoidCallback onRemove}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 128, height: 96, child: image),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            tooltip: 'Remove photo',
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            icon: const Icon(Icons.close),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final url in saved)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _thumb(
                image: CarImage(url: url, iconSize: 28),
                onRemove: () => onRemoveSaved(url),
              ),
            ),
          for (final photo in added)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _thumb(
                image: Image.memory(photo.bytes, fit: BoxFit.cover),
                onRemove: () => onRemoveAdded(photo),
              ),
            ),
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onAdd,
              child: SizedBox(
                width: 128,
                height: 96,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: scheme.primary),
                    const SizedBox(height: 6),
                    const Text('Add photos'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

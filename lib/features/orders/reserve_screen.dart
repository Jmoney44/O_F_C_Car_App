import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../models/car.dart';
import '../../models/car_order.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';
import '../cars/car_details_screen.dart';

class ReserveScreen extends ConsumerStatefulWidget {
  const ReserveScreen({super.key, required this.carId});

  final String carId;

  @override
  ConsumerState<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends ConsumerState<ReserveScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _phone = TextEditingController(
    text: ref.read(currentUserProvider).value?.phone ?? '',
  );
  final _address = TextEditingController();
  final _note = TextEditingController();
  Fulfilment _fulfilment = Fulfilment.pickup;
  PaymentMethod _payment = PaymentMethod.bankTransfer;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit(Car car) async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final offer = ref.read(acceptedOfferProvider(car.id));
    final order = CarOrder(
      id: '',
      code: CarOrder.newCode(),
      carId: car.id,
      carTitle: car.title,
      carImage: car.coverImage,
      price: offer?.amount ?? car.price,
      offerId: offer?.id,
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      phone: _phone.text.trim(),
      fulfilment: _fulfilment,
      paymentMethod: _payment,
      address: _fulfilment == Fulfilment.delivery ? _address.text.trim() : '',
      note: _note.text.trim(),
    );
    setState(() => _loading = true);
    final ok = await runGuarded(
      context,
      () => ref.read(repositoriesProvider).orders.createOrder(order),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, size: 48),
        title: const Text('Reservation requested'),
        content: Text(
          'Your reference is ${order.code}. The showroom will contact you on '
          '${order.phone} to confirm and arrange payment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View my orders'),
          ),
        ],
      ),
    );
    if (mounted) context.pushReplacement('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final car = ref.watch(carProvider(widget.carId));
    final offer = ref.watch(acceptedOfferProvider(widget.carId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reserve this car')),
      body: AsyncView<Car?>(
        value: car,
        data: (car) {
          if (car == null || !car.isAvailable) {
            return const EmptyState(
              icon: Icons.no_crash_outlined,
              title: 'This car is no longer available',
            );
          }
          final price = offer?.amount ?? car.price;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CarListTile(
                  imageUrl: car.coverImage,
                  title: car.title,
                  subtitle: offer == null
                      ? 'Price ${formatMoney(price)}'
                      : 'Agreed price ${formatMoney(price)} (listed at ${formatMoney(car.price)})',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number to reach you',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'How would you like to get the car?',
                  style: theme.textTheme.titleSmall,
                ),
                RadioGroup<Fulfilment>(
                  groupValue: _fulfilment,
                  onChanged: (value) => setState(() => _fulfilment = value!),
                  child: Column(
                    children: [
                      for (final option in Fulfilment.values)
                        RadioListTile<Fulfilment>(
                          value: option,
                          title: Text(option.label),
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
                if (_fulfilment == Fulfilment.delivery) ...[
                  TextFormField(
                    controller: _address,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        Validators.required(value, 'Delivery address'),
                    decoration: const InputDecoration(
                      labelText: 'Delivery address',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                Text('How will you pay?', style: theme.textTheme.titleSmall),
                RadioGroup<PaymentMethod>(
                  groupValue: _payment,
                  onChanged: (value) => setState(() => _payment = value!),
                  child: Column(
                    children: [
                      for (final option in PaymentMethod.values)
                        RadioListTile<PaymentMethod>(
                          value: option,
                          title: Text(option.label),
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _note,
                  maxLines: 2,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note for the showroom (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                LoadingButton(
                  label: 'Request reservation · ${formatMoney(price)}',
                  loading: _loading,
                  onPressed: () => _submit(car),
                ),
                const SizedBox(height: 12),
                Text(
                  'No payment is taken in the app. The showroom confirms your '
                  'reservation and arranges payment with you directly.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

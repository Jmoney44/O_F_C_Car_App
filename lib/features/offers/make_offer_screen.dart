import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config.dart';
import '../../core/formatters.dart';
import '../../core/validators.dart';
import '../../models/car.dart';
import '../../models/offer.dart';
import '../../providers.dart';
import '../../widgets/car_widgets.dart';
import '../../widgets/common.dart';

class MakeOfferScreen extends ConsumerStatefulWidget {
  const MakeOfferScreen({super.key, required this.carId});

  final String carId;

  @override
  ConsumerState<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends ConsumerState<MakeOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _message = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amount.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit(Car car) async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _loading = true);
    final ok = await runGuarded(
      context,
      () => ref
          .read(repositoriesProvider)
          .offers
          .createOffer(
            Offer(
              id: '',
              carId: car.id,
              carTitle: car.title,
              carImage: car.coverImage,
              listPrice: car.price,
              amount: parseInt(_amount.text),
              userId: user.uid,
              userName: user.name,
              userPhone: user.phone,
              message: _message.text.trim(),
            ),
          ),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      showMessage(context, 'Offer sent. We will reply shortly.');
      context.pushReplacement('/offers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = ref.watch(carProvider(widget.carId));
    return Scaffold(
      appBar: AppBar(title: const Text('Make an offer')),
      body: AsyncView<Car?>(
        value: car,
        data: (car) {
          if (car == null || !car.isAvailable) {
            return const EmptyState(
              icon: Icons.no_crash_outlined,
              title: 'This car is no longer available',
            );
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CarListTile(
                  imageUrl: car.coverImage,
                  title: car.title,
                  subtitle: 'Listed at ${formatMoney(car.price)}',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Your offer',
                    prefixText: '${AppConfig.currencySymbol} ',
                  ),
                  validator: (value) {
                    final invalid = Validators.positiveInt(value, 'Your offer');
                    if (invalid != null) return invalid;
                    return parseInt(value!) >= car.price
                        ? 'That is the list price or more. Reserve the car instead.'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _message,
                  maxLines: 3,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                LoadingButton(
                  label: 'Send offer',
                  loading: _loading,
                  onPressed: () => _submit(car),
                ),
                const SizedBox(height: 12),
                Text(
                  'The showroom reviews every offer. If yours is accepted you '
                  'can reserve the car at that price.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

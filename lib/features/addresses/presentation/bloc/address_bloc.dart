import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/saved_address.dart';
import '../../domain/repositories/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _repository;

  StreamSubscription<List<SavedAddress>>? _subscription;
  String? _userId;

  AddressBloc(this._repository) : super(const AddressState()) {
    on<AddressesStarted>(_onStarted);
    on<AddressesStopped>(_onStopped);
    on<AddressesUpdated>(
      (event, emit) => emit(AddressState(addresses: event.addresses)),
    );
    on<AddressesLoadFailed>(
      (event, emit) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load your addresses.',
        ),
      ),
    );
    on<AddressSaved>(_onSaved);
    on<AddressDeleted>(_onDeleted);
    on<AddressDefaultSet>(_onDefaultSet);
  }

  Future<void> _onStarted(
    AddressesStarted event,
    Emitter<AddressState> emit,
  ) async {
    await _subscription?.cancel();
    _userId = event.userId;

    emit(const AddressState(isLoading: true));

    _subscription = _repository
        .watchAddresses(event.userId)
        .listen(
          (addresses) => add(AddressesUpdated(addresses)),
          onError: (_) => add(const AddressesLoadFailed()),
        );
  }

  Future<void> _onStopped(
    AddressesStopped event,
    Emitter<AddressState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = null;
    _userId = null;
    emit(const AddressState());
  }

  Future<void> _onSaved(AddressSaved event, Emitter<AddressState> emit) async {
    final userId = _userId;
    if (userId == null) return;

    var address = event.address;

    // There must always be a default: if no OTHER address is the default,
    // this one becomes it (e.g. the very first address).
    final anotherIsDefault = state.addresses.any(
      (a) => a.isDefault && a.id != address.id,
    );
    if (!anotherIsDefault) {
      address = address.copyWith(isDefault: true);
    }

    await _run(emit, () => _repository.saveAddress(userId, address));
  }

  Future<void> _onDeleted(
    AddressDeleted event,
    Emitter<AddressState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;

    await _run(emit, () => _repository.deleteAddress(userId, event.addressId));
  }

  Future<void> _onDefaultSet(
    AddressDefaultSet event,
    Emitter<AddressState> emit,
  ) async {
    final userId = _userId;
    if (userId == null) return;

    await _run(emit, () => _repository.setDefault(userId, event.addressId));
  }

  Future<void> _run(
    Emitter<AddressState> emit,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      // No emit needed: the Firestore stream sends the updated list.
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage:
              'Could not update your addresses. Check your connection.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import '../models/journal_entry.dart';
import 'api_provider.dart';

final accountsProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/accounts');
  return (response as List).map((j) => Account.fromJson(j as Map<String, dynamic>)).toList();
});

final createAccountProvider = FutureProvider.autoDispose.family<Account, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/accounts', data);
  return Account.fromJson(response);
});

final updateAccountProvider = FutureProvider.autoDispose.family<Account, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final id = data['id'];
  final updateData = Map<String, dynamic>.from(data)..remove('id');
  final response = await api.put('/api/accounts/$id', updateData);
  return Account.fromJson(response);
});

final deleteAccountProvider = FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/api/accounts/$id');
});

final accountByIdProvider = FutureProvider.autoDispose.family<Account, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/accounts/$id');
  return Account.fromJson(response);
});

final journalEntriesProvider = FutureProvider.autoDispose.family<List<JournalEntry>, Map<String, dynamic>>((ref, filters) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/journal-entries');
  return (response as List).map((j) => JournalEntry.fromJson(j as Map<String, dynamic>)).toList();
});

final journalEntryDetailsProvider = FutureProvider.autoDispose.family<JournalEntry, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/journal-entries/$id');
  return JournalEntry.fromJson(response);
});

final createJournalEntryProvider = FutureProvider.autoDispose.family<JournalEntry, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/journal-entries', data);
  return JournalEntry.fromJson(response);
});

final updateJournalEntryProvider = FutureProvider.autoDispose.family<JournalEntry, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final id = data['id'];
  final updateData = Map<String, dynamic>.from(data)..remove('id');
  final response = await api.put('/api/journal-entries/$id', updateData);
  return JournalEntry.fromJson(response);
});

final deleteJournalEntryProvider = FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/api/journal-entries/$id');
});

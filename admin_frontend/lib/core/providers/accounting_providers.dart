import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import '../models/journal_entry.dart';

final accountsProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/accounts');
  return (response as List).map((j) => Account.fromJson(j as Map<String, dynamic>)).toList();
});

final createAccountProvider = FutureProvider.autoDispose.family<Account, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/accounts', body: data);
  return Account.fromJson(response);
});

final updateAccountProvider = FutureProvider.autoDispose.family<Account, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final id = data['id'];
  final updateData = Map<String, dynamic>.from(data)..remove('id');
  final response = await api.put('/accounts/$id', body: updateData);
  return Account.fromJson(response);
});

final deleteAccountProvider = FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/accounts/$id');
});

final journalEntriesProvider = FutureProvider.autoDispose.family<List<JournalEntry>, Map<String, dynamic>>((ref, filters) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/journal-entries', queryParams: filters);
  return (response as List).map((j) => JournalEntry.fromJson(j as Map<String, dynamic>)).toList();
});

final journalEntryDetailsProvider = FutureProvider.autoDispose.family<JournalEntry, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/journal-entries/$id');
  return JournalEntry.fromJson(response);
});

final createJournalEntryProvider = FutureProvider.autoDispose.family<JournalEntry, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/journal-entries', body: data);
  return JournalEntry.fromJson(response);
});

final updateJournalEntryProvider = FutureProvider.autoDispose.family<JournalEntry, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final id = data['id'];
  final updateData = Map<String, dynamic>.from(data)..remove('id');
  final response = await api.put('/journal-entries/$id', body: updateData);
  return JournalEntry.fromJson(response);
});

final deleteJournalEntryProvider = FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/journal-entries/$id');
});

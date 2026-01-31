import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sentence.dart';
import '../services/supabase_service.dart';

final sentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  return await SupabaseService.getSentences();
});

final sentenceByIdProvider = FutureProvider.family<Sentence?, String>((ref, id) async {
  return await SupabaseService.getSentenceById(id);
});

final studySentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  return await SupabaseService.getSentences();
});

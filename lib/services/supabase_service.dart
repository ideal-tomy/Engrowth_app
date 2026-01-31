import '../config/supabase_config.dart';
import '../models/word.dart';
import '../models/sentence.dart';
import '../models/user_progress.dart';

class SupabaseService {
  // 単語関連
  static Future<List<Word>> getWords({
    String? searchQuery,
    String? wordGroup,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.client
          .from('words')
          .select();
      
      if (wordGroup != null && wordGroup.isNotEmpty) {
        query = query.eq('word_group', wordGroup);
      }
      
      query = query.order('word_number');
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      List<Word> words = (response as List)
          .map((json) => Word.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // 検索クエリがある場合は、クライアント側でフィルタリング
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        words = words.where((word) {
          return word.word.toLowerCase().contains(lowerQuery) ||
                 word.meaning.toLowerCase().contains(lowerQuery);
        }).toList();
      }
      
      return words;
    } catch (e) {
      print('Error fetching words: $e');
      return [];
    }
  }
  
  static Future<Word?> getWordById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from('words')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return Word.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
  
  // 例文関連
  static Future<List<Sentence>> getSentences({
    int? difficulty,
    int? limit,
  }) async {
    try {
      dynamic query = SupabaseConfig.client
          .from('sentences')
          .select();
      
      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }
      
      // created_atが存在する場合のみソート
      try {
        query = query.order('created_at', ascending: false);
      } catch (e) {
        // created_atカラムが存在しない場合は、groupでソート
        try {
          query = query.order('group', ascending: true);
        } catch (e2) {
          // ソートなしで続行
        }
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      return (response as List)
          .map((json) => Sentence.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching sentences: $e');
      return [];
    }
  }
  
  static Future<Sentence?> getSentenceById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from('sentences')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return Sentence.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
  
  // 進捗関連
  static Future<List<UserProgress>> getUserProgress(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .order('last_studied_at', ascending: false);
      
      return (response as List)
          .map((json) => UserProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user progress: $e');
      return [];
    }
  }
  
  static Future<void> updateProgress({
    required String userId,
    required String sentenceId,
    required bool isMastered,
  }) async {
    try {
      await SupabaseConfig.client
          .from('user_progress')
          .upsert({
            'user_id': userId,
            'sentence_id': sentenceId,
            'is_mastered': isMastered,
            'last_studied_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,sentence_id');
    } catch (e) {
      print('Error updating progress: $e');
      rethrow;
    }
  }
  
  static Future<int> getMasteredCount(String userId) async {
    try {
      // カウントを取得するために、データを取得して長さを返す
      final response = await SupabaseConfig.client
          .from('user_progress')
          .select('id')
          .eq('user_id', userId)
          .eq('is_mastered', true);
      
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}

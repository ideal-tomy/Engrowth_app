# UX評価イベントとKPI設計

## 主要指標

| 指標 | 算出方法 | 目標 |
|------|----------|------|
| session_start_rate | ホーム表示中の session_start / ホーム表示回数 | 週次改善 |
| quick30_completion_rate | quick30_complete / session_start(session_mode=quick30) | 80%以上 |
| focus3_completion_rate | focus3_complete / session_start(session_mode=focus3) | 70%以上 |
| voice_attempt_rate | voice_attempt / 表示された問題数 | 60%以上 |
| day1_retention | 初回アクセス翌日の再訪問率 | 40%以上 |
| day7_retention | 初回アクセス7日後の再訪問率 | 20%以上 |

## 画面別イベント

| イベント | 発火タイミング |
|----------|----------------|
| session_start | Quick30/Focus3ボタンタップ時（session_mode付与） |
| quick30_complete | Quick30セッション完了時 |
| focus3_complete | Focus3セッション完了時 |
| voice_attempt | 録音ボタンで録音開始時 |
| audio_compare_played | 聴き直しボタン再生時 |
| hint_auto_shown | ThinkingTimerによるヒント自動表示時 |
| resume_card_tap | 再開カードタップ時（source: resume | recommended） |
| story_resume_tap | 3分ストーリー「続きから」カードタップ時 |
| next_task_accepted | セッション完了ダイアログで「もう1セット続ける」タップ時 |

## 改善サイクル（週次レビュー）

1. **月曜朝**: 前週KPIをダッシュボードで確認
2. **指標の検証**: session_start_rate が低下していないか、quick30/focus3_completion_rate の推移
3. **離脱ポイント特定**: 完了率が低い場合、ヒートマップやイベント順序で停滞箇所を特定
4. **施策決定**: 離脱箇所に応じたUI微調整・導線変更を優先
5. **A/Bテスト**: 大きな変更は段階ロールアウト

## 目標の置き方

- **Phase1（1〜2週）**: session_start_rate と completion_rate のベースライン計測
- **Phase2（3〜4週）**: voice_attempt_rate の改善（音声導線の強化）
- **Phase3（5週以降）**: day1/day7_retention の追跡と習慣化施策の効果検証

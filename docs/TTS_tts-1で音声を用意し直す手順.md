# tts-1 で音声を用意し直す手順（やることだけ）

**目的**: tts-1 で音声を一から揃え直して、アプリで再生できるようにする。

---

## やること 3 つ

### 1. コードが tts-1 になっているか確認（変えてなければスキップでOK）

次の **1 か所** だけ見ればよい（prefill は Edge を呼ぶので Edge のモデルに合わせる）。

| 場所 | 確認する値 |
|------|-------------|
| **Edge** | `supabase/functions/tts_synthesize/index.ts` の 7 行目あたりで `const MODEL = "tts-1";` になっていること |

アプリ側は `lib/services/tts_cache_key_util.dart` の `kTtsModel = 'tts-1'`。  
いじってなければこのままでよい。

---

### 2. Edge をデプロイする

モデルを変えた場合や、まだデプロイしていない場合だけ。

```bash
supabase functions deploy tts_synthesize
```

（Supabase のプロジェクトが紐づいていること。未ログインなら `supabase login`）

---

### 3. prefill を実行する

**ここが本番。** DB に tts-1 のキーで音声を入れていく。

```bash
cd プロジェクトのフォルダ（engrowth_app）
dart run scripts/prefill_tts_assets.dart
```

- 時間がかかる（数千件あると 30 分〜数時間）。
- **429 エラー（You exceeded your current quota）** が出たら、**OpenAI の請求・クレジット** を確認する。  
  https://platform.openai.com/account/billing  
  クレジットが切れていると prefill は進まない。
- 途中で止めたくなったら `Ctrl+C`。  
  もう一度実行すると、**すでに DB にある分はスキップ**される（冪等）。

**ゆっくり再生（0.6）も使うなら**:

```bash
dart run scripts/prefill_tts_assets.dart --include-slow
```

---

## うまくいったか確認する

```bash
dart run scripts/check_tts_prefill_status.dart --limit 10
```

「tts_assets に存在: 10」と出れば、その 10 件は tts-1 で入っている。  
アプリでその会話を再生して、音が鳴れば OK。

---

## まとめ（一言）

1. **Edge が `MODEL = "tts-1"` か確認**  
2. **必要なら `supabase functions deploy tts_synthesize`**  
3. **`dart run scripts/prefill_tts_assets.dart` を回す**（429 なら OpenAI の請求を直す）

これだけで、tts-1 の音声が DB に入り、アプリで再生できる状態になる。

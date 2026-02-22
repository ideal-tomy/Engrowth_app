# 3分ストーリー カテゴリ別表示画像プロンプト

各カテゴリ用に、AI画像生成で使用するプロンプトです。
横160px×縦100px程度のカード用サムネイルに適した構図を想定しています。

---

## 1. 挨拶
```
Two business professionals in modern office attire shaking hands and smiling warmly. Professional greeting scene, bright office environment, neutral background. Flat illustration style, warm and welcoming mood. No text.
```

---

## 2. 自己紹介
```
Person giving a confident self-introduction in front of a projector screen, professional networking event. Modern office or conference room, diverse audience. Clean flat illustration, business casual attire.
```

---

## 3. 道案内
```
Two people on a street corner, one holding an open map, the other pointing toward a direction. Urban scenery with landmarks in background. Friendly tourist-local interaction. Flat illustration style.
```

---

## 4. 飛行機
```
Passenger at airport check-in counter speaking with a flight attendant. Airport interior, luggage and boarding pass. Professional and calm atmosphere. Flat illustration, travel theme.
```

---

## 5. ホテル
```
Guest and hotel staff at front desk, welcoming smile. Hotel lobby with elegant interior. Check-in scene. Warm lighting, flat illustration style.
```

---

## 6. カフェ&レストラン
```
Customer and waiter at a stylish restaurant table, menu in hand. Cozy cafe or restaurant interior. Ordering scene. Warm ambient lighting. Flat illustration.
```

---

## 7. ショッピング
```
Customer in a boutique fitting room area, holding clothing, store assistant nearby. Fashion retail store interior. Shopping experience. Clean flat illustration style.
```

---

## 8. 交通機関
```
Traveler at train or bus ticket counter, asking station staff. Public transport station interior. Helpful interaction. Flat illustration, transit theme.
```

---

## 9. ビジネスメール
```
Business person typing on laptop with focused expression, email composition scene. Modern office desk, professional setting. Flat illustration, work productivity theme.
```

---

## 10. プレゼンテーション①
```
Presenter in front of projector screen with charts and graphs, confident pose. Audience in background. Conference room setting. Flat illustration, professional presentation.
```

---

## 11. プレゼンテーション②
```
Presenter answering question from audience with smile. Q&A session, engagement scene. Modern meeting room. Flat illustration style.
```

---

## 12. 銀行口座開設
```
Customer and bank teller at counter with documents. Bank interior, professional and trustworthy atmosphere. Flat illustration, financial service theme.
```

---

## 13. 郵便局・宅急便
```
Customer handing a package to postal staff at counter. Post office interior, parcels and scales. Shipping scene. Flat illustration.
```

---

## 14. 病院
```
Patient and doctor in consultation, medical setting. Calm clinic or hospital room. Professional and caring atmosphere. Flat illustration, healthcare theme.
```

---

## 15. 学習プラン (カスタム)
```
Consultant and student discussing at a desk with laptop. Learning goal setting, coaching session. Modern office or online meeting. Flat illustration, educational theme.
```

---

## 16. その他
```
People having a friendly conversation in a neutral indoor setting. Casual meeting scene, soft colors. Flat illustration style, versatile background.
```

---

## 使い方

1. 上記プロンプトを AI 画像生成サービス（DALL-E、Midjourney、Stable Diffusion など）に入力
2. 生成した画像をアスペクト比 16:10 程度にトリミング
3. Supabase Storage にアップロードするか、`assets/images/` に配置
4. カテゴリ単位で共通サムネイルとして利用

---

## 共通指定（全プロンプトに追加可能）

- **スタイル**: Flat illustration, soft colors, no harsh shadows
- **用途**: Mobile app card thumbnail, 160x100px display
- **禁止**: Text, watermarks, realistic photos

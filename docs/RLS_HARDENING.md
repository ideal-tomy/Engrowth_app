# RLS 厳格化

## 概要

ユーザーデータの分離を強化するため、Row Level Security の緩いポリシー（`USING (true)` 等）を撤廃し、`auth.uid() = user_id` または担当者関係テーブル（`consultant_assignments`）経由のアクセスのみに統一している。

## 適用順

1. **database_phase_b_rls_hardening.sql**
   - `voice_submissions`: 担当コンサル・管理者のみ閲覧・更新（全件不可）
   - `voice_feedbacks`: 提出者本人・担当コンサル・管理者のみ閲覧
   - `consultant_client_permissions`: 管理者のみ全操作
   - `user_sessions`: 担当コンサル・管理者閲覧追加

2. **database_rls_hardening_phase_c.sql**
   - `voice_feedbacks`: INSERT を担当コンサル・管理者に制限
   - `analytics_events`: INSERT を自 user_id または null に制限
   - `conversation_learning_events`: SELECT を本人・担当コンサル・管理者に制限（全件不可廃止）

## 事前条件

- `consultant_assignments` テーブルが存在すること
- 管理者には Supabase Dashboard の JWT Templates で `app_role=admin` を設定すること（必要に応じて）

## 実行

Supabase SQL Editor で上記マイグレーションを順に実行するか、`supabase db push` で一括適用する。

# Claude Code Skills 開発ワークフロー

Matt Pocock氏の[Claude Code Skills](https://github.com/mattpocock/skills)をベースに、
日本語に翻訳・カスタマイズしたスキル群の使い方ガイド。

## スキル一覧

| スキル | 用途 |
| ---- | ---- |
| `/grill-me` | プラン・設計について容赦なくインタビューし、認識を合わせる |
| `/write-prd` | インタビュー結果をPRD（仕様書）に変換する |
| `/prd-to-issues` | PRDを垂直スライスで独立着手可能なタスクに分解する |
| `/tdd` | Red-Green-Refactorループによるテスト駆動開発 |
| `/improve-codebase-architecture` | コードベースの構造改善を提案し、RFCを作成する |

## 基本フロー

```text
スプリントタスク（Notion等）
  ↓
/grill-me（要件の深掘り）
  ↓ ※同じ会話で続ける
/write-prd（仕様書の作成）
  ↓
/prd-to-issues（タスク分解）
  ↓ タスクごとに実行
/tdd（テスト駆動で実装）

── 定期メンテナンス ──
/improve-codebase-architecture
```

## 各スキルの使い方

### 1. /grill-me - 要件の深掘り

チケットを受け取ったら、まずこれを実行する。
Claudeが設計上の曖昧な点を次々と質問してくるので、答えていく。
**実装に入る前の最重要ステップ。**

```text
このチケットの内容について grill me してほしい
[チケットの内容をペースト]
```

### 2. /write-prd - 仕様書の作成

grill-meで共通理解ができた**同じ会話の中で**実行する。
grill-meの対話内容がコンテキストに残っているので、そのまま仕様書に変換される。

```text
/write-prd
```

保存先はプロジェクトのルール（CLAUDE.md等）に従う。記載がなければ確認される。

### 3. /prd-to-issues - タスク分解

PRDを「垂直スライス（トレーサーバレット）」方式でタスクに分解する。
各タスクが全レイヤーを薄く貫通する形で切られるため、1つ完了するだけでデモ可能になる。

```text
/prd-to-issues
```

出力されたタスクをNotionのチケット等に反映する。

### 4. /tdd - テスト駆動開発

分解されたタスクごとに実行する。
Red（失敗テスト）→ Green（最小実装）→ Refactor のサイクルで進む。

```text
/tdd
[タスクの内容]
```

### 5. /improve-codebase-architecture - 定期メンテナンス

スプリントの流れとは独立して、コードベースの品質が気になったときに使う。
浅いモジュールを深化させる提案をRFCとして作成してくれる。

```text
/improve-codebase-architecture
```

## タスク規模に応じた使い分け

全スキルを毎回使う必要はない。タスクの規模に応じて組み合わせを変える。

| 規模 | 推奨フロー |
| ---- | ---- |
| 大（新機能・大規模改修） | grill-me → write-prd → prd-to-issues → tdd |
| 中（既存機能の拡張） | grill-me → tdd |
| 小（バグ修正・軽微な変更） | tdd のみ |
| メンテナンス | improve-codebase-architecture |

## 補足

- **1→2は同じ会話で続ける**のが効果的（grill-meの文脈がそのまま使える）
- **improve-codebase-architectureは週1やスプリント終わり**など、区切りのタイミングで実行するとよい
- スキルの実体は `claude/skills/` 配下にあり、`.gitignore` でGit管理対象外

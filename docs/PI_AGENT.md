# pi agent の方針

個人契約の Claude API で使う pi を、Claude Code より最小の機能で、トークンを抑えつつモデルの精度を最大限に出せる構成にして、コスパよく自由に開発するための方針。

実装前の方針で、各項目の動作は Phase ごとに検証する。

## 原則

- **毎回送る内容を最小にする**: モデルに常に渡すのは、pi 本体のシステムプロンプト、標準 4 ツール（read / bash / edit / write）、`AGENTS.md`、スキルの説明を基本とする。足したものは下の表の「追加トークン」で管理する
- **機能はモデルに見えない形で足す**: コマンド・イベントフック・TUI はツール定義を増やさないのでトークン 0。ツールにするのは本当に必要なものだけ
- **コンテキストを汚さずに精度を上げる**: 寄り道・自己レビューはセッションツリーの別ブランチかサブエージェントで行い、メインには結論だけを戻す
- **キャッシュを壊さない**: ツールやシステムプロンプトを途中で変えない（変えるとプロバイダによってはキャッシュが効かなくなる）
- **他人のパッケージは `pi install` しない**: 拡張は pi と同じ権限で動く。必要な `.ts` を読んでから自分の `extensions/` に移す

## 最低限の機能

| 用途 | 実現方法 | 追加トークン |
| ---- | ---- | ---- |
| grep・sed・git・gh | 標準の bash。grep / find / ls ツールは足さない | 0 |
| main への commit 禁止・deny | 拡張がツール実行前に既存の `agents/hooks/*.sh` と Claude の deny を読んでブロックする。正本は共有 | 0 |
| 完了通知 | 実行完了のイベントで terminal-notifier と通知音を呼ぶ | 0 |
| モデル切り替え | `enabledModels` と Ctrl+P。`modelThinkingLevels` でモデル別の thinking を設定 | 0 |
| スキル | `~/.agents/skills` を共有。業務用は `pi config` で無効にする | 減る |
| サブエージェント | 公式の例 `examples/extensions/subagent/` を最小限にして入れる。調査役は Sonnet か Haiku | ツール 1 個分 |
| ユーザーへの質問 | ツールにしない。直前の回答の質問を入力フォームにする `/answer` 方式 | 0 |
| Web 取得 | スキルと CLI。検索は必要になったら足す | 小 |
| ブラウザ操作 | Chrome DevTools Protocol を直接操作するスキルを pi に書かせる | 小 |
| MCP | 入れない。必要になったら codemode / tool_search で定義を常に送らない形にする | 0 |

## Claude Code にない機能

- **セッションツリー**: 寄り道は別ブランチで行い、戻るときは要約だけ持ち帰る（`/tree`、空のエディタで Esc 2 回）
- **別ブランチでの `/review`**: セルフレビューを新しいコンテキストで行い、修正だけをメインに戻す（agent-stuff の `review.ts`）
- **プリセット**: `/preset` でモデル・thinking・ツールをまとめて切り替える（公式例 `preset.ts`）
- **コストとキャッシュの可視化**: `showCacheMissNotices: true` と、モデル別のトークン・コストを集計する `session-breakdown.ts`
- **pi に拡張を書かせる**: docs と examples が同梱されているので、書かせて `/reload` で試す

## TUI のリッチ化（トークン 0）

| 対象 | 内容 | 参考 |
| ---- | ---- | ---- |
| フッター | 今の statusline（ディレクトリ・ブランチ・時刻・モデル・ctx%）を移植。5h% の代わりにセッションのコストとキャッシュヒット率 | `custom-footer.ts` |
| テーマ | まず `system`。物足りなければ WezTerm の背景 `#2D353B` に合わせた Everforest 系の自作 | pi 同梱の `docs/themes.md` |
| ツールの表示 | bash・edit を短く表示し、diff を色分け。モデルに渡す内容は変わらない | `built-in-tool-renderer.ts` |
| エディタ周り | 枠にステータス、上部にサブエージェントの進み具合や git の状態 | `border-status-editor.ts`、`widget-placement.ts` |
| 作業中の表示 | スピナー、タイトルバー | `working-indicator.ts`、`titlebar-spinner.ts` |
| 変更ファイル | 一覧から diff・Finder・Quick Look を開く | agent-stuff の `files.ts` |
| ペイン分割 | 分岐したセッションを WezTerm の右ペインで開く（Ghostty 用を書き換える） | agent-stuff の `split-fork.ts` |

参考: 表中の `*.ts` のうち公式の例は pi 同梱の `examples/extensions/`、agent-stuff 側は [mitsuhiko/agent-stuff](https://github.com/mitsuhiko/agent-stuff)。

## 管理方法

- 設定は `agents/pi/`（`extensions/`、`themes/`、`prompts/`、`keybindings.json`）に置き、`symlinks.txt` にディレクトリごと追加する
- `~/.pi/agent/settings.json` を git で管理するかは未定。管理すると pi が書き込む `lastChangelogVersion` や Ctrl+S で保存したデフォルトモデルが差分に出る

## 進め方

1. **Phase 1**: hook と deny を共有する拡張、完了通知、モデルと thinking の設定、業務用スキルの無効化、フッター
2. **Phase 2**: 別ブランチでの `/review`、`/answer`、サブエージェント、コスト集計、プリセット
3. **Phase 3**: テーマ、ツールの表示、ウィジェット、ブラウザ操作スキル

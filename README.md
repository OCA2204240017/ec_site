# ec_site

`ec_site` は Rails で作られたシンプルな電子書籍販売のサンプルアプリケーションです。
このリポジトリはローカル開発向けに組まれており、管理者とユーザの基本的な EC フローを備えています。

## 主要機能

- 管理者（Admin）
	- 管理者ログイン（環境変数から作成される初期管理者アカウント）
	- 書籍（Book）の CRUD
	- タグ（Tag）の管理
	- ユーザ一覧の確認

- ユーザ（Public）
	- サインアップ / ログイン / ログアウト（`has_secure_password`）
	- 書籍一覧・詳細表示、タグ絞り込み、ヘッダ検索
	- カートに追加 / 削除
	- 注文作成（複数書籍に対応）と注文確認メール（`OrderMailer`）
	- マイページ（注文履歴など）

## 動作環境（ローカル開発）

前提:
- Ruby 3.4.x
- Rails 8.x
- SQLite3（開発）

セットアップ手順:

1. リポジトリをクローンして移動

```bash
git clone <this-repo-url>
cd ec_site
```

2. 依存ライブラリをインストール

```bash
bundle install
```

3. 環境変数（管理者アカウントの初期化に必要）

```bash
export ADMIN_EMAIL=admin@example.com
export ADMIN_PASSWORD=changeme
```

4. データベース作成とマイグレーション、シード

```bash
bin/rails db:create db:migrate
bin/rails db:seed
```

シードは `ADMIN_EMAIL` / `ADMIN_PASSWORD` から管理者アカウントを作成します。環境変数が未設定の場合は管理者は作成されません（安全対策）。

5. サーバ起動

```bash
bin/rails server
```

ブラウザで `http://localhost:3000` を開いてください。

## アセットについて

このプロジェクトは `bootstrap` gem と `dartsass-rails` を使って Bootstrap を SCSS 経由で組み込んでいます。

- 開発中は通常プリコンパイルは不要です（Rails が動的にアセットを提供します）。
- 必要に応じてプリコンパイルできます：

```bash
bin/rails assets:precompile
```

注意: 現在 Bootstrap 側の一部スタイルで古い `@import` を使う箇所があり、Sass の deprecation 警告が出ます。動作自体には問題ありませんが、将来的に `@use` へ移行するのが望ましいです。

カスタムスタイルは `app/assets/stylesheets/custom.scss` にあります。

## 環境変数（まとめ）

- `ADMIN_EMAIL` — シードで作成する管理者メールアドレス
- `ADMIN_PASSWORD` — 管理者の初期パスワード

（必要に応じてメール設定などを追加で環境変数で切り替えてください）

## よくあるトラブルと対処

- CSS が反映されない
	- ブラウザのキャッシュをハードリロード（Ctrl/Cmd+Shift+R）してください。
	- `public/assets` に古いプリコンパイル済みアセットが残っていると開発モードと挙動が変わることがあります。その場合は `rm -rf public/assets && bin/rails assets:precompile` またはサーバ再起動をお試しください。

- マイグレーションが競合する
	- ローカルで複数のマイグレーションが編集・追加されている場合は不要なマイグレーションを整理するか、`db/schema.rb` から再構築してください。

## テスト / デバッグ

- まだフルの E2E 自動テストは整備されていません。今後のタスクで「サインアップ → ログイン → カート → 注文」のシンプルな smoke テストを追加する予定です。

## 今後の改善案

- Sass の `@import` を `@use` に置換して deprecation を解消
- `letter_opener` などを導入して開発環境でメールプレビューを改善
- Capybara 等でシステムテストを追加して回帰を防ぐ

---

必要なら README にデプロイ手順や CI（GitHub Actions 等）設定、テストの実行手順などを追記します。どの情報を優先して追加しますか？

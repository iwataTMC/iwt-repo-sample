# GitHub リリース手順（`post-create.sh` と `branch-setting.md` の設定後）

この手順は、次の2点が完了している前提です。

- `.devcontainer/post-create.sh` の実行
- `branch-setting.md` に記載したブランチ設定の完了

さらに、以下のファイルが作成済みである前提です。

- `.github/workflows/release.yml`
- `.releaserc.json`
- `commitlint.config.cjs`
- `.pre-commit-config.yaml`
- `.husky/` 配下のフック

---

## 0. まず理解しておくこと（かんたん要約）

このリポジトリでは、**`main` ブランチへ push されたとき**に GitHub Actions が `semantic-release` を実行し、次を自動化します。

1. コミット履歴からバージョンを決定
2. GitHub Release を作成
3. `CHANGELOG.md` を更新
4. 変更後の `CHANGELOG.md` / `package.json` / `package-lock.json` をコミット
5. タグ（例: `v1.2.3`）を作成

---

## 1. 初回のみ：GitHub 側の準備

### 1-1. Actions の実行権限を確認

1. GitHub のリポジトリ画面を開く
2. `Settings` → `Actions` → `General`
3. `Workflow permissions` を確認
   - 基本はワークフローファイル内の `permissions` 指定で動きます
   - もし権限エラーが出る場合は、`Read and write permissions` を有効化

### 1-2. （必要な場合）Branch protection を確認

- `main` ブランチが保護されていて直接 `push` できない場合は、
  - `feature/**` ブランチなどで作業
  - `Pull Request` を作成
  - **PR を `main` にマージ**してリリースをトリガーする

---

## 2. GitHub Codespaces で作業する

### 2-1. 変更を作る

例）`README.md` に1行追加など

### 2-2. 変更をステージング

```bash
git add .
```

### 2-3. Conventional Commits でコミット

対話式で作る場合（推奨）:

```bash
npm run cz
```

手動で作る場合（例）:

```bash
git commit -m "feat: add sample section to README"
```

> リリース判定の目安:
>
> - `feat:` → マイナーバージョンアップ
> - `fix:` → パッチバージョンアップ
> - `BREAKING CHANGE` を含む → メジャーバージョンアップ
> - `docs:` / `chore:` だけだとリリースされないことがあります

---

## 3. `main` に反映してリリースを開始

### 3-1. `main` に push（または PR をマージ）

直接 push できる場合:

```bash
git push origin main
```

PR 運用の場合:

1. ブランチを push
2. PR 作成
3. `main` へマージ

→ どちらも最終的に `main` に入った時点でリリースワークフローが走ります。

---

## 4. GitHub Actions の結果を確認

1. GitHub リポジトリの `Actions` タブを開く
2. `release` ワークフローを選択
3. ジョブ `release` が `✅` になっていることを確認

成功したら以下を確認:

- `Releases` に新規リリースが追加
- タグ（`vX.Y.Z`）が作成
- `CHANGELOG.md` が更新されている

---

## 5. トラブルシュート

### A. 「No release published」になる

- 原因: リリース対象のコミットが無い（`feat` / `fix` / breaking がない）
- 対処: `feat:` または `fix:` のコミットを追加して再度 `main` へ反映

### B. 権限エラー（403 など）

- 原因: `GITHUB_TOKEN` の権限不足
- 対処: `Settings > Actions > General > Workflow permissions` を見直し

### C. `npm ci` 失敗

- 原因: `package-lock.json` と `package.json` の不整合
- 対処:
  1. ローカルで `npm install`
  2. 生成された `package-lock.json` をコミット
  3. 再度 `main` へ反映

---

## 6. 最短実行チェックリスト

- [ ] `post-create.sh` 実行済み
- [ ] `branch-setting.md` の設定完了
- [ ] 変更を作成した
- [ ] `npm run cz`（または Conventional Commits）でコミットした
- [ ] `main` に push または PR マージした
- [ ] `Actions > release` が成功した
- [ ] `Releases` に新しいタグと本文が作成された

これで GitHub リリース運用が回せます。

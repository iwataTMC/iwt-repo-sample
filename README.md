# Dev Container Sample Repository

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/owner/repo)

このリポジトリは、以下を前提にした開発・リリース運用のサンプルです。

- Conventional Commits
- Husky + commitlint + pre-commit
- GitHub Actions + semantic-release

## 使い方

### 1. Codespaces で起動する

1. 上の **Open in GitHub Codespaces** から起動します。
> [!IMPORTANT]
> 適宜 `owner/repo` 部分は変更してください  
> 例：`https://codespaces.new/iwataTMC/iwt-repo-sample`


2. コンテナ初回起動時に `postCreateCommand` で `.devcontainer/post-create.sh` が実行されます。
3. もし途中で失敗した場合は、ターミナルで次を実行してください。

```bash
bash .devcontainer/post-create.sh
```

### 2. ブランチ保護を設定する（初回のみ）

`main` を安全に運用するため、先にブランチ保護を設定します。

- 詳細手順: [branch-setting.md](branch-setting.md)

### 3. 日常の開発フロー

1. ブランチを切る  
```bash
git checkout -b feature/*****
```
2. 変更を加える
3. ステージングする

```bash
git add .
```

3. Conventional Commits でコミットする（推奨）

```bash
npm run cz
```

4. PR を作成して `main` にマージ（または運用ルールに従って反映）

### 4. リリースする

`main` に反映されると、`release` ワークフローが実行され、GitHub Release とタグが自動作成されます。

- 詳細手順: [github-release.md](github-release.md)

## 生成される主な設定ファイル

`post-create.sh` 実行後、主に次が準備されます。

- `.github/workflows/release.yml`
- `.github/copilot-instructions.md`
- `.releaserc.json`
- `commitlint.config.cjs`
- `.pre-commit-config.yaml`
- `.husky/commit-msg`, `.husky/pre-commit`

## トラブル時の基本対応

- コンテナ起動エラー: `Dev Containers: Rebuild Container`
- 設定反映漏れ: `bash .devcontainer/post-create.sh` を再実行
- リリース失敗: [github-release.md](github-release.md) の「トラブルシュート」を確認

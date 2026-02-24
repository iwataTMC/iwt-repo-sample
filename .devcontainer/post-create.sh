#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this script inside a git repository." >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js is required." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm is required." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: Python 3 is required for pre-commit." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required to install uv." >&2
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

if [ ! -f package.json ]; then
  npm init -y >/dev/null
fi

npm install -D \
  semantic-release \
  @semantic-release/commit-analyzer \
  @semantic-release/release-notes-generator \
  @semantic-release/changelog \
  @semantic-release/git \
  @semantic-release/github \
  @commitlint/cli \
  @commitlint/config-conventional \
  commitizen \
  cz-conventional-changelog-ja \
  husky

node -e "const fs=require('fs');const p=JSON.parse(fs.readFileSync('package.json'));p.private=p.private??true;p.scripts=p.scripts||{};p.scripts.prepare=p.scripts.prepare||'husky install';p.scripts.cz=p.scripts.cz||'cz';p.config=p.config||{};p.config.commitizen=p.config.commitizen||{};p.config.commitizen.path=p.config.commitizen.path||'cz-conventional-changelog-ja';fs.writeFileSync('package.json', JSON.stringify(p,null,2));"

npx husky install

mkdir -p .husky .github/workflows

cat > .husky/commit-msg <<'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- commitlint --edit "$1"
EOF

cat > .husky/pre-commit <<'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

pre-commit run --hook-stage pre-commit
EOF

chmod +x .husky/commit-msg .husky/pre-commit

git config core.hooksPath .husky

if ! command -v pre-commit >/dev/null 2>&1; then
  if command -v pipx >/dev/null 2>&1; then
    pipx install pre-commit
  else
    python3 -m pip install --user pre-commit
  fi
fi

cat > commitlint.config.cjs <<'EOF'
module.exports = {
  extends: ["@commitlint/config-conventional"],
};
EOF

cat > .releaserc.json <<'EOF'
{
  "branches": ["main"],
  "tagFormat": "v${version}",
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    [
      "@semantic-release/git",
      {
        "assets": ["CHANGELOG.md", "package.json", "package-lock.json"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ],
    "@semantic-release/github"
  ]
}
EOF

cat > .pre-commit-config.yaml <<'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
EOF

cat > .github/workflows/release.yml <<'EOF'
name: release

on:
  push:
    branches:
      - main

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: npx semantic-release
EOF

if [ ! -f CHANGELOG.md ]; then
  cat > CHANGELOG.md <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.
EOF
fi

echo "Setup complete. Next: commit and push to main to trigger release."
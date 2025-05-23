#!/bin/bash

set -exuo pipefail

setup() {
  if ! command -v git; then
    echo "Git is not installed in your system. Exitting."
    exit 1
  fi
  if [ "$(git rev-parse --show-toplevel)" == "" ]; then
    echo "Your are not in a git initialised repository. Exitting."
    exit 1
  fi

  local git_root
  local hooks_dir
  local commit_msg_hook
  local pre_commit_hook

  git_root=$(git rev-parse --show-toplevel)
  hooks_dir=$git_root/.git-hooks
  commit_msg_hook=$hooks_dir/commit-msg
  pre_commit_hook=$hooks_dir/pre-commit

  if ! test -d "$hooks_dir"; then
    mkdir "$hooks_dir"
  fi

  if ! test -f "$hooks_dir/commit-msg"; then
    touch "$hooks_dir"/commit-msg
    cat >"$commit_msg_hook" <<-'EOF'
			#!/bin/bash

			if ! grep -Eq '^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([a-z -]+\))?!?: [a-z0-9 ]+$' "$1"; then
				echo "Prompt does not follow conventional commiting style(https://www.conventionalcommits.org/). Aborting the commit."
				exit 1
			fi
		EOF
  fi
  chmod +x "$hooks_dir"/commit-msg

  if ! test -f "$hooks_dir/pre-commit"; then
    touch "$hooks_dir"/pre-commit
    cat >"$pre_commit_hook" <<-'EOF'
			#!/bin/bash

			# Different pre commit hooks to run.
		EOF
  fi
  chmod +x "$hooks_dir"/pre-commit

  git config --local core.hooksPath "$hooks_dir"
}

setup "$@"

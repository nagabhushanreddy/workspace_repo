#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_list="$script_dir/extensions.txt"

usage() {
	cat <<'EOF'
Usage: install_vs_code_extensions.sh [install|export] [extensions_file]

Commands:
	install   Install extensions listed in extensions_file (default: ./extensions.txt)
	export    Export currently installed extensions into extensions_file

Examples:
	./install_vs_code_extensions.sh install
	./install_vs_code_extensions.sh install custom.txt
	./install_vs_code_extensions.sh export
EOF
}

ensure_code_cli() {
	if ! command -v code >/dev/null 2>&1; then
		echo "VS Code CLI ('code') not found in PATH. In VS Code, run: Shell Command: Install 'code' command in PATH." >&2
		exit 1
	fi
}

install_extensions() {
	local list_file="$1"
	if [[ ! -s "$list_file" ]]; then
		echo "Extension list file not found or empty: $list_file" >&2
		exit 1
	fi
	while IFS= read -r ext; do
		[[ -z "$ext" ]] && continue
		echo "Installing $ext..."
		code --install-extension "$ext"
	done <"$list_file"
}

export_extensions() {
	local list_file="$1"
	echo "Exporting installed extensions to $list_file"
	code --list-extensions >"$list_file"
}

main() {
	local cmd="${1:-install}"
	local list_file="${2:-$default_list}"

	case "$cmd" in
		install)
			ensure_code_cli
			install_extensions "$list_file"
			;;
		export)
			ensure_code_cli
			export_extensions "$list_file"
			;;
		-h|--help|help)
			usage
			;;
		*)
			echo "Unknown command: $cmd" >&2
			usage
			exit 1
			;;
	esac
}

main "$@"
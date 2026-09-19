# ~/.profile: read by login shells when ~/.bash_profile and ~/.bash_login do
# not exist.

# Load the interactive Bash configuration for Bash login sessions.
if [ -n "${BASH_VERSION:-}" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# Add user-managed command directories for non-interactive login sessions as
# well. npm-global is last here so that it takes precedence over ~/.local/bin;
# this keeps Codex under npm management.
profile_path_prepend() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *:"$1":*) ;;
        *) PATH="$1${PATH:+:$PATH}" ;;
    esac
}

profile_path_prepend "$HOME/bin"
profile_path_prepend "$HOME/.local/bin"
profile_path_prepend "$HOME/.npm-global/bin"
export PATH
unset -f profile_path_prepend

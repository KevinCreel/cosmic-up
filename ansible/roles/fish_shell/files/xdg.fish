set -q XDG_CACHE_HOME || set -Ux XDG_CACHE_HOME $HOME/.cache
set -q XDG_CONFIG_HOME || set -Ux XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME || set -Ux XDG_DATA_HOME $HOME/.local/share

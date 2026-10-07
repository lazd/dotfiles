for bin_dir in "$HOME/.local/bin" "$HOME/bin"; do
	case ":$PATH:" in
		*":$bin_dir:"*) ;;
		*) export PATH="$PATH:$bin_dir" ;;
	esac
done
export EDITOR=vim

if status is-interactive
    # Commands to run in interactive sessions can go here

end

# Remove greeting message

set fish_greeting

# Starship prompt

starship init fish | source

# Aliases

    # GNU Utils

    alias cat="bat --wrap never"
    alias ls="lsd -lah --header --group-directories-first"

    # Pacman

    alias maintain="sh ~/Personal/scripts/system-maintenance.sh"
    alias install="yay -S"
    alias remove="yay -Rns"
    alias force-remove="yay -Rdd"
    alias search-local="yay -Qi"
    alias search-repo="yay -Si"
    alias ls-pkgs="yay -Qq"
    alias num-pkgs="yay -Qq | wc -l"

    # Operations Alias

    alias c="clear"
    alias edit="sudo micro"
    alias del-dir="sudo rm -rf"
    alias restart="source ~/.config/fish/config.fish"
    alias empty-trash="cd ~/.local/share/Trash/files && sudo rm -rf *"

    # Git

    alias update-repo="sh ~/Personal/scripts/update-repo.sh"

    # ArchISO

    alias build-iso="sh ~/Personal/scripts/build-iso.sh"

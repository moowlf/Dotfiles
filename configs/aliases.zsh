# Creates a directory and changes current directory to the newly created
mkcd() { mkdir -p "$1" && cd "$1"; }

# -----------------------------------------------------------------------------
#   Alias setup
# -----------------------------------------------------------------------------
alias mkcd='mkcd'
alias reboot='sudo reboot'
alias shutdown='sudo shutdown 0'
alias clp="xclip -selection clipboard"

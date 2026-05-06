if status is-interactive
    # Commands to run in interactive sessions can go here
    # Disable greeting
    set -U fish_greeting ""
    
    # Run fastfetch with Genesi OS logo if fastfetch is installed
    if command -v fastfetch >/dev/null
        # Use small genesi logo with specific color
        fastfetch -l small --logo-color-1 "green"
    end
end

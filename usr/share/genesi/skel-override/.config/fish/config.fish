if status is-interactive
    # Commands to run in interactive sessions can go here
    # Disable fish's built-in greeting. The branded Genesi greeting (logo + system
    # info) is shown ONCE by /usr/share/fish/vendor_conf.d/genesi-fastfetch.fish
    # (genesi-fastfetch package), which runs fastfetch with the Genesi config.
    # Do NOT run fastfetch here too — that showed the greeting twice (the distro
    # logo from this plain `fastfetch` plus the branded one from vendor_conf.d).
    set -U fish_greeting ""
end

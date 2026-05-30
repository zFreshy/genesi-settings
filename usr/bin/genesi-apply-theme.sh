#!/bin/bash
# Genesi OS - Theme Applicator
# Ensures all theme settings are applied correctly on first boot

# Wait for Plasma to fully start
sleep 5

# Apply wallpaper using plasma-apply-wallpaperimage
if command -v plasma-apply-wallpaperimage &>/dev/null; then
    plasma-apply-wallpaperimage /usr/share/wallpapers/genesi/wallpaper.png 2>/dev/null || true
fi

# Apply color scheme
plasma-apply-colorscheme Genesi 2>/dev/null || true

# Apply icons (multiple fallback methods)
# The package creates Tela-circle-green-dark, check if it exists first
if [ -d "/usr/share/icons/Tela-circle-green-dark" ]; then
    /usr/lib/plasma-changeicons Tela-circle-green-dark 2>/dev/null || true
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-circle-green-dark 2>/dev/null || true
    kwriteconfig5 --file kdeglobals --group Icons --key Theme Tela-circle-green-dark 2>/dev/null || true
    gtk-update-icon-cache -f -t /usr/share/icons/Tela-circle-green-dark 2>/dev/null || true
fi

# Reset layout using KDE Scripting Engine
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat /etc/skel/.config/genesi-layout.js)" 2>/dev/null || true

# Restart KWin to apply window decoration and effects
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    kwin_wayland --replace &
else
    kwin_x11 --replace &
fi

# Restart plasmashell so it re-reads the appletsrc with the new Kickoff
# popupHeight/popupWidth that the JS just wrote. Without this, plasmashell
# keeps its in-memory cached size from when the panel was first built
# (BEFORE the JS overrode the dimensions), and the Kickoff menu renders
# at the Plasma default size instead of our 300x450 hint. Reproduced
# 2026-05-30: file had popupHeight=300 but menu still rendered oversize
# until a manual `kquitapp6 plasmashell && kstart plasmashell` was run.
# `plasmashell --replace` is the atomic equivalent that ships in a single
# command. Brief panel flicker (~1-2s) is acceptable because this entire
# script is a one-shot autostart that removes itself below.
sleep 1
plasmashell --replace &
disown
sleep 2

# Disable this autostart after first run
rm -f ~/.config/autostart/genesi-apply-theme.desktop

exit 0
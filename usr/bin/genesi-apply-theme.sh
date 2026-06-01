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

# Reset layout using KDE Scripting Engine (builds the floating panel + Kickoff
# sizing). Plasma 6 ships `qdbus6` and has NO `qdbus`, so the old hard-coded
# `qdbus` call silently failed on installed systems and the panel never became
# floating (reproduced 2026-06-01). Pick whichever binary exists, and read the
# layout JS from the user's own config first, falling back to /etc/skel.
_applied=0
_qdbus="$(command -v qdbus6 || command -v qdbus || true)"
_layout=""
[ -f "$HOME/.config/genesi-layout.js" ] && _layout="$HOME/.config/genesi-layout.js"
[ -z "$_layout" ] && [ -f /etc/skel/.config/genesi-layout.js ] && _layout="/etc/skel/.config/genesi-layout.js"
if [ -n "$_qdbus" ] && [ -n "$_layout" ]; then
    if "$_qdbus" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$_layout")" 2>/dev/null; then
        _applied=1
    fi
fi

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

# Disable this autostart ONLY if the layout actually applied. If qdbus/qdbus6
# wasn't available (old failure mode), keep the autostart so the next login
# retries instead of silently self-destructing with nothing applied.
if [ "${_applied:-0}" = 1 ]; then
    rm -f ~/.config/autostart/genesi-apply-theme.desktop
fi

exit 0
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

# NOTE: we deliberately do NOT run genesi-layout.js anymore.
#
# The skel ships a complete, working plasma-org.kde.plasma.desktop-appletsrc
# (floating panel, sized Kickoff, the AI Mode launcher AND a fully-populated
# system tray). genesi-layout.js used to `panels().remove()` and rebuild from
# scratch, but a script-built systemtray never instantiates the notifications
# applet -> org.freedesktop.Notifications is never registered -> every
# notify-send hangs ~25s and silently fails (no update-available popup, no AI
# Mode toast, kdeconnect "could not query capabilities"). The static appletsrc
# carries `shownItems=org.kde.plasma.notifications`, so simply LOADING it gives
# a working notification server. Rebuilding it was redundant and harmful.
# Reproduced + verified on an installed VM 2026-06-02.

# Restart KWin to apply window decoration and effects
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    kwin_wayland --replace &
else
    kwin_x11 --replace &
fi

# Restart plasmashell so the icon theme just written to kdeglobals takes effect
# (plasma-changeicons/kwriteconfig don't repaint a running shell). The panel
# layout + Kickoff sizing already come from the static appletsrc loaded at
# login, so this is only a repaint. Brief panel flicker (~1-2s) is acceptable
# because this is a one-shot autostart that removes itself below.
sleep 1
plasmashell --replace &
disown
sleep 2

# One-shot: remove the autostart so this only runs on the very first login.
# (There's no layout step to retry anymore — the static appletsrc is the
# source of truth, and wallpaper/colorscheme/icons above are idempotent.)
rm -f ~/.config/autostart/genesi-apply-theme.desktop

exit 0
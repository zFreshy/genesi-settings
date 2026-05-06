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

# Apply icons
/usr/lib/plasma-changeicons Tela-circle-green-dark 2>/dev/null || true

# Reset layout using KDE Scripting Engine
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat /etc/skel/.config/genesi-layout.js)" 2>/dev/null || true

# Restart KWin to apply window decoration and effects
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    kwin_wayland --replace &
else
    kwin_x11 --replace &
fi

# Disable this autostart after first run
rm -f ~/.config/autostart/genesi-apply-theme.desktop

exit 0
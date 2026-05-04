#!/bin/bash
# Genesi OS - Theme Applicator
# Ensures all theme settings are applied correctly on first boot

# Wait for Plasma to fully start
sleep 3

# Set wallpaper using qdbus
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "file:///usr/share/wallpapers/genesi/wallpaper.png");
    d.writeConfig("FillMode", "2");
}
'

# Restart KWin to apply window decoration and effects
kwin_x11 --replace &

# Apply color scheme
plasma-apply-colorscheme Genesi 2>/dev/null || true

# Disable this autostart after first run
rm -f ~/.config/autostart/genesi-apply-theme.desktop

exit 0

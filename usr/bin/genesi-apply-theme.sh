#!/bin/bash
# Genesi OS - Theme Applicator
# Ensures all theme settings are applied correctly on first boot

# Wait for Plasma to fully start
sleep 3

# Apply wallpaper using plasma-apply-wallpaperimage (works on both X11 and Wayland)
if command -v plasma-apply-wallpaperimage &>/dev/null; then
    plasma-apply-wallpaperimage /usr/share/wallpapers/genesi/wallpaper.png 2>/dev/null || true
fi

# Restart KWin to apply window decoration and effects
# Detect if running X11 or Wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    kwin_wayland --replace &
else
    kwin_x11 --replace &
fi

# Apply color scheme
plasma-apply-colorscheme Genesi 2>/dev/null || true

# Disable this autostart after first run
rm -f ~/.config/autostart/genesi-apply-theme.desktop

exit 0

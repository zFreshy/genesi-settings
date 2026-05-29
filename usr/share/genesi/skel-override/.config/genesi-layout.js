var p = panels();
for (var i = 0; i < p.length; i++) {
    p[i].remove();
}

var bottomDock = new Panel("org.kde.panel");
bottomDock.location = "bottom";
bottomDock.height = 50;
bottomDock.alignment = "center";
bottomDock.floating = true;

var launcher = bottomDock.addWidget("org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "/usr/share/pixmaps/genesi-logo.png");
// Lock the popup size so the menu opens at its final dimensions instead
// of starting at the "natural content size" and visibly growing upward
// until it hits the limit (reproduced 2026-05-27). popupHeight/popupWidth
// live at the Configuration root, not under [General], so reset the
// group before writing. Same numbers shipped statically in
// plasma-org.kde.plasma.desktop-appletsrc - duplicated here because the
// script destroys all panels above and rebuilds, so the static file's
// values for the previous applet IDs are no longer applied.
launcher.currentConfigGroup = [];
launcher.writeConfig("popupHeight", 509);
launcher.writeConfig("popupWidth", 631);
launcher.reloadConfig();

bottomDock.addWidget("org.kde.plasma.panelspacer");

var tasks = bottomDock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("iconSpacing", "2");
// IMPORTANT: pass launchers as a JS array, NOT a comma-separated string.
// Reproduced 2026-05-29: writing a string left the panel with a single "?"
// icon tooltipped "browser,applications:org.kde.konsole.d..." - Plasma 6
// treated the entire string as ONE URL instead of splitting on commas.
// Plasma scripting's writeConfig joins arrays with commas correctly into
// the underlying KConfig string-list format.
// Also swapped preferred://browser -> applications:firefox.desktop because
// preferred:// adds another resolution layer that fails silently in the
// live ISO (no default browser registered yet via xdg-mime).
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:firefox.desktop",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop"
]);

bottomDock.addWidget("org.kde.plasma.panelspacer");

var aiBtn = bottomDock.addWidget("org.kde.plasma.icon");
aiBtn.currentConfigGroup = ["General"];
aiBtn.writeConfig("applicationName", "Genesi AI Mode");
aiBtn.writeConfig("iconName", "cpu");
aiBtn.writeConfig("url", "file:///usr/share/applications/genesi-aimode.desktop");

var tray = bottomDock.addWidget("org.kde.plasma.systemtray");
var clock = bottomDock.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("dateFormat", "isoDate");
clock.writeConfig("use24hFormat", "2");

bottomDock.addWidget("org.kde.plasma.showdesktop");

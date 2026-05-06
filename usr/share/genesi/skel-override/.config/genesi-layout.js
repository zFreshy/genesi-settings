var p = panels();
for (var i = 0; i < p.length; i++) {
    p[i].remove();
}

var bottomDock = new Panel("org.kde.panel");
bottomDock.location = "bottom";
bottomDock.height = 50;
bottomDock.alignment = "center";
bottomDock.floating = true;

var launcher = bottomDock.addWidget("org.kde.plasma.kicker");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "/usr/share/pixmaps/genesi-logo.png");

bottomDock.addWidget("org.kde.plasma.panelspacer");

var tasks = bottomDock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("iconSpacing", "2");
tasks.writeConfig("launchers", "applications:org.kde.dolphin.desktop,preferred://browser,applications:org.kde.konsole.desktop,applications:systemsettings.desktop");

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

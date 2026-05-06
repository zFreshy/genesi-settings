var topPanel = new Panel("org.kde.panel");
topPanel.location = "top";
topPanel.height = 32;
topPanel.alignment = "left";
topPanel.opacity = "translucent";

topPanel.addWidget("org.kde.plasma.appmenu");
topPanel.addWidget("org.kde.plasma.panelspacer");
var clock = topPanel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("dateFormat", "isoDate");
clock.writeConfig("use24hFormat", "2");
topPanel.addWidget("org.kde.plasma.panelspacer");
topPanel.addWidget("org.kde.plasma.systemtray");

var bottomDock = new Panel("org.kde.panel");
bottomDock.location = "bottom";
bottomDock.height = 56;
bottomDock.alignment = "center";
bottomDock.lengthMode = "fit";
bottomDock.floating = true;
bottomDock.opacity = "translucent";

var launcher = bottomDock.addWidget("org.kde.plasma.kicker");
launcher.currentConfigGroup = ["General"];
launcher.writeConfig("icon", "/usr/share/pixmaps/genesi-logo.png");

var tasks = bottomDock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "applications:org.kde.dolphin.desktop,preferred://browser,applications:org.kde.konsole.desktop,applications:systemsettings.desktop");

var aiBtn = bottomDock.addWidget("org.kde.plasma.icon");
aiBtn.currentConfigGroup = ["General"];
aiBtn.writeConfig("applicationName", "Genesi AI Mode");
aiBtn.writeConfig("iconName", "cpu");
aiBtn.writeConfig("url", "file:///usr/share/applications/genesi-aimode.desktop");

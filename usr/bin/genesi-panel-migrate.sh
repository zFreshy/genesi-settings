#!/bin/bash
# Genesi OS - Panel migration (one-shot, per existing user)
#
# New users get the full Genesi panel from the static skel appletsrc, which
# already lists every default widget (AI Mode = applet 32, Containers = applet
# 33, ...). But an EXISTING user keeps the panel layout that plasmashell built
# at their first login; adding a widget to skel never touches it. So when a new
# default widget ships (e.g. org.genesi.containers via the genesi-desktop meta),
# already-installed systems get the plasmoid in /usr/share/plasma/plasmoids but
# it never lands on the running panel.
#
# This script heals that. The genesi-settings post_upgrade scriptlet drops the
# accompanying autostart into each existing user's ~/.config/autostart on
# `pacman -Syu`; on the next login this runs IN the user's session (so the
# plasmashell D-Bus scripting interface and the session bus are available) and
# adds any missing default widget to the live panel via evaluateScript. Going
# through plasmashell means the change is persisted by the shell itself — no
# editing of plasma-org.kde.plasma.desktop-appletsrc under a running session
# (which plasmashell would clobber from its in-memory layout on logout).
#
# It is idempotent: it only adds a widget that is not already on a panel, so it
# can never create a duplicate, and it self-removes its autostart once done.

set -u

MARKER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/genesi"
MARKER="$MARKER_DIR/panel-migrate-containers.done"
AUTOSTART="${XDG_CONFIG_HOME:-$HOME/.config}/autostart/genesi-panel-migrate.desktop"

# Already migrated -> make sure the autostart is gone and stop.
if [ -f "$MARKER" ]; then
    rm -f "$AUTOSTART"
    exit 0
fi

# Wait until plasmashell is actually up (no fixed-sleep race).
for _ in $(seq 1 30); do
    pgrep -x plasmashell >/dev/null 2>&1 && break
    sleep 0.5
done

# Pick a working qdbus (Plasma 6 ships qdbus6).
QDBUS=""
for q in qdbus6 qdbus-qt6 qdbus; do
    if command -v "$q" >/dev/null 2>&1; then QDBUS="$q"; break; fi
done
[ -n "$QDBUS" ] || exit 0   # nothing to do without D-Bus; retry next login

# Add org.genesi.containers to the first panel if no panel already has it.
# print("ok") on success (present or just added), "nopanel" if there is no
# panel to add it to. Anything else (empty / error) -> leave the marker unset
# so we retry on the next login.
read -r -d '' JS <<'PLASMASCRIPT'
var present = false;
var ps = panels();
for (var i = 0; i < ps.length; i++) {
    var ws = ps[i].widgets();
    for (var j = 0; j < ws.length; j++) {
        if (ws[j].type == "org.genesi.containers") { present = true; }
    }
}
if (!present && ps.length > 0) {
    ps[0].addWidget("org.genesi.containers");
    present = true;
}
print(present ? "ok" : "nopanel");
PLASMASCRIPT

RESULT="$("$QDBUS" org.kde.plasma.shell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$JS" 2>/dev/null)" || RESULT=""

# Mark done + drop the autostart only on a confirmed success, so a transient
# failure (plasmashell not ready, scripting locked) is retried next login
# instead of being silently skipped forever.
if [ "$RESULT" = "ok" ]; then
    mkdir -p "$MARKER_DIR"
    : > "$MARKER"
    rm -f "$AUTOSTART"
fi

exit 0

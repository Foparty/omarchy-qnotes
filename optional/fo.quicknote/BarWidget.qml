import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "fo.quicknote"

  readonly property string icon: ""
  readonly property string notesDirFallback: (Quickshell.env("HOME") || "") + "/notes"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    slotSize: Style.bar.statusSlot
    tooltipText: "Notes panel (see keybindings)"

    onPressed: function(b) {
      if (!root.bar) return
      if (b === Qt.RightButton) {
        root.bar.run("xdg-open \"$(omarchy-notes print-dir 2>/dev/null || printf %s " + Util.shellQuote(root.notesDirFallback) + ")\"")
      } else {
        root.bar.run("omarchy-notes toggle")
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property bool awake: false
    // kde-inhibit holds the inhibition for as long as the child command runs.
    // "sleep infinity" keeps it alive until we disconnect the source (which kills it).
    readonly property string inhibitCmd: "kde-inhibit --power --screenSaver sleep infinity"
    readonly property url coffeeIcon: Qt.resolvedUrl("../icons/coffee.svg")

    preferredRepresentation: compactRepresentation
    Plasmoid.icon: coffeeIcon

    toolTipMainText: i18n("Keep Awake")
    toolTipSubText: awake
        ? i18n("Active: the computer will not sleep or start the screensaver")
        : i18n("Inactive: normal power behavior")

    Plasmoid.status: awake ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        // Long-running command: no data arrives until it exits, so the source
        // stays connected (process alive). Disconnecting terminates it.
    }

    function toggle() {
        if (awake) {
            executable.disconnectSource(inhibitCmd)
            awake = false
        } else {
            executable.connectSource(inhibitCmd)
            awake = true
        }
    }

    compactRepresentation: MouseArea {
        id: compactRoot
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: root.toggle()

        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        implicitWidth: Kirigami.Units.iconSizes.large
        implicitHeight: Kirigami.Units.iconSizes.large

        Kirigami.Icon {
            anchors.fill: parent
            source: root.coffeeIcon
            // coffee.svg uses currentColor, so Kirigami recolors it via `color`
            // (no isMask: grabbed/painted reliably and adapts to light/dark panels).
            // Always full opacity so it stays clearly visible on the panel; the
            // active/inactive state is shown by color (accent vs text color).
            color: root.awake ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            opacity: compactRoot.containsMouse && !root.awake ? 0.8 : 1.0
        }
    }

    // The global shortcut fires the applet's activated() signal; route it to toggle().
    // A default shortcut is set imperatively (a declarative binding can't convert a
    // string to QKeySequence in Plasma 6). It is only applied when the user has not
    // already chosen one, so a custom shortcut survives restarts.
    Component.onCompleted: {
        if (String(Plasmoid.globalShortcut).length === 0) {
            Plasmoid.globalShortcut = "Meta+Shift+K"
        }
        Plasmoid.activated.connect(root.toggle)
    }

    Component.onDestruction: {
        Plasmoid.activated.disconnect(root.toggle)
        if (awake) {
            executable.disconnectSource(inhibitCmd)
        }
    }
}

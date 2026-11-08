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
    readonly property url coffeeOnIcon: Qt.resolvedUrl("../icons/coffee-on.svg")
    readonly property url coffeeOffIcon: Qt.resolvedUrl("../icons/coffee-off.svg")
    readonly property url coffeeIcon: awake ? coffeeOnIcon : coffeeOffIcon

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

    fullRepresentation: Rectangle {
        color: "steelblue"
        implicitWidth: 200
        implicitHeight: 100

        Text {
            anchors.centerIn: parent
            text: "KEEP AWAKE OK"
            color: "white"
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

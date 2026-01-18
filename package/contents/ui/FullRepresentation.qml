import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ColumnLayout {
    id: fullRoot

    //Layout.fillHeight: plasmoid.formFactor === Plasmoid.Vertical

    PlasmaExtras.Heading {
        Layout.fillWidth: true
        level: 3
        wrapMode: Text.WordWrap
        text: headsetcontrol.model
    }

    PlasmaComponents.Label {
        id: headsetStatus
        text: headsetcontrol.status
    }

    // Why there is no separator Component built-in is beyond me.
    Item {
        height: headsetStatus.height

        Layout.fillWidth: true

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right

            // same as MenuItem background
            implicitWidth: Kirigami.Units.gridUnit * 8
            implicitHeight: 1 //Kirigami.Units.devicePixelRatio
            color: Kirigami.Theme.textColor
            opacity: 0.2
        }
    }


    RowLayout {
        id: featureSidetone
        visible: headsetcontrol.features.includes("s")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Slider {
            id: featureSidetoneValue
            Layout.fillWidth: true
            from: 0
            to: 128
            value: 16
            wheelEnabled: true
            stepSize: 1.0

            ToolTip.visible: pressed
            ToolTip.text: value.toFixed()
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Set sidetone")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -s ' + featureSidetoneValue.value.toFixed())
        }
    }

    RowLayout {
        id: featureLights
        visible: headsetcontrol.features.includes("l")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Enable lights")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -l 1')
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Disable lights")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -l 0')
        }
    }

    RowLayout {
        id: featureVoicePrompt
        visible: headsetcontrol.features.includes("v")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Enable voice prompt")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -v 1')
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Disable voice prompt")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -v 0')
        }
    }

    RowLayout {
        id: featureRotateToMute
        visible: headsetcontrol.features.includes("r")

        Layout.fillHeight: false
        Layout.fillWidth: true

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Enable rotate-to-mute")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -r 1')
        }

        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Disable rotate-to-mute")
            onClicked: headsetCommand.exec(plasmoid.configuration.binaryPath + ' -r 0')
        }
    }

    // Spacer item until I figure out how to resize the pop-up.
    Item {
        Layout.fillHeight: true
    }

    // Separate DataSource for non-polling commands. No signal here since we
    // don't expect any output.
    Plasma5Support.DataSource {
        id: headsetCommand
        engine: "executable"
        connectedSources: []
        onNewData: {
            var stdout = data["stdout"].trim();
            var code = data["exit code"];
            console.log("headsetCommand code: " + code + ", output: " + stdout);

            disconnectSource(sourceName); // cmd finished
        }

        function exec(cmd) {
            connectSource(cmd);
        }
    }
}
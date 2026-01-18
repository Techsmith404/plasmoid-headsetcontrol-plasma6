import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: headsetcontrol

    property bool present: false    // USB receiver is plugged in.
    property bool available: false  // Headset is on and connected.
    property int percent: 0
    property string status: "N/A"
    property string model: "Headset Control"
    property string features: ""

    // Manual Representation Loading - Foolproof Method
    Plasmoid.status: {
        if (headsetcontrol.available) {
            return Plasmoid.Active;
        }
        return Plasmoid.Passive;
    }

    Loader {
        anchors.fill: parent
        source: Plasmoid.formFactor === Plasmoid.Compact 
                ? Qt.resolvedUrl("CompactRepresentation.qml")
                : Qt.resolvedUrl("FullRepresentation.qml")
    }

    // DataSource for the user command execution results.
    Plasma5Support.DataSource {
        id: subprocess
        engine: "executable"
        connectedSources: []
        onNewData: {
            var stdout = data["stdout"].trim();
            var code = data["exit code"];

            exited(sourceName, code, stdout);
            disconnectSource(sourceName); // cmd finished
        }

        function exec(cmd) {
            connectSource(cmd);
        }

        signal exited(string sourceName, string code, string stdout);
    }

    Timer {
        id: timer
        interval: Plasmoid.configuration.pollingRate
        running: false
        repeat: false
        onTriggered: poll()
    }

    Component.onCompleted: {
        poll();
    }

    // Parse output of called command when it returns.
    Connections {
        target: subprocess
        onExited: {
            parse(sourceName, code, stdout);
        }
    }

    // FIXME: ... a state machine would probably make this less confusing.
    function poll() {
        if (!headsetcontrol.present) {
            // Try detecting headset model before charge. We don't use the short
            // output because that won't give us the headset model.
            subprocess.exec(Plasmoid.configuration.binaryPath + ' -?');
        } else {
            // Try detecting features before charge. We could try to get it all
            // at once along with the model, but using the short output here is
            // much easier.
            if (headsetcontrol.features == "") {
                subprocess.exec(Plasmoid.configuration.binaryPath + ' -? -c');
            } else {
                subprocess.exec(Plasmoid.configuration.binaryPath + ' -b -c');
            }
        }
    }

    // Reset internal state.
    function reset() {
        headsetcontrol.present = false;
        headsetcontrol.available = false;
        headsetcontrol.features = "";
        headsetcontrol.percent = 0;
        headsetcontrol.model = "Headset Control";
        headsetcontrol.status = "N/A";
    }

    // Parse the output of a polling command (which is either trying to detect
    // if the headset receiver is present, what model the headset is and what
    // it's charge level is, if available).
    function parse(cmd, code, status) {
        // Was the headset receiver detected at all?
        if (!headsetcontrol.present) {
            // We're trying to detect the receiver/model.
            if (code == 0) {
                // Receiver is present, we hould have a model name.
                headsetcontrol.present = true;
                headsetcontrol.model = parseModel(status);

                // Poll again immediately to get features.
                poll();
            } else {
                // No receiver detected at all. Reset everything.
                reset();

                // Wait a little before polling again.
                timer.running = true;
            }

            // Stop here, we need more polling to get the features.
            return;
        }

        // Have we detected the headset's features?
        // FIXME: this would be easier if we read name AND features at once.
        if (headsetcontrol.features == "") {
            // Receiver is present, read the headset's features.
            if (code == 0) {
                // We have a list of letters, each one indicating a feature.
                headsetcontrol.features = status;

                // Poll again immediately to get battery state.
                poll();
            } else {
                // Most likely the receiver was unplugged.
                reset();

                // Wait a little before polling again.
                timer.running = true;
            }

            // Stop here, we need more polling to get the charge.
            return;
        }

        // If we got here, we know the model and features. We just need the
        // headset itself to be on so we can get its battery level.
        if (code == 0) {
            // Mark headset as available and grab charge level.
            headsetcontrol.available = true;
            headsetcontrol.percent = parseInt(status);
        } else {
            // Reset charge and availability.
            headsetcontrol.available = false;
            headsetcontrol.percent = 0;

            // Reset the features list. This will cause another round of
            // polling that will also detect whether the receiver itself is
            // still there.
            headsetcontrol.features = "";
        }

        // Update text with charge status.
        headsetcontrol.status = updatedStatus();

        // Wait a little before polling again.
        timer.running = true;
    }

    function updatedStatus() {
        if (!headsetcontrol.available || !headsetcontrol.present) {
            return i18n("N/A");
        }
        if (headsetcontrol.percent == -1) {
            return i18n("Charging...");
        }
        return i18n("Charge: %1%", headsetcontrol.percent);
    }

    // Extract the headset model from "-?" output.
    function parseModel(output) {
        var header = output.split("\n")[0];
        var model = header.match(/^Found ([^!]*)!$/)[1];

        return model;
    }
}
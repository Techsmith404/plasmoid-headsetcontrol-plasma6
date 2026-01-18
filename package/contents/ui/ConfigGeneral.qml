import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: pageColumn
    
    property alias cfg_binaryPath: binaryPath.text
    property alias cfg_pollingRate: pollingRate.value

    RowLayout {
        Kirigami.FormData.label: i18n("Headsetcontrol path:")
    
        TextField {
            id: binaryPath
            placeholderText: i18n("No file selected.")
        }
        Button {
            text: i18n("Browse")
            icon.name: "folder-symbolic"
            onClicked: fileDialogLoader.active = true

            Loader {
                id: fileDialogLoader
                active: false

                sourceComponent: FileDialog {
                    id: fileDialog
                    title: i18n("Select headsetcontrol binary")
                    nameFilters: [
                        i18n("All files (%1)", "*"),
                    ]
                    onAccepted: {
                        var path = selectedFile.toString();
                        // remove prefixed "file://"
                        path = path.replace(/^(file:\/{2})/,"");
                        // unescape html codes like '%23' for '#'
                        binaryPath.text = decodeURIComponent(path);
                        fileDialogLoader.active = false;
                    }
                    onRejected: {
                        fileDialogLoader.active = false;
                    }
                    Component.onCompleted: open()
                }
            }
        }
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Polling rate (ms):")

        SpinBox {
            id: pollingRate
            from: 500
            to: 60000
            stepSize: 100
        }
    }
}

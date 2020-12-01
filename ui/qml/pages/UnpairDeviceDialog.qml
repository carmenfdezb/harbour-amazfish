import QtQuick 2.0
import uk.co.piggz.amazfish 1.0
import "../components"
import "../components/platform"

DialogPL {
    onAccepted: {
        DaemonInterfaceInstance.disconnect();
        pageStack.replace(Qt.resolvedUrl("./PairSelectDeviceType.qml"));
    }

    Column {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: styler.themePaddingMedium

        LabelPL {
            anchors {
                left: parent.left
                right: parent.right
                margins: styler.themeHorizontalPageMargin
            }
            //height: implicitHeight + Theme.paddingLarge
            text: qsTr("Unpair")
            font.pixelSize: styler.themeFontSizeExtraLarge
            wrapMode: Text.WordWrap
        }

        LabelPL {
            anchors {
                left: parent.left
                right: parent.right
                margins: styler.themeHorizontalPageMargin
            }
            text: qsTr("Before proceeding you need to unpair your current device.")
            //color: Theme.highlightColor
            wrapMode: Text.WordWrap
        }
    }
}

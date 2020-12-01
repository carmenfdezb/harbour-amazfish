import QtQuick 2.0
import org.SfietKonstantin.weatherfish 1.0
import uk.co.piggz.amazfish 1.0
import QtQuick.Layouts 1.1
import "../components/"
import "../components/platform"

PagePL {
    id: page
    title: "Amazfish"

    readonly property string _connectionState: DaemonInterfaceInstance.connectionState
    readonly property bool _disconnected: _connectionState === "disconnected"
    readonly property bool _connecting: _connectionState === "connecting"
    readonly property bool _connected: _connectionState === "connected"
    readonly property bool _authenticated: _connectionState === "authenticated"
    property int _steps: 0

    function _refreshInformation() {
        if (!_authenticated) {
            return
        }

        supportedFeatures = DaemonInterfaceInstance.supportedFeatures();
        console.log("Supported features", supportedFeatures);

        DaemonInterfaceInstance.refreshInformation();

        _steps = parseInt(DaemonInterfaceInstance.information(DaemonInterface.INFO_STEPS));
    }

    on_ConnectionStateChanged: console.log(_connectionState)

    on_AuthenticatedChanged: _refreshInformation()

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            text: qsTr("Pair with watch")
            onClicked: {
                var page = AmazfishConfig.pairedAddress
                        ? "UnpairDeviceDialog.qml"
                        : "PairSelectDeviceType.qml"
                pageStack.push(Qt.resolvedUrl(page))
            }
        }
        PageMenuItemPL {
            text: qsTr("Download File")
            onClicked: pageStack.push(Qt.resolvedUrl("BipFirmwarePage.qml"))
        }
        PageMenuItemPL {
            text: qsTr("Settings")
            onClicked: pageStack.push(Qt.resolvedUrl("Settings-menu.qml"))
        }
        PageMenuItemPL {
            text: qsTr("Data Graphs")
            onClicked: pageStack.push(Qt.resolvedUrl("AnalysisPage.qml"))
        }
        PageMenuItemPL {
            visible: AmazfishConfig.pairedAddress
            enabled: !_connecting
            text: _disconnected ? qsTr("Connect to watch") : qsTr("Disconnect from watch")
            onClicked: {
                if (_disconnected) {
                    DaemonInterfaceInstance.connectToDevice(AmazfishConfig.pairedAddress);
                } else {
                    DaemonInterfaceInstance.disconnect();
                }
            }
        }
    }

    Column {
        id: column
        spacing: styler.themePaddingLarge
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: styler.themePaddingMedium

        RowLayout {
            height: styler.themeItemSizeSmall
            width: parent.width

            LabelPL {
                id: pairedNameLabel
                text: AmazfishConfig.pairedName
                color: styler.themeSecondaryHighlightColor
                font.pixelSize: styler.themeFontSizeLarge
                truncMode: truncModes.fade
                Layout.fillWidth: true

            }

            IconPL {
                iconName: styler.iconBluetooth
                iconHeight: styler.themeIconSizeMedium
                visible: _connected || _authenticated || _connecting
                BusyIndicatorSmallPL {
                    visible: _connecting
                    running: visible
                    anchors.centerIn: parent
                }
            }

            IconPL {
                iconName: styler.iconWatch
                iconHeight: styler.themeIconSizeMedium
                visible: _authenticated || _connected
                BusyIndicatorSmallPL {
                    visible: _connected
                    running: visible
                    anchors.centerIn: parent
                }
            }

            IconPL {
                id: btryImage
                iconName: styler.iconBattery
                iconHeight: styler.themeIconSizeMedium
                visible: _authenticated
            }

            LabelPL {
                id: btryPercent
                visible: _authenticated
                font.pixelSize: styler.themeFontSizeMedium
                width: styler.themeIconSizeMedium
            }
        }


        SectionHeaderPL {
            text: qsTr("Steps")
            visible: supportsFeature(DaemonInterface.FEATURE_STEPS)
        }

        // steps
        IconPL {
            id: imgSteps
            iconName: styler.iconSteps
            height: styler.themeIconSizeMedium
            width: height
            visible: supportsFeature(DaemonInterface.FEATURE_STEPS)
        }

        PercentCircle {
            id: stpsCircle
            visible: supportsFeature(DaemonInterface.FEATURE_STEPS)
            anchors.horizontalCenter: parent.horizontalCenter
            size: parent.width - styler.themeHorizontalPageMargin * 4
            percent: _steps ? _steps / AmazfishConfig.profileFitnessGoal : 0.06
            widthRatio: 0.08

            Item {
                anchors.centerIn: parent
                height: lblSteps.height + lblGoal.height + styler.paddingSmall
                width: Math.max(lblSteps.width, lblGoal.width)

                LabelPL {
                    id: lblSteps
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: styler.themeHighlightColor
                    font.pixelSize: styler.themeFontSizeExtraLarge
                    verticalAlignment: Text.AlignVCenter
                    text: _steps.toLocaleString()
                }

                LabelPL {
                    id: lblGoal
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: lblSteps.bottom
                        topMargin: styler.themePaddingSmall
                    }
                    color: styler.themeSecondaryHighlightColor
                    font.pixelSize: styler.themeFontSizeLarge
                    verticalAlignment: Text.AlignVCenter
                    text: AmazfishConfig.profileFitnessGoal.toLocaleString()
                }
            }
        }

        SectionHeaderPL {
            text: qsTr("Heartrate")
            visible: supportsFeature(DaemonInterface.FEATURE_HRM)
        }

        //Heartrate
        RowLayout {
            spacing: styler.themePaddingLarge
            width: parent.width
            visible: supportsFeature(DaemonInterface.FEATURE_HRM)

            IconPL {
                id: imgHeartrate
                iconName: styler.iconHeartrate
                width: styler.themeIconSizeMedium
                height: width
            }
            LabelPL {
                id: lblHeartrate
                color: styler.themePrimaryColor
                font.pixelSize: styler.themeFontSizeLarge
                height: styler.iconSizeMedium
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }

            IconButtonPL {
                id: btnHR
                iconName: styler.iconRefresh
                iconHeight: styler.themeIconSizeMedium
                iconWidth: iconHeight
                onClicked: {
                    DaemonInterfaceInstance.requestManualHeartrate();
                }
            }
        }

        SectionHeaderPL {
            text: qsTr("Service")
            visible: !serviceActiveState || !serviceEnabledState
        }

        ButtonPL {
            text: qsTr("Start")
            visible: serviceActiveState == false
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                systemdServiceIface.call("Start", ["replace"])
            }
        }

        ButtonPL {
            text: qsTr("Enable")
            visible: serviceEnabledState == false
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: {
                systemdManager.enableService();
            }
        }

        Timer {
            id: tmrStartup
            running: true
            repeat: false
            interval: 500
            onTriggered: {
                pushAttached(Qt.resolvedUrl("StepsPage.qml"))
                if (!AmazfishConfig.profileName) {
                    pageStack.push(Qt.resolvedUrl("Settings-profile.qml"))
                }
            }
        }

        Connections {
            target: DaemonInterfaceInstance
            onInformationChanged: {
                console.log("Information changed", infoKey, infoValue);

                switch (infoKey) {
                case DaemonInterface.INFO_BATTERY:
                    btryPercent.text = qsTr("%1%").arg(infoValue)
                    break;
                case DaemonInterface.INFO_HEARTRATE:
                    lblHeartrate.text = qsTr("%1 bpm").arg(infoValue)
                    break;
                case DaemonInterface.INFO_STEPS:
                    _steps = parseInt(infoValue);
                    break;
                }
            }
        }
    }

    onPageStatusActive: {

    }

    Component.onCompleted: {
        if (AmazfishConfig.profileName) {
            _refreshInformation();
        }
        start();
    }

    function start() {
        app.rootPage = app.pages.replace(Qt.resolvedUrl("FirstPage.qml"));
        app.initialize();
    }
}

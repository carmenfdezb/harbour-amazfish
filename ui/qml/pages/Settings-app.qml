import QtQuick 2.0
import uk.co.piggz.amazfish 1.0
import "../components"
import "../components/platform"

PagePL {
    id: page
    title: qsTr("Application Settings")

    // Place our content in a Column.  The PageHeader is always placed at the top
    // of the page, followed by our content.
    Column {
        id: column
        spacing: styler.themePaddingLarge
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: styler.themePaddingMedium

        AdapterModel {
            id: adapters
        }

        ComboBoxPL {
            id: cboLocalAdapter
            model: adapters
            textRole: "path"
            label: qsTr("BT Adapter")
            Component.onCompleted: {
                cboLocalAdapter.value =  AmazfishConfig.localAdapter;
            }
        }

        SectionHeaderPL {
            visible: supportsFeature(DaemonInterface.FEATURE_ALERT)
            text: qsTr("Notifications")
        }

        TextSwitchPL {
            id: chkNotifyConnect
            visible: supportsFeature(DaemonInterface.FEATURE_ALERT)

            width: parent.width
            text: qsTr("Notify on connect")
        }

        TextSwitchPL {
            id: chkNotifyLowBattery
            visible: supportsFeature(DaemonInterface.FEATURE_ALERT)

            width: parent.width
            text: qsTr("Low battery notification")
        }

        TextSwitchPL {
            id: chkNavigationNotification
            visible: supportsFeature(DaemonInterface.FEATURE_ALERT)

            width: parent.width
            text: qsTr("Navigation notifications")
        }

        SectionHeaderPL {
            text: qsTr("Refresh rates")
        }

        TextSwitchPL {
            id: chkAutoSyncData
            width: parent.width
            text: qsTr("Sync activity data each hour")
        }

        SliderPL {
            id: sldWeatherRefresh
            visible: supportsFeature(DaemonInterface.FEATURE_WEATHER)

            width: parent.width
            minimumValue: 15
            maximumValue: 120
            stepSize: 15
            label: qsTr("Refresh weather every (") + value + qsTr(") minutes")
        }

        SliderPL {
            id: sldCalendarRefresh
            width: parent.width
            minimumValue: 15
            maximumValue: 240
            stepSize: 15
            label: qsTr("Refresh calendar every (") + value + qsTr(") minutes")
            visible: supportsFeature(DaemonInterface.FEATURE_EVENT_REMINDER)
        }

        SectionHeaderPL {
            text: qsTr("Amazfish Service")
        }

        TextSwitchPL {
            id: chkServiceEnabled
            checked: serviceEnabledState === false ? false : true
            text: qsTr("Start service on boot")
            onCheckedChanged: {
                if (serviceEnabledState) {
                    systemdManager.disableService();
                } else {
                    systemdManager.enableService();
                }
            }
        }

        LabelPL {
            width: parent.width
            text: qsTr("Start/Stop the Amazfish Background Service")
        }

        Row {
            id: serviceButtonRow

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: 10

            ButtonPL {
                id: start
                text: qsTr("Start")
                enabled: serviceActiveState ? false : true
                onClicked: {
                    systemdServiceIface.call("Start", ["replace"])
                }
            }

            ButtonPL {
                id: stop
                text: qsTr("Stop")
                enabled: serviceActiveState ? true : false
                onClicked: {
                    systemdServiceIface.call("Stop", ["replace"])
                }
            }
        }

        SectionHeaderPL {
        }

        ButtonPL {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Save Settings")
            onClicked: {
                saveSettings();
            }
        }
    }

    Component.onCompleted: {
        chkNotifyConnect.checked = AmazfishConfig.appNotifyConnect;
        sldWeatherRefresh.value = AmazfishConfig.appRefreshWeather;
        sldCalendarRefresh.value = AmazfishConfig.appRefreshCalendar;
        chkAutoSyncData.checked = AmazfishConfig.appAutoSyncData;
        chkNotifyLowBattery.checked = AmazfishConfig.appNotifyLowBattery;
        chkNavigationNotification.checked = AmazfishConfig.appNavigationNotification;
    }

    function saveSettings() {
        AmazfishConfig.appNotifyConnect = chkNotifyConnect.checked;
        AmazfishConfig.appRefreshWeather = sldWeatherRefresh.value;
        AmazfishConfig.appRefreshCalendar = sldCalendarRefresh.value;
        AmazfishConfig.appAutoSyncData = chkAutoSyncData.checked;
        AmazfishConfig.appNotifyLowBattery = chkNotifyLowBattery.checked;
        AmazfishConfig.appNavigationNotification = chkNavigationNotification.checked;
        AmazfishConfig.localAdapter = cboLocalAdapter.value;
    }

}

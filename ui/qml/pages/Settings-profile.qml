import QtQuick 2.0
import "../components/"
import "../components/platform"
import uk.co.piggz.amazfish 1.0

PagePL {
    id: page
    title: qsTr("Profile Settings")

    property string dob

    Column {
        id: column
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: styler.themePaddingMedium
        spacing: styler.themePaddingLarge

        SectionHeaderPL {
            text: qsTr("Personal data")
        }

        TextFieldPL {
            id: fldName
            label: qsTr("Name:")
            placeholderText: qsTr("Name:")
            width: parent.width
        }

        LabelPL {
            id: lblDOB
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Birthday")

        }
        ButtonPL {
            id: btnDOB
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - lblDOB.width - styler.themePaddingLarge
            text: new Date(page.dob).toLocaleDateString();

            onClicked: {
                var dialog = pageStack.push(pickerComponent, {
                                                date: new Date(AmazfishConfig.profileDOB)
                                            })
                dialog.accepted.connect(function() {
                    page.dob = dialog.date;
                })
            }

            Component {
                id: pickerComponent
                DatePickerDialogPL {}
            }
        }

        ComboBoxPL {
            id: cboGender
            width: parent.width
            label: qsTr("Gender")

            model: ListModel {
                ListElement {
                    text: qsTr("Male")
                }
                ListElement {
                    text: qsTr("Female")
                }
            }
        }
        SliderPL {
            id: sldHeight
            width: parent.width
            minimumValue: 50
            maximumValue: 250
            stepSize: 1
            label: qsTr("Height (cm): ") + value
        }
        SliderPL {
            id: sldWeight
            width: parent.width
            minimumValue: 50
            maximumValue: 200
            stepSize: 1
            label: qsTr("Weight (kg): ") + value
        }

        SectionHeaderPL {
            text: qsTr("Personal preferences")
        }

        ComboBoxPL {
            id: cboWearLocation
            width: parent.width
            label: qsTr("Wear Location")

            model: ListModel {
                ListElement {
                    text: qsTr("Left")
                }
                ListElement {
                    text: qsTr("Right")
                }
            }
        }

        TextSwitchPL {
            id: swDisplayOnLiftWrist
            width: parent.width
            text: qsTr("Display on lift wrist")
        }

        SliderPL {
            id: sldFitnessGoal
            width: parent.width
            minimumValue: 5000
            maximumValue: 30000
            stepSize: 100
            label: qsTr("Goal (steps): ") + value
        }


        TextSwitchPL {
            id: swAlertOnGoal
            width: parent.width
            text: qsTr("Alert on fitness goal")
        }

        SectionHeaderPL {
            text: qsTr("Heartrate usage")
        }

        TextSwitchPL {
            id: swHRMSleepSupport
            width: parent.width
            text: qsTr("Use HRM for Sleep Detection")
        }

        SliderPL {
            id: sldAllDayHRM
            width: parent.width

            minimumValue: 0
            maximumValue: 60
            stepSize: 1
            label: qsTr("All day HRM interval (minutes): ") + value
        }

        ButtonPL {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Save Profile")
            onClicked: {
                saveProfile();
            }
        }
    }

    Component.onCompleted: {
        fldName.text = AmazfishConfig.profileName;
        dob = AmazfishConfig.profileDOB;
        cboGender.currentIndex = AmazfishConfig.profileGender;
        sldHeight.value = AmazfishConfig.profileHeight;
        sldWeight.value = AmazfishConfig.profileWeight;
        cboWearLocation.currentIndex = AmazfishConfig.profileWearLocation;
        sldFitnessGoal.value = AmazfishConfig.profileFitnessGoal;
        swAlertOnGoal.checked = AmazfishConfig.profileAlertFitnessGoal;
        sldAllDayHRM.value = AmazfishConfig.profileAllDayHRM;
        swDisplayOnLiftWrist.checked = AmazfishConfig.profileDisplayOnLiftWrist;
        swHRMSleepSupport.checked = AmazfishConfig.profileHRMSleepSupport;
    }
    function saveProfile() {
        AmazfishConfig.profileName = fldName.text;
        AmazfishConfig.profileDOB = dob;
        AmazfishConfig.profileGender = cboGender.currentIndex;
        AmazfishConfig.profileHeight = sldHeight.value;
        AmazfishConfig.profileWeight = sldWeight.value;
        AmazfishConfig.profileWearLocation = cboWearLocation.currentIndex;
        AmazfishConfig.profileFitnessGoal = sldFitnessGoal.value;
        AmazfishConfig.profileAlertFitnessGoal = swAlertOnGoal.checked;
        AmazfishConfig.profileAllDayHRM = sldAllDayHRM.value;
        AmazfishConfig.profileDisplayOnLiftWrist = swDisplayOnLiftWrist.checked;
        AmazfishConfig.profileHRMSleepSupport = swHRMSleepSupport.checked;

        tmrSetDelay.start();
    }

    Timer {
        //Allow data to sync
        id: tmrSetDelay
        repeat: false
        interval: 500
        running: false
        onTriggered: {
            DaemonInterfaceInstance.applyDeviceSetting(DaemonInterface.SETTING_USER_PROFILE);
            DaemonInterfaceInstance.applyDeviceSetting(DaemonInterface.SETTING_USER_GOAL);
            DaemonInterfaceInstance.applyDeviceSetting(DaemonInterface.SETTING_USER_ALERT_GOAL);
            DaemonInterfaceInstance.applyDeviceSetting(DaemonInterface.SETTING_USER_DISPLAY_ON_LIFT);
            DaemonInterfaceInstance.applyDeviceSetting(DaemonInterface.SETTING_USER_ALL_DAY_HRM);
            DaemonInterfaceInstance.applyDeviceSetting(DaemonInterface.SETTING_USER_HRM_SLEEP_DETECTION)
        }
    }
}

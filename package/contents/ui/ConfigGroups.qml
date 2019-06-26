import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQml.Models 2.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.private.nxmenu 0.1 as NXMenu

import '../code/tools.js' as Tools

Item {
    property alias cfg_groupsJson: rawGroupJsonEdit.text;

    NXMenu.RootModel {
        id: rootModel
        groupsModel.json: cfg_groupsJson

        appNameFormat: plasmoid.configuration.appNameFormat
        flat: true
        showSeparators: false
        appletInterface: plasmoid

        showAllSubtree: true
    }

    Connections {
        target: rootModel.groupsModel
        onJsonChanged: cfg_groupsJson = rootModel.groupsModel.json
    }

    GridLayout {
        anchors.fill: parent
        anchors.rightMargin: 18
        columns: 2

        PlasmaExtras.ScrollArea {
            Layout.rowSpan: 2
            Layout.minimumWidth: 200
            Layout.fillHeight: true

            PlasmaCore.FrameSvgItem {
                anchors.fill: parent

                imagePath: "opaque/widgets/panel-background"
            }

            ListView {
                id: groupListView
                anchors.fill: parent

                property var currentGroup: rootModel.groupsModel.get(currentIndex);

                model: rootModel.groupsModel
                delegate: listItemDelegate

                highlightFollowsCurrentItem: true
                highlight: PlasmaComponents.Highlight {
                }

                RowLayout {
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }
                    PlasmaComponents.ToolButton {
                        iconName: "list-remove"
                        onClicked: rootModel.groupsModel.removeGroup(groupListView.currentGroup.id)
                    }

                    PlasmaComponents.ToolButton {
                        iconName: "list-add"
                        onClicked: rootModel.groupsModel.newGroup(Tools.randomId());
                    }

                }
            }
        }

        PlasmaComponents.TextField {
            id: groupTitle
            Layout.fillWidth: true
            placeholderText: i18n("Group title")
            enabled: groupListView.currentGroup !== undefined
            text: groupListView.currentGroup !== undefined ?
                      groupListView.currentGroup.name : ""
            onTextChanged: {
                if (groupListView.currentIndex > -1 ) {
                    var index = groupListView.model.index(groupListView.currentIndex, 0)

                    rootModel.groupsModel.setData(index, text, Qt.DisplayRole)
                    groupListView.model = rootModel.groupsModel
                }
            }
        }

        PlasmaExtras.ScrollArea {
            id: appsListViewScroll
            Layout.fillWidth: true
            Layout.fillHeight: true

            enabled: groupListView.currentGroup !== undefined

            PlasmaCore.FrameSvgItem {
                anchors.fill: parent

                imagePath: "opaque/widgets/panel-background"

                Popup {
                    id: newAppPopup
                    y: appsListViewScroll.height - groupListView.height
                    width: appsListViewScroll.width
                    height: groupListView.height
                    focus: true
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

                    background: PlasmaCore.FrameSvgItem {
                        anchors.fill: parent
                        imagePath: "opaque/dialogs/background"
                    }

                    PlasmaExtras.ScrollArea {
                        anchors.fill: parent
                        ListView {
                            id: newAppPopupListView
                            model: rootModel.allAppsModel

                            highlightFollowsCurrentItem: true
                            highlight: PlasmaComponents.Highlight {
                            }

                            delegate: PlasmaComponents.ListItem {
                                height: 40
                                RowLayout {
                                    anchors.fill: parent

                                    PlasmaCore.IconItem {
                                        Layout.fillHeight: true
                                        Layout.minimumWidth: 32
                                        Layout.maximumWidth: Layout.minimumWidth

                                        source: decoration
                                    }

                                    PlasmaComponents.Label {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        text: display
                                    }

                                    MouseArea {
                                        anchors.fill: parent

                                        hoverEnabled: true
                                        onContainsMouseChanged: {
                                            if (containsMouse) {
                                                newAppPopupListView.currentIndex = index
                                            }
                                        }
                                        onClicked: {
                                            newAppPopup.close()

                                            rootModel.groupsModel.addAppToGroup(groupListView.currentGroup.id,  model.favoriteId)
                                            appsListView.model = rootModel.groupsModel.groupApps(groupListView.currentGroup.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            ListView {
                id: appsListView
                anchors.fill: parent
                property var currentAppId;

                model: groupListView.currentGroup !== undefined ?
                           rootModel.groupsModel.groupApps(groupListView.currentGroup.id) : 0

                delegate:         PlasmaComponents.ListItem {
                    id: listItemRoot
                    height: 40
                    RowLayout {
                        anchors.fill: parent
                        PlasmaCore.IconItem {
                            Layout.fillHeight: true
                            Layout.minimumWidth: 32
                            Layout.maximumWidth: Layout.minimumWidth

                            source: decoration
                            visible: valid
                        }

                        PlasmaComponents.Label {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: display
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                listItemRoot.ListView.view.currentIndex = index
                                listItemRoot.ListView.view.currentAppId = model.favoriteId;
                            }
                        }
                    }
                }

                highlightFollowsCurrentItem: true
                highlight: PlasmaComponents.Highlight {
                }

                RowLayout {
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }
                    PlasmaComponents.ToolButton {
                        iconName: "list-remove"
                        onClicked: {
                            var index = appsListView.model.index(appsListView.currentIndex, 0)
                            var currentAppId = appsListView.model.data(index, appsListView.model.favoriteId);

                            rootModel.groupsModel.removeAppFromGroup(groupListView.currentGroup.id, appsListView.currentAppId)
                            appsListView.model = rootModel.groupsModel.groupApps(groupListView.currentGroup.id)
                        }
                    }

                    PlasmaComponents.ToolButton {
                        iconName: "list-add"

                        onClicked: newAppPopup.open()
                    }
                }
            }
        }

        PlasmaComponents.TextField {
            id: rawGroupJsonEdit
            Layout.fillWidth: true
            Layout.columnSpan: 2
            visible: false
        }
    }

    Component {
        id: listItemDelegate

        PlasmaComponents.ListItem {
            id: listItemRoot
            height: 40
            RowLayout {
                anchors.fill: parent
                PlasmaCore.IconItem {
                    Layout.fillHeight: true
                    Layout.minimumWidth: 32
                    Layout.maximumWidth: Layout.minimumWidth

                    source: decoration
                    visible: valid
                }

                PlasmaComponents.Label {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: display
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: listItemRoot.ListView.view.currentIndex = index
                }
            }
        }
    }
}

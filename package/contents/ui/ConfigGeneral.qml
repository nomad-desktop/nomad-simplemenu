/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.private.nxmenu 0.1 as NXMenu

Item {
    id: configGeneral

    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_useCustomButtonImage: useCustomButtonImage.checked
    property alias cfg_customButtonImage: customButtonImage.text

    property alias cfg_appNameFormat: appNameFormat.currentIndex

    property alias cfg_useExtraRunners: useExtraRunners.checked

    ColumnLayout {
        GroupBox {
            Layout.fillWidth: true

            title: i18n("Icon")

            flat: true

            RowLayout {
                CheckBox {
                    id: useCustomButtonImage

                    text: i18n("Use custom image:")
                }

                TextField {
                    id: customButtonImage

                    enabled: useCustomButtonImage.checked

                    Layout.fillWidth: true
                }

                Button {
                    iconName: "document-open"

                    enabled: useCustomButtonImage.checked

                    onClicked: {
                        imagePicker.folder = systemSettings.picturesLocation();
                        imagePicker.open();
                    }
                }

                FileDialog {
                    id: imagePicker

                    title: i18n("Choose an image")

                    selectFolder: false
                    selectMultiple: false

                    nameFilters: [ i18n("Image Files (*.png *.jpg *.jpeg *.bmp *.svg *.svgz)") ]

                    onFileUrlChanged: {
                        customButtonImage.text = fileUrl;
                    }
                }

                NXMenu.SystemSettings {
                    id: systemSettings
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Behavior")

            flat: true

            ColumnLayout {
                RowLayout {
                    Label {
                        text: i18n("Show applications as:")
                    }

                    ComboBox {
                        id: appNameFormat

                        Layout.fillWidth: true

                        model: [i18n("Name only"), i18n("Description only"), i18n("Name (Description)"), i18n("Description (Name)")]
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            title: i18n("Search")

            flat: true

            ColumnLayout {
                CheckBox {
                    id: useExtraRunners

                    text: i18n("Expand search to bookmarks, files and emails")
                }
            }
        }
    }
}

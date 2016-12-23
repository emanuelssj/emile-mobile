import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0

Drawer {
    id: menu
    width: window.width * 0.85; height: window.height
    dragMargin: enabled ? Qt.styleHints.startDragDistance : 0

    property bool enabled: true
    property color menuItemTextColor: "#ddd"
    property alias menuBackgroundColor: menuRectangle.color

    signal profileImageChange()

    function getIcon(parentItem, iconName, color) {
        var component = Qt.createComponent(Qt.resolvedUrl("AwesomeIcon/AwesomeIcon.qml"));
        component.createObject(parentItem, {"name":iconName,"color":color});
    }

    Connections {
        target: window
        onWidthChanged: menu.width = window.width * window.width > window.height ? 0.60 : 0.85
        onCurrentPageChanged: if (menu.visible) close();
    }

    Flickable {
        width: parent.width
        anchors.fill: parent
        contentHeight: Math.max(content.implicitHeight, height)
        boundsBehavior: Flickable.StopAtBounds

        // adicionado para exibir o scrool lateral
        Keys.onUpPressed: flickableScrollBar.decrease()
        Keys.onDownPressed: flickableScrollBar.increase()
        ScrollBar.vertical: ScrollBar { id: flickableScrollBar }

        Rectangle {
            id: menuRectangle
            anchors.fill: parent
            color: appSettings.theme.colorPrimary
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                id: content
                width: parent.width; anchors.fill: parent

                Image {
                    id: drawerImage
                    clip: true; cache: true; asynchronous: true
                    width: parent.width; fillMode: Image.PreserveAspectFit
                    source: "qrc:/assets/menu-temp.png"
                }

                Repeater {
                    model: menuPages

                    ListItem {
                        id: listItem
                        width: menu.width
                        primaryLabelColor: menuItemTextColor
                        primaryLabelText: modelData.menu_name
                        selected: modelData.menu_name === window.currentPage.objectName
                        primaryImageIcon: getIcon(primaryAction, modelData.icon_name, primaryLabelColor)
                        onClicked: {
                            menu.close();
                            if (!selected) {
                                var pageSource = "%1/%2".arg(modelData.configJson.root_folder).arg(modelData.main_qml);
                                pushPage(pageSource, {"configJson":modelData.configJson, "objectName": modelData.menu_name});
                            }
                        }
                    }
                }
            }
        }
    }
}

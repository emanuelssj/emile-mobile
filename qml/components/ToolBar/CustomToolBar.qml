import QtQuick 2.8
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import "../AwesomeIcon/" as Awesome

ToolBar {
    id: toolBar
    visible: window.menu && window.menu.enabled
    height: visible ? 50 : 0
    state: currentPage.toolBarState ? currentPage.toolBarState : "normal"
    states: [
        State {
            name: "normal"
            PropertyChanges { target: toolButtonDrawer; iconName: "bars"; action: "openMenu" }
        },
        State {
            name: "action"
            PropertyChanges { target: toolButtonDrawer; iconName: "arrow_left"; action: "cancel" }
        },
        State {
            name: "goback"
            PropertyChanges { target: toolButtonDrawer; iconName: "arrow_left"; action: "goback" }
        },
        State {
            name: "search"
            PropertyChanges { target: toolButtonDrawer; iconName: "arrow_left"; action: "cancel" }
            PropertyChanges { target: searchToolbar; visible: true }
        }
    ]

    property bool hasMenuList: false
    property string toolBarColor: appSettings.theme.colorPrimary
    property color defaultTextColor: appSettings.theme.colorAccent

    /**
     * a list of objects to the toolbar actions.
     * each page must be set the lists for the visible itens that will be use in the page
     * binding with ToolBar state. The object needs to be like this: {"action": "copy", "iconName": "copy", "when": "action"},
     */
    property var toolBarActions: []

    // emited when user click in any button from toolbar sending the action name
    signal actionExec(var actionName)

    // if current page defines a list of itens to submenu (the last item displayed in ToolBar),
    // the itens will be append into a dropdown list
    onActionExec: {
        if (actionName === "submenu" && optionsToolbarMenu != null)
            optionsToolbarMenu.open();
        else if (actionName === "goback" && (toolBar.state === "actions" || toolBar.state === "search"))
            toolBar.state = "normal";
        else if (actionName === "search" && toolBar.state === "normal")
            toolBar.state = "search";
        else if (actionName === "cancel" && toolBar.state === "search")
            toolBar.state = "normal";
        else if (currentPage.actionExec)
            currentPage.actionExec(actionName);
    }

    Loader {
        onLoaded: toolBar.background = item
        asynchronous: false; active: toolBarColor.length > 0
        sourceComponent: Rectangle {
            color: toolBarColor
            width: toolBar.width; height: toolBar.height - 2
            layer.enabled: true
            layer.effect: DropShadow {
                visible: toolBar.visible
                verticalOffset: 1; horizontalOffset: 0
                color: toolBarColor; spread: 0.3
                samples: 17
            }
        }
    }

    Connections {
        target: window.currentPage && window.currentPage.toolBarActions ? window.currentPage : null
        ignoreUnknownSignals: true
        onToolBarActionsChanged: if (currentPage.toolBarActions) toolBarActions = currentPage.toolBarActions;
    }

    Connections {
        target: window
        onPageChanged: {
            var fixBind = [];
            hasMenuList = false;
            toolBarActions = fixBind;
            searchToolbar.visible = false;

            if (currentPage.toolBarActions)
                toolBarActions = currentPage.toolBarActions;

            if (currentPage.toolBarMenuList && currentPage.toolBarMenuList.length > 0) {
                hasMenuList = true;
                optionsToolbarMenu.reset();
                for (var i = 0; i < currentPage.toolBarMenuList.length; i++)
                    optionsToolbarMenu.addItem(currentPage.toolBarMenuList[i]);
            }
        }
    }

    RowLayout {
        id: toolBarItens
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }

        CustomToolButton {
            id: toolButtonDrawer
            iconColor: defaultTextColor
        }

        Item {
            id: title
            width: visible ? parent.width * 0.55 : 0; height: parent.height
            visible: toolBar.state === "normal" || toolBar.state === "goback"
            anchors { left: toolButtonDrawer.right; leftMargin: 12; verticalCenter: parent.verticalCenter }

            Text {
                elide: Text.ElideRight
                text: currentPage.title || ""; color: defaultTextColor
                anchors.verticalCenter: parent.verticalCenter
                font { weight: Font.DemiBold; pointSize: appSettings.theme.bigFontSize }
            }
        }

        SearchToolbar {
            id: searchToolbar
            visible: toolBar.state == "search"; defaultTextColor: defaultTextColor
            onSearchTextChanged: if (currentPage.searchText) currentPage.searchText = searchToolbar.searchText
            anchors { left: title.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
        }

        CustomToolButton {
            id: toolButtonSave
            iconColor: defaultTextColor; action: "save"; iconName: "save"
            anchors.right: toolButtonDelete.left
            visible: toolBarActions.indexOf("save") !== -1 && (toolBar.state === "action" || toolBar.state === "goback")
        }

        CustomToolButton {
            id: toolButtonDelete
            iconColor: defaultTextColor; action: "delete"; iconName: "trash"
            anchors.right: toolButtonSearch.left
            visible: toolBarActions.indexOf("delete") !== -1 && (toolBar.state === "action" || toolBar.state === "goback")
        }

        CustomToolButton {
            id: toolButtonSearch
            iconColor: defaultTextColor; action: "search"; iconName: "search"
            anchors.right: toolButtonMenuList.left
            visible: toolBarActions.indexOf("search") !== -1 && (toolBar.state === "normal" || toolBar.state === "goback")
        }

        CustomToolButton {
            id: toolButtonMenuList
            iconColor: defaultTextColor; action: "submenu"; iconName: "ellipsis_v"
            anchors.right: parent.right
            visible: hasMenuList && (toolBar.state === "normal" || toolBar.state === "goback")

            Menu {
                id: optionsToolbarMenu
                x: parent ? (parent.width - width) : 0
                y: parent ? parent.height : 0
                transformOrigin: Menu.BottomRight

                function reset() {
                    for (var i = 0; i < optionsToolbarMenu.contentData.length; i++) {
                        optionsToolbarMenu.removeItem(0);
                        optionsToolbarMenu.removeItem(i);
                    }
                }
            }
        }
    }
}

import QtQuick 2.7
import QtQml.Models 2.2
import QtQuick.Controls 2.0

import "../../qml/js/Utils.js" as Util
import "../../qml/components/" as AppComponents

Page {
    id: page
    title: "My attendance"
    objectName: "My attendance"
    background: Rectangle{
        anchors.fill: parent
        color: appSettings.theme.colorWindowBackground
    }

    property var configJson: {}

    function request() {
        jsonListModel.debug = false;
        jsonListModel.source += "students_course_sections/" + userProfileData.id
        jsonListModel.load(function(response, status) {
            if (status !== 200)
                return;
            var i = 0;
            for (var prop in response) {
                while (i < response[prop].length) {
                    listModel.append(response[prop][i++]);
                }
            }
        });
    }

    Component.onCompleted: request();

    onConfigJsonChanged: {
        if (!configJson.index_fields.length) return
        var arrayTemp = []
        for (var i = 0; i < configJson.index_fields.length; i++)
            arrayTemp.push(configJson.index_fields[i])
        fieldsVisible = arrayTemp
    }

    Connections {
        target: window
        onPageChanged: if (currentPage.title === page.title) request();
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        visible: jsonListModel.state === "loading"
    }

    AppComponents.EmptyList {
        z: listView.z + 1
        visible: listView.count === 0 && !busyIndicator.visible
        onClicked: request()
    }

    Component {
        id: listViewDelegate

        AppComponents.ListItem {
            id: wrapper
            parent: listView.contentItem
            showSeparator: true
            badgeText: course.id
            primaryLabelText: name + ""
            secondaryLabelText: code + ""

            x: ListView.view.currentItem.x
            y: ListView.view.currentItem.y

            onClicked: pushPage(configJson.root_folder+"/FaltasPorDisciplina.qml", {"title": "Attendance in " + primaryLabelText, "courseId": id})
        }
    }

    ListView {
        id: listView
        width: page.width
        height: page.height
        focus: true
        model: ListModel { id: listModel }
        delegate: listViewDelegate
        cacheBuffer: width
        onRemoveChanged: update()
        Keys.onUpPressed: scrollBar.decrease()
        Keys.onDownPressed: scrollBar.increase()
        ScrollBar.vertical: ScrollBar { id: scrollBar }
    }
}

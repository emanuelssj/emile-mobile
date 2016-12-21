import QtQuick 2.7

Item {
    id: rootItem
    state: "null"
    states: [
        State {name: "null"},
        State {name: "ready"},
        State {name: "error"},
        State {name: "loading"}
    ]

    property int count
    property int httpStatus
    property bool debug: false
    property string source: ""
    property string errorString: ""
    property string requestParams: ""
    property string requestMethod: "GET"
    property string contentType: "application/x-www-form-urlencoded"
    property ListModel model

    QtObject {
        id: privateProperties
        property string json: ""
        onJsonChanged: updateJSONModel();
    }

    onStateChanged: {
        if (state === "ready" || state === "error") {
            source = ""
            requestParams = ""
            requestMethod = "GET"
            contentType = "application/x-www-form-urlencoded"
        }
    }

    function load() {
        var xhr = new XMLHttpRequest;
        xhr.open(requestMethod, (requestMethod === "GET") ? source + "?" + requestParams : source);
        xhr.setRequestHeader("Content-type", contentType);
        xhr.onerror = function() {
            rootItem.errorString = qsTr("Cannot connect to server!");
            rootItem.state = "error";
        }
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                rootItem.httpStatus = xhr.status;
                if (rootItem.httpStatus >= 200 && rootItem.httpStatus <= 299) {
                    // fix not state changed when result is a same of previous request!
                    privateProperties.json = "";
                    privateProperties.json = xhr.responseText;
                } else {
                    rootItem.errorString = qsTr("The server returned error ") + xhr.status;
                    rootItem.state = "error";
                }
                if (debug) {
                    console.log("xhr.status: " + xhr.status)
                    console.log("xhr.responseText: " + xhr.responseText)
                }
            }
        }
        xhr.send(requestParams);
        rootItem.errorString = "";
        rootItem.state = "loading";
    }

    function updateJSONModel() {
        if (model !== null && model.count > 0)
            model.clear();

        if (privateProperties.json === "") {
            rootItem.errorString = qsTr("The server returned an empty response!");
            rootItem.state = "error";
            return;
        }

        var objectArray = JSON.parse(privateProperties.json);
        for (var key in objectArray)
            mode.append(objectArray[key]);
        rootItem.state = "ready";
    }
}

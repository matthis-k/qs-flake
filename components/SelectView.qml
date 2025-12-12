import QtQuick
import QtQml

Item {
    id: root

    property var currentView
    property Item currentItem: null

    property var views: ({})

    implicitWidth: currentItem ? currentItem.implicitWidth : 0
    implicitHeight: currentItem ? currentItem.implicitHeight : 0

    default property alias definitions: root.data

    component Option: QtObject {
        id: option
        property string key
        property Item item
        property Component component
    }

    property bool _owned: false

    function _apply(value) {
        if (currentItem) {
            if (_owned) {
                currentItem.destroy();
            } else {
                if (currentItem.parent === root)
                    currentItem.parent = null;
                currentItem.visible = false;
            }
        }

        currentItem = null;
        _owned = false;

        if (!value)
            return;

        var item = null;

        if (value instanceof Component) {
            item = value.createObject(root);
            _owned = true;
        } else {
            item = value;
        }

        if (!item)
            return;

        item.parent = root;
        if (item.anchors)
            item.anchors.fill = root;
        item.visible = true;

        currentItem = item;
    }

    function refresh() {
        if (currentView) {
            _apply(views[currentView]);
        } else {
            _apply(null);
        }
    }

    onCurrentViewChanged: refresh()

    Component.onCompleted: {
        for (var i = 0; i < definitions.length; ++i) {
            var obj = definitions[i];
            if (!obj)
                continue;

            if (obj.key !== undefined && (obj.item || obj.component)) {
                var key = obj.key;
                var value = obj.component || obj.item;

                if (key && value) {
                    views[key] = value;
                }
            }
        }

        if (currentView) {
            refresh();
        }
    }
}

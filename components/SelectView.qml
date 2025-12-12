import QtQuick
import QtQml
import "../utils/types"

Item {
    id: root

    property string currentView: ""

    default property alias entries: views.entries
    readonly property SimpleMap map: views

    readonly property Item currentItem: _currentItem

    property Item _currentItem: null
    property bool _owned: false

    implicitWidth: _currentItem ? _currentItem.implicitWidth : 0
    implicitHeight: _currentItem ? _currentItem.implicitHeight : 0

    SimpleMap {
        id: views
    }

    onCurrentViewChanged: _sync()
    Connections {
        target: views
        function onReactiveChanged() {
            root._sync();
        }
    }
    Component.onCompleted: _sync()

    function _sync() {
        const value = currentView ? views.get(currentView) : undefined;
        _currentItem = _apply(value);
    }

    function _apply(value) {
        if (_currentItem) {
            if (_owned) {
                _currentItem.destroy();
            } else {
                if (_currentItem.parent === root)
                    _currentItem.parent = null;
                _currentItem.visible = false;
            }
        }

        _owned = false;

        if (!value)
            return null;

        var item = null;
        if (value instanceof Component) {
            item = value.createObject(root);
            _owned = true;
        } else {
            item = value;
        }

        if (!item)
            return null;

        item.parent = root;
        if (item.anchors)
            item.anchors.fill = root;
        item.visible = true;

        return item;
    }

    function get(key, def) {
        return views.get(key, def);
    }
    function has(key) {
        return views.has(key);
    }
    function keys() {
        return views.keys();
    }
    function values() {
        return views.values();
    }
    function insert(key, val) {
        return views.insert(key, val);
    }
    function remove(key) {
        return views.remove(key);
    }
    function clear() {
        return views.clear();
    }
}

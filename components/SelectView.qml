import QtQuick
import QtQml
import "../utils/types"

Item {
    id: root

    property string currentView: ""
    property Item currentItem: null

    implicitWidth: currentItem ? currentItem.implicitWidth : 0
    implicitHeight: currentItem ? currentItem.implicitHeight : 0

    default property alias entries: views.entries
    property var initProps

    SimpleMap {
        id: views
    }

    property var _selectedValue: currentView ? views.get(currentView) : undefined

    property bool _owned: false

    on_SelectedValueChanged: {
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

        if (!_selectedValue)
            return;

        var item = null;

        if (_selectedValue instanceof Component) {
            item = _selectedValue.createObject(root, initProps);
            initProps = undefined;
            _owned = true;
        } else {
            item = _selectedValue;
        }

        if (!item)
            return;

        item.parent = root;
        if (item.anchors)
            item.anchors.fill = root;
        item.visible = true;

        currentItem = item;
    }

    function get(key, defaultValue) {
        return views.get(key, defaultValue);
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

    function getEntry(key) {
        return views.getEntry(key);
    }
    function insert(key, value) {
        return views.insert(key, value);
    }
    function remove(key) {
        return views.remove(key);
    }
    function clear() {
        return views.clear();
    }
}

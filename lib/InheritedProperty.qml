import QtQuick

Item {
    Component.onCompleted: {
        if (parent) {
            parent.inheritanceNode = this;
        }
    }

    function lookup(propertyName) {
        if (this.hasOwnProperty(propertyName)) {
            return this[propertyName];
        }
        if (parent && parent.inheritanceNode && parent.inheritanceNode !== this) {
            return parent.inheritanceNode.lookup(propertyName);
        }
        return undefined;
    }
}
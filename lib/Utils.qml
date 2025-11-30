pragma Singleton
import Quickshell

Singleton {
    function findRootObject(obj) {
        if (obj && typeof obj.screen !== "undefined") {
            return obj;
        }
        if (obj && obj.parent) {
            return findRootObject(obj.parent);
        }
        return null;
    }
}

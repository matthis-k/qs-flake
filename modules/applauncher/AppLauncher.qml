import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../components"
import "../../services"
import "../../utils"
import "../../utils/types"
import "."

SelectView {
    id: view
    currentView: "appsearch"

    SimpleMap.Entry {
        key: "appsearch"
        value: AppSearch {
            view: view
            closeHandler: closeLauncher
        }
    }

    property var _desktopEntry
    function openDetails(desktopEntry: DesktopEntry) {
        view.initProps = {
            view: view,
            desktopEntry: desktopEntry
        };
        view.insert("details", detailsFactory);
        view.currentView = "details";
    }

    function closeDetails() {
        view.currentView = "appsearch";
        view.currentItem.searchTerm = "";
        view.currentItem.onEnter();
        view.remove("details");
        _desktopEntry = undefined;
    }

    function closeLauncher() {
        ShellState.getScreenByName(screen.name).appLauncher.close();
    }

    property Component detailsFactory: Component {
        AppDetails {}
    }
}

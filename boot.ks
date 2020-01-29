@lazyglobal off.

set terminal:width to 60.
set terminal:height to 40.

function ThrowException {
    parameter msg.

    print "[ERROR] " + msg + "".
    abort.
}

function LogInfo {
    parameter msg.
    print "[INFO] " + msg + "".
}

function import {
    parameter name.

    if not exists(name) {
        ThrowException("Failed to find a module named '" + name + "'.").
    }

    runoncepath(name).
}

function BootLoader {

    local DISK is core:volume.
    local CON is core:connection.

    // Uploads the files in [path] to the HD storage.
    function uploadFiles {
        parameter path.

        if not exists(path) {
            ThrowException("The folder " + path + " does not exist.").
        }

        cd(path).

        local copyok is true.
        local fileList is list().
        list files in fileList.
        for f in fileList {
            if f:name = ".git" {
                LogInfo("Skipping git folder.").
            }
            else {
                if not copypath(f, DISK) { copyok off. }.
                LogInfo("Uploaded file: " + f:name + " - " + round(f:size) + "B").
            }
        }
    }

    function connect {
        LogInfo("Connecting to KSC network...").
        wait 0.5.

        if CON:isconnected {
            LogInfo("Connected successfully to KSC.").
        } else {
            ThrowException("Failed to connect to KSC network.").
        }
    }

    function boot {
        parameter startupCommand is "init".

        LogInfo("Booting...").
        wait 0.25.

        runpath(startupCommand).
    }

    return lexicon(
        "uploadFiles", uploadFiles@,
        "connect", connect@,
        "boot", boot@
    ).
}
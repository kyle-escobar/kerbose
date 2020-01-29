@lazyglobal off.

set terminal:width to 60.
set terminal:height to 40.

function ThrowException {
    parameter msg.

    print "[ERROR] " + msg + "".
    reboot.
}

function LogInfo {
    parameter msg.
    print "[INFO] " + msg + "".
}

function import {
    parameter name.

    if not exists(name + ".ks") {
        ThrowException("Failed to find a module named '" + name + "'.").
    }

    runoncepath(name).
}

function BootLoader {

    local DISK is core:volume.
    local CON is core:connection.

    local function getFiles {
        local parameter path.

        if not exists(path) {
            ThrowException("Path " + path + " does not exist.").
        }

        local fileList is list().

        local fileLayer is list().
        list files in fileLayer.

        for f in fileLayer {
            if f:name:endswith(".ks") {
                fileList:add(f).
            } else if not f:isfile {
                cd(f:name).
                local subFiles is getFiles(path).
                for f in subFiles {
                    copypath(f, "../").
                    fileList:add(f).
                }
                cd("../").
            }
        }

        return fileList.
    }

    // Uploads the files in [path] to the HD storage.
    function uploadFiles {
        parameter path.

        if not exists(path) {
            ThrowException("The folder " + path + " does not exist.").
        }

        cd(path).

        local copySuccess is true.
        local fSize is 0.
        local fileList is getFiles(path).

        for f in fileList {
            if f:name:endswith(".ks") {
                set fSize to fSize + f:size.
            }
        }

        if DISK:freespace >= fSize {
            LogInfo("Uploading libary files to flight computer.").

            for f in fileList {
                if f:name:endswith(".ks") {
                    if not copypath(f, DISK) { copySuccess off. }.
                    LogInfo("Uploaded file: " + f:name + " - " + round(f:size) + "B").
                }
            }

            if copySuccess {
                LogInfo("Completed uploading files successfully.").
            } else {
                ThrowException("Failed to upload files to flight computer.").
            }
        } else {
            ThrowException("Failed to upload files to flight computer. Not enough DISK space.").
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
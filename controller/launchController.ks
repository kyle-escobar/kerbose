@lazyglobal off.

// Controls the launch sequence.
function LaunchController {

    import("controller/StageController").

    // ----- [ VARIABLE DECLARATIONS ] ----------
    local TARGET_ALT is 0.
    local LAUNCH_DIR is 90.
    local state is "PRE LAUNCH".
    local stageController is 0.

    // Calculates the rotation profile for flight.
    local function defaultRotation {
        if abs(ship:facing:roll - 180 - LAUNCH_DIR) < 30 return 0.
        return 180.
    }

    // Setting for kerbin for calculating the start and end of gravity turn.
    local launch_gt0 is body:atm:height * 0.007. // 500m
    local launch_gt1 is body:atm:height * 0.6. // 42km

    // ----- [ FLAGS ] ----------
    local FLAG_Staging is false.

    // ----- [ HELPERS ] ----------

    // Gets the launch steering.
    function getSteering {
        local gravityTurnPercent is min(1, max(0, (ship:altitude - launch_gt0) / (launch_gt1 - launch_gt0))).
        local pitch is arccos(gravityTurnPercent).
        return heading (LAUNCH_DIR, pitch) * R(0, 0, defaultRotation).
    }

    // Gets the launch throttle.
    function getThrottle {
        local aoa is vdot(ship:facing:vector, ship:velocity:surface).
        local atmHeightPercent is ship:altitude / (body:atm:height + 1).
        local speed is ship:airspeed.
        local cutoff is 200 + (400 * max(0, (atmHeightPercent * 3))).

        if speed > cutoff {
            // Going to fast.
            return 1 - max(0.1, ((speed - cutoff) / cutoff)).
        } else {
            // Ease throttle.
            local ApoPercent is ship:apoapsis / TARGET_ALT.
            local ApoCompensation is 0.

            if ApoPercent > 0.9 {
                set ApoCompensation to (ApoPercent - 0.9) * 10.
            }

            return 1.05 - min(1, max(0, ApoCompensation)).
        }
    }

    // ----- [ ACTIONS ] ----------

    // Executes the launch.
    function launch {
        // Check if we need to setup staging.
        if FLAG_Staging = true {
            set stageController to StageController().
        }

        sas off.
        rcs off.

        lock steering to getSteering().
        lock throttle to getThrottle().

        until ship:apoapsis >= TARGET_ALT {
            wait 0.001.
        }
    }

    // ----- [SETTINGS / SETTERS ] ----------

    function setTargetAltitude {
        parameter value.
        set TARGET_ALT to value.
    }

    function setLaunchDirection {
        parameter value.
        set LAUNCH_DIR to value.
    }

    function enableStaging {
        parameter value.
        set FLAG_Staging to value.
    }

    function getTargetAltitude { return TARGET_ALT. }
    function getLaunchDirection { return LAUNCH_DIR. }
    function getState { return state. }
    function isStagingEnabled { return FLAG_Staging. }
    function getStageController { return stageController. }

    // ----- [ END ] ----------

    return lexicon(
        "launch", launch@,
        "setTargetAltitude", setTargetAltitude@,
        "setLaunchDirection", setLaunchDirection@,
        "enableStaging", enableStaging@,
        "isStagingEnabled", isStagingEnabled@,
        "getTargetAltitude", getTargetAltitude@,
        "getLaunchDirection", getLaunchDirection@,
        "getState", getState@,
        "getThrottle", getThrottle@,
        "getSteering", getSteering@,
        "getStageController", getStageController@
    ).
}
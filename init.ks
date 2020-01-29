clearscreen.

import("LaunchController").

print "Starting launch.".
local launchController is LaunchController().

launchController["setTargetAltitude"](100000).

print "Alt: " + launchController["getTargetAltitude"]().
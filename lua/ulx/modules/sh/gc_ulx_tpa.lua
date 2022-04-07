-- ULX command and handling
function ulx.tpa(caller, target)
    if SERVER then
        if target:IsInWorld() && !target:InVehicle() && util.IsInWorld(target:GetPos() - (target:GetAngles():Forward() * 100) then
            net.Start("ulx_tpa_request")
            net.WriteEntity(caller)
            net.Send(target)
        else
            ULib.tsayError(caller, target:Name() .. " is in unreachable place!.", true)
        end
    end
end
local ulx_tpa = ulx.command("Teleport", "ulx tpa", ulx.tpa, "!tpa")
ulx_tpa:addParam{type=ULib.cmds.PlayerArg, target="!^", ULib.cmds.ignoreCanTarget}
ulx_tpa:defaultAccess(ULib.ACCESS_ALL)
print("added command to ulx lol")

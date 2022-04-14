-- These Networks are required to make plugin work
-- 1. Network is a empty message sent to the target to initialize tpa GUI
-- 2. Network is a message with boolean (after choosing option in GUI or timeouting) and the caller entity sent from target to the server if caller is allowed to teleport
util.AddNetworkString("ulx_tpa_request")
util.AddNetworkString("ulx_tpa_response")

local function handle_tpa_responce(len, ply)
    local tAnwser = net.ReadBool()
    local caller = net.ReadEntity()

    if tAnwser then
        caller:SetPos(ply:GetPos() - (ply:GetAngles():Forward() * 100))
    else
        ULib.tsayError(caller, ply:Name() .. " declined your tpa request.", true)
    end
end

-- Handling responce sent from the target
net.Receive("ulx_tpa_response", handle_tpa_responce)


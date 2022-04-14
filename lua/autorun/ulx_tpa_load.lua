if SERVER then
    AddCSLuaFile("gc_tpa/client.lua")
    include("gc_tpa/server.lua")
end
if CLIENT then
    include("gc_tpa/client.lua")
end

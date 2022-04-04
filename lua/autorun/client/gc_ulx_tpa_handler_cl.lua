-- Table to hold additional incoming requests
local requestQueueTable = {}

-- local variables for our GUI elements and current state
local window, usertext, text, bYes, bNo, gui_state, timer_local, timer_text, mouse_status

curr_player = nil
gui_state = false
timer_local = 30
mouse_status = false

-- Handling request sent from the caller
net.Receive("ulx_tpa_request", function(len, ply)
    curr_player = net.ReadEntity()
    if !gui_state then
        ulx_request_gui_handling(curr_player)
    else
        table.insert(requestQueueTable, curr_player)
    end
end)

-- Function that creates our request GUI and handles it
function ulx_request_gui_handling(ply)
    -- Setting state to true so that we dont draw oncoming requests
    gui_state = true
    -- Set function argument to local variable beacuse passed by argument isnt accessible in timer, OnClose and DoClick spectrum (or im stupid)
    curr_player = ply

    -- Timeout
    timer.Create("ulx_tpa_timeout", 30, 1, function()
        net.Start("ulx_tpa_response")
        net.WriteBool(false)
        net.WriteEntity(curr_player)
        net.SendToServer()
        checkQueue()
    end)

    timer.Create("ulx_tpa_local_timer", 1, 30, function()
        timer_local = timer_local - 1
        timer_text:SetText("Time left: " .. timer_local .. "s")
        timer_text:SizeToContents()
        timer_text:SetContentAlignment(4)
        if timer_local == 0 then
            timer_local = 30
        end
    end)

    -- Create GUI elements if local variables are empty
    if window == nil && text == nil && bYes == nil && bNo == nil && timer_text == nil then

        window = vgui.Create("DPanel")
        usertext = vgui.Create("DLabel", window)
        text = vgui.Create("DLabel", window)
        bYes = vgui.Create("DButton", window)
        bNo = vgui.Create("DButton", window)
        timer_text = vgui.Create("DLabel", window)

        window:SetBackgroundColor(Color(0, 0, 0, 176))
        window:SetPos((ScrW() / 2) - 100, 40)
        window:SetSize(300,105)

        -- Do stuff when frame was closed
        window.OnClose = function(s, w, h)
            net.Start("ulx_tpa_response")
            net.WriteBool(false)
            net.WriteEntity(curr_player)
            net.SendToServer()

             if timer.Exists("ulx_tpa_timeout") && timer.Exists("ulx_tpa_local_timer")then
                timer.Remove("ulx_tpa_timeout")
                timer.Remove("ulx_tpa_local_timer")
            end

            checkQueue()
        end

        usertext:SetColor(Color(255,255,255))
        usertext:SetFont("ChatFont")
        usertext:SetText(curr_player:Name())
        usertext:SizeToContents()
        usertext:SetContentAlignment(5)
        usertext:SetPos((window:GetWide() / 2) - (usertext:GetWide() / 2), 10)

        text:SetColor(Color(255,255,255))
        text:SetFont("ChatFont")
        text:SetText("sent you a teleport request")
        text:SizeToContents()
        text:SetContentAlignment(5)
        text:SetPos((window:GetWide() / 2) - (text:GetWide() / 2), 25)

        bYes:SetColor(Color(255,255,255))
        bYes:SetFont("ChatFont")
        bYes:SetText("Accept")
        bYes:SetPos((window:GetWide() / 2) + ((window:GetWide() / 2) / 2) - (bYes:GetWide() / 2), 50)

        -- Do stuff when accept was clicked
        bYes.DoClick = function(s, w, h)
            net.Start("ulx_tpa_response")
            net.WriteBool(true)
            net.WriteEntity(curr_player)
            net.SendToServer()

            if timer.Exists("ulx_tpa_timeout") && timer.Exists("ulx_tpa_local_timer")then
                timer.Remove("ulx_tpa_timeout")
                timer.Remove("ulx_tpa_local_timer")
            end

            checkQueue()
        end

        bYes.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 200, 0))
        end

        bNo:SetColor(Color(255,255,255))
        bNo:SetFont("ChatFont")
        bNo:SetText("Decline")
        bNo:SetPos((window:GetWide() / 2) - ((window:GetWide() / 2) / 2) - (bYes:GetWide() / 2), 50)

        -- Do stuff when decline was clicked
        bNo.DoClick = function(s, w, h)
            net.Start("ulx_tpa_response")
            net.WriteBool(false)
            net.WriteEntity(curr_player)
            net.SendToServer()

            if timer.Exists("ulx_tpa_timeout") && timer.Exists("ulx_tpa_local_timer")then
                timer.Remove("ulx_tpa_timeout")
                timer.Remove("ulx_tpa_local_timer")
            end

            checkQueue()
        end

        bNo.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(200, 0, 0))
        end

        timer_text:SetColor(Color(255,255,255))
        timer_text:SetFont("ChatFont")
        timer_text:SetText("Time left: 30s")
        timer_text:SizeToContents()
        timer_text:SetContentAlignment(4)
        timer_text:SetPos((window:GetWide() / 2) - (timer_text:GetWide() / 2), 80)


    else
        -- Update existing GUI elements
        usertext:SetText(curr_player:Name())
        usertext:SetPos((window:GetWide() / 2) - (usertext:GetWide() / 2), 10)
        usertext:SizeToContents()
        usertext:SetContentAlignment(5)

        timer_text:SetText("Time left: 30s")
        timer_text:SizeToContents()
        timer_text:SetContentAlignment(4)

    end
end

-- Function to call ulx_request_gui_handling if queue is not empty
function checkQueue()
    -- Remove timer in case overwritten DoClick or DoClose function didnt do that (Security thing)
    if timer.Exists("ulx_tpa_timeout") then
        timer.Remove("ulx_tpa_timeout")
    end

    curr_player = nil

    if #requestQueueTable > 0 then
        ulx_request_gui_handling(requestQueueTable[1])
        table.remove(requestQueueTable, 1)
    else
        gui_state = false
        window:Remove()
        window = nil
        text = nil
        bYes = nil
        bNo = nil
        timer_text = nil
        return
    end
end

-- Only way to use it with mouse
hook.Add("PlayerButtonDown", "ulx_tpa_request_clicker", function(ply, butt)
    if ply == LocalPlayer() && butt == KEY_F3 then
        if !mouse_status then
            mouse_status = true
            gui.EnableScreenClicker(true)
        else
            mouse_status = false
            gui.EnableScreenClicker(false)
        end
    end
end)

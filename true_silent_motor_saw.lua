local SILENT_MOTOR_PART_ID = "wpn_fps_saw_body_silent"

local RADIUS_METERS = 5
local CLAMP_RADIUS = RADIUS_METERS * 100

local function table_contains(t, v)
    if type(t) ~= "table" then return false end
    for i = 1, #t do
        if t[i] == v then return true end
    end
    return false
end

local function is_saw_with_silent_motor(player_unit)
    if not alive(player_unit) then return false end

    local inv = player_unit:inventory()
    local wpn = inv and inv:equipped_unit()
    if not alive(wpn) then return false end

    local wbase = wpn:base()
    if not wbase then return false end

    local td = wbase.weapon_tweak_data and wbase:weapon_tweak_data()
    local cats = td and td.categories
    if not table_contains(cats, "saw") then
        return false
    end

    local bp = wbase._blueprint
    if type(bp) ~= "table" and wbase.blueprint then
        local ok, res = pcall(function() return wbase:blueprint() end)
        if ok then bp = res end
    end

    return table_contains(bp, SILENT_MOTOR_PART_ID)
end

local orig_propagate_alert = GroupAIStateBase.propagate_alert
function GroupAIStateBase:propagate_alert(alert_data, ...)
    if type(alert_data) == "table" then
        local player_unit = managers.player and managers.player:player_unit()
        if is_saw_with_silent_motor(player_unit) then
            local radius = alert_data[3]
            if type(radius) == "number" then
                if radius > CLAMP_RADIUS then
                    alert_data[3] = CLAMP_RADIUS
                end
            else
                alert_data[3] = CLAMP_RADIUS
            end
        end
    end

    return orig_propagate_alert(self, alert_data, ...)
end
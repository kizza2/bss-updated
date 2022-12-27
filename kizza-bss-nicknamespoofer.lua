local new_name = "Me" 
local new_id = 1 -- Set other ^_^
local clear_avatar = false -- So no one can reverse search by your outfit
local flush_body_colors = true -- So no one can reverse search by your bodycolors
local rename_instances = false -- Rename any instances that holds your name. (Not recomended unless you can see your name above your character)
local change_id = true -- Change your player ID (not visually)
local deep_scan = true -- Can get a bit laggy if there is a mass wave of new instances
local filter_httpget = { -- Didn't seem like this would be helpful, but requested.
    enabled = false, -- Turn on
    result = true, -- Filter the results of the request
    request = true -- Filter the url before requesting
}


local Players = assert(assert(game, "game missing?"):FindService("Players") or game:GetService("Players"), "Players missing?")
local LocalPlayer = assert(Players.LocalPlayer, "LocalPlayer missing?")
local CoreGui = game:FindService("CoreGui") or game:GetService("CoreGui")
local PlayerGui = assert(LocalPlayer:FindFirstChild("PlayerGui"), "PlayerGui mising?")
local RunService = assert(game:FindService("RunService") or game:GetService("RunService"), "RunService missing?")
local replaces_str = {
    Players.LocalPlayer.Name
}
local replaces_num = {
    tostring(Players.LocalPlayer.UserId)
}
new_name, new_id = tostring(new_name), tostring(new_id)
local function casepatt(pattern)
    return string.gsub(pattern, "(%%?)(.)", function(percent, letter)
        if percent ~= "" or not string.match(letter, "%a") then
            return percent .. letter
        else
            return string.format("[%s%s]", string.lower(letter), string.upper(letter))
        end
    end)
end
function replace(item, fast)
    for replacewith, data in pairs({
        [new_name] = replaces_str,
        [new_id] = replaces_num
    }) do
        if not fast then
            RunService.RenderStepped:Wait()
        end
        for _, v in pairs(data) do
            if not fast then
                RunService.RenderStepped:Wait()
            end
            for _, t in pairs({
                "Text",
                "Message",
                "ToolTip",
                "Value"
            }) do
                pcall(function()
                    if string.find(item[t], v, nil, true) then
                        item[t] = string.gsub(item[t], v, replacewith)
                    elseif string.find(item[t], string.lower(v), nil, true) then
                        item[t] = string.gsub(item[v], string.lower(v), string.lower(replacewith))
                    elseif string.find(item[t], string.upper(v), nil, true) then
                        item[t] = string.gsub(item[v], string.upper(v), string.upper(replacewith))
                    elseif string.find(string.lower(item[t]), string.lower(v), nil, true) then
                        item[t] = string.gsub(item[v], casepatt(v), replacewith)
                    end
                end)
                if not fast then
                    RunService.RenderStepped:Wait()
                end
            end
            if not fast then
                RunService.RenderStepped:Wait()
            end
            if rename_instances then
                pcall(function()
                    if string.find(item.Name, v, nil, true) then
                        item.Name = string.gsub(item.Name, v, replacewith)
                    elseif string.find(item.Name, string.lower(v), nil, true) then
                        item.Name = string.gsub(item.Name, string.lower(v), string.lower(replacewith))
                    elseif string.find(item.Name, string.upper(v), nil, true) then
                        item.Name = string.gsub(item.Name, string.lower(v), string.upper(replacewith))
                    elseif string.find(string.lower(item.Name), string.lower(v), nil, true) then
                        item.Name = string.gsub(item.Name, casepatt(v), replacewith)
                    end
                end)
            end
        end
    end
end
shared.rep = replace
local function scan_and_replace(fast)
    local scan_que = {
        CoreGui:GetDescendants(),
        PlayerGui:GetDescendants(),
        workspace:GetDescendants()
    }
    local last_break = 0
    for _, items in pairs(scan_que) do
        if not fast then
            RunService.RenderStepped:Wait()
        end
        for _, gui in pairs(assert(type(items) == "table" and items, "scan_que does not hold a table")) do
            last_break = 1 + last_break
            if last_break >= 6000 then
                RunService.RenderStepped:Wait()
                last_break = 0
            end
            if not fast then
                RunService.RenderStepped:Wait()
            end
            replace(gui, fast)
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if not fast then
            RunService.RenderStepped:Wait()
        end
        replace(obj)
    end
end
function fixchar(Character)
    if not Character then
        return 
    end
	wait(0.2)
    RunService.RenderStepped:Wait()
    if rename_instances then
        Character.Name = new_name
    end
	if clear_avatar then
    	Players.LocalPlayer:ClearCharacterAppearance()
	end
    wait(0.1)
    if flush_body_colors then
        local bc = Character:FindFirstChildOfClass("BodyColors")
        if bc then
            for _, c in pairs({
                "HeadColor",
                "LeftArmColor",
                "LeftLegColor",
                "RightArmColor",
                "RightLegColor",
                "TorsoColor"
            }) do
                bc[c] = (typeof(bc[c]) == "BrickColor" and BrickColor.Random()) or bc[c]
            end
        else
            local h = Character:FindFirstChildOfClass("Humanoid")
            if h then
                for _, limb in pairs(Character:GetChildren()) do
                    if limb:IsA("BasePart") and pcall(h.GetLimb, h, limb) then
                        limb.BrickColor = BrickColor.Random()
                    end
                end
            end
        end
    end
end
fixchar(Players.LocalPlayer.Character)
Players.LocalPlayer.CharacterAppearanceLoaded:Connect(fixchar)
Players.LocalPlayer.CharacterAdded:Connect(fixchar)
if deep_scan then
    game.ItemChanged:Connect(function(obj, property)
        if not rename_instances and "Name" == property then
            return 
        end
        local s, v = pcall(function()
            return obj[property]
        end)
        if s then
            if "string" == type(v) then
                for _, c in pairs(replaces_str) do
                    RunService.RenderStepped:Wait()
                    if string.find(obj[property], c, nil, true) then
                        obj[property] = string.gsub(tostring(obj[property] or v), c, new_name)
                    elseif string.find(obj[property], string.lower(c)) then
                        obj[property] = string.gsub(tostring(obj[property] or v), string.lower(c), string.lower(new_name))
                    elseif string.find(obj[property], string.upper(c), nil, true) then
                        obj[property] = string.gsub(tostring(obj[property] or v), string.upper(c), string.upper(new_name))
                    elseif string.find(string.upper(obj[property]), string.upper(c), nil, true) then
                        obj[property] = string.gsub(tostring(obj[property] or v), casepatt(c), new_name)
                    end
                end
                RunService.RenderStepped:Wait()
                for _, c in pairs(replaces_num) do
                    RunService.RenderStepped:Wait()
                    if string.find(obj[property], new_id) then
                        obj[property] = string.gsub(tostring(obj[property] or v), c, new_id)
                    end
                end
            elseif "number" == type(v) then
                v = tostring(obj[property] or v)
                for _, c in pairs(replaces_num) do
                    RunService.RenderStepped:Wait()
                    if string.find(v, c) then
                        obj[property] = tonumber(tonumber(string.gsub(v, c, new_id) or obj[property]) or obj[property])
                    end
                end
            end
        end
    end)
    CoreGui.DescendantAdded:Connect(replace)
    PlayerGui.DescendantAdded:Connect(replace)
end
local function filterstr(s)
    for _, data in pairs({
        [new_name] = replaces_str,
        [new_id] = replaces_num
    }) do
        for c, v in pairs(data) do
            if string.find(s, v, nil, true) then
                s = string.gsub(s, v, c)
            elseif string.find(s, string.lower(v), nil, true) then
                s = string.gsub(s, string.lower(v), string.lower(c))
            elseif string.find(s, string.upper(v), nil, true) then
                s = string.gsub(s, string.upper(v), string.upper(c))
            elseif string.find(string.upper(s), string.upper(v), nil, true) then
                s = string.gsub(s, casepatt(v), c)
            end
        end
    end
    return s
end
if filter_httpget.enabled and type(hookfunc or hookfunction or detour_function) == "function" then
    local hget
    hget = assert(hookfunction or hookfunc or detour_function, "Hook function required for filter_httpget")(assert(game.HttpGet, "HttpGet required for filter_httpget"), function(shelf, u, ...)
        if filter_httpget.request then
            local x, e = pcall(filterstr, u)
            if x and e then
                u = e
            end
        end
        if filter_httpget.result then
            local result = hget(shelf, u, ...)
            local x, e = pcall(filterstr, result)
            if x and e then
                return e
            end
        end
        return hget(shelf, u, ...)
    end)
end
scan_and_replace(true)

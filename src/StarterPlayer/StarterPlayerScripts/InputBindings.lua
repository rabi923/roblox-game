--[[
    Hotel Hermes - Cross-Platform Input Bindings
    File: StarterPlayer/StarterPlayerScripts/InputBindings.lua
    Description: Unifies Desktop, Mobile Touch, and Console Gamepad inputs
                 using ContextActionService with custom priority bands.
--]]

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local InputBindings = {}

InputBindings.ActionNames = {
    Interact = "Hermes_Interact",
    ToggleFlashlight = "Hermes_ToggleFlashlight",
    Crouch = "Hermes_Crouch",
    Sprint = "Hermes_Sprint",
    DropItem = "Hermes_DropItem",
    PauseMenu = "Hermes_PauseMenu",
}

-- Default Desktop Keycodes
local DESKTOP_KEYS = {
    [InputBindings.ActionNames.Interact] = { Enum.KeyCode.E },
    [InputBindings.ActionNames.ToggleFlashlight] = { Enum.KeyCode.F },
    [InputBindings.ActionNames.Crouch] = { Enum.KeyCode.C, Enum.KeyCode.LeftControl },
    [InputBindings.ActionNames.Sprint] = { Enum.KeyCode.LeftShift },
    [InputBindings.ActionNames.DropItem] = { Enum.KeyCode.G },
    [InputBindings.ActionNames.PauseMenu] = { Enum.KeyCode.Escape, Enum.KeyCode.P },
}

-- Console Gamepad Mappings
local GAMEPAD_BUTTONS = {
    [InputBindings.ActionNames.Interact] = { Enum.KeyCode.ButtonX },
    [InputBindings.ActionNames.ToggleFlashlight] = { Enum.KeyCode.ButtonY },
    [InputBindings.ActionNames.Crouch] = { Enum.KeyCode.ButtonB },
    [InputBindings.ActionNames.Sprint] = { Enum.KeyCode.ButtonL3 },
    [InputBindings.ActionNames.DropItem] = { Enum.KeyCode.DPadDown },
    [InputBindings.ActionNames.PauseMenu] = { Enum.KeyCode.ButtonStart },
}

--[[
    Binds an action with automatic cross-platform key resolution and optional mobile touch button creation.
--]]
function InputBindings.BindAction(
    actionName: string,
    callback: (actionName: string, inputState: Enum.UserInputState, inputObj: InputObject) -> Enum.ContextActionResult?,
    createTouchButton: boolean,
    touchButtonTitle: string?
)
    local keysToBind = {}

    -- Add desktop keys
    if DESKTOP_KEYS[actionName] then
        for _, key in ipairs(DESKTOP_KEYS[actionName]) do
            table.insert(keysToBind, key)
        end
    end

    -- Add gamepad keys
    if GAMEPAD_BUTTONS[actionName] then
        for _, btn in ipairs(GAMEPAD_BUTTONS[actionName]) do
            table.insert(keysToBind, btn)
        end
    end

    ContextActionService:BindAction(
        actionName,
        callback,
        createTouchButton,
        table.unpack(keysToBind)
    )

    -- Configure mobile on-screen touch button appearance if requested
    if createTouchButton and UserInputService.TouchEnabled then
        local button = ContextActionService:GetButton(actionName)
        if button then
            button.Size = UDim2.new(0, 60, 0, 60)
            button.Position = UDim2.new(1, -90, 1, -170)
            if touchButtonTitle then
                button.Title.Text = touchButtonTitle
                button.Title.TextSize = 14
            end
        end
    end
end

--[[
    Unbinds an action cleanly.
--]]
function InputBindings.UnbindAction(actionName: string)
    ContextActionService:UnbindAction(actionName)
end

--[[
    Helper to detect active input device type.
--]]
function InputBindings.GetPlatform(): string
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        return "Console"
    else
        return "Desktop"
    end
end

return InputBindings

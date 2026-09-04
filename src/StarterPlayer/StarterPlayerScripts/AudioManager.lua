--[[
    Hotel Hermes - Positional Audio & Horror Soundscape Manager
    File: StarterPlayer/StarterPlayerScripts/AudioManager.lua
    Description: Adaptive audio crossfader, surface-aware footstep generator,
                 and 3D horror stingers for Hotel Hermes.
--]]

local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")
local Constants = require(SharedModules:WaitForChild("Constants"))
local GameConfig = require(SharedModules:WaitForChild("GameConfig"))

local localPlayer = Players.LocalPlayer

local AudioManager = {}

-- Volume controls
local masterSfxVolume = 0.8
local masterMusicVolume = 0.5

-- Active Sound references
local currentAmbientTrack: Sound? = nil
local nextAmbientTrack: Sound? = nil

-- Roblox Asset IDs for Audio (Placeholder IDs that can be mapped to approved Creator Store audio)
local AUDIO_LIBRARY = {
    Ambience = {
        [1] = "rbxassetid://9114223175", -- Vintage eerie hallway drone
        [2] = "rbxassetid://9114223502", -- Abandoned pipe wind & creaks
        [3] = "rbxassetid://9114224018", -- Flooded underground rumble
        [4] = "rbxassetid://9114224422", -- Mirror resonant hum
        [5] = "rbxassetid://9114224890", -- The Void silence & sub-bass
    },
    Stingers = {
        EntitySpotted = "rbxassetid://9114225211",  -- High violin screech
        Jumpscare = "rbxassetid://9114225580",      -- Bass impact + distortion
        DoorOpen = "rbxassetid://9114225902",       -- Heavy brass creak
        DoorLocked = "rbxassetid://9114226214",     -- Handle rattle
        KeyPickup = "rbxassetid://9114226508",      -- Metallic chime
        ElevatorChime = "rbxassetid://9114226810",  -- Vintage bell ding
        FlashlightClick = "rbxassetid://9114227101",-- Switch click
    },
    Footsteps = {
        Carpet = "rbxassetid://9114227419",
        Wood = "rbxassetid://9114227702",
        Concrete = "rbxassetid://9114228001",
        Water = "rbxassetid://9114228312",
    }
}

--[[
    Plays a 2D or 3D one-shot sound effect.
--]]
function AudioManager.PlaySound(soundId: string, parent: Instance?, volumeScale: number?, pitch: number?)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = (volumeScale or 1.0) * masterSfxVolume
    sound.PlaybackSpeed = pitch or 1.0
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.RollOffMinDistance = 6
    sound.RollOffMaxDistance = 45
    sound.Parent = parent or SoundService

    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    return sound
end

--[[
    Smoothly crossfades between ambient room tracks when moving between floor tiers.
--]]
function AudioManager.CrossfadeAmbient(newTrackId: string, fadeDuration: number?)
    local duration = fadeDuration or 3.0

    if currentAmbientTrack and currentAmbientTrack.SoundId == newTrackId then
        return -- Already playing this track
    end

    nextAmbientTrack = Instance.new("Sound")
    nextAmbientTrack.SoundId = newTrackId
    nextAmbientTrack.Volume = 0
    nextAmbientTrack.Looped = true
    nextAmbientTrack.Parent = SoundService
    nextAmbientTrack:Play()

    -- Fade in new track
    TweenService:Create(nextAmbientTrack, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Volume = masterMusicVolume
    }):Play()

    -- Fade out old track
    if currentAmbientTrack then
        local oldTrack = currentAmbientTrack
        local fadeOutTween = TweenService:Create(oldTrack, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Volume = 0
        })
        fadeOutTween:Play()
        fadeOutTween.Completed:Connect(function()
            oldTrack:Stop()
            oldTrack:Destroy()
        end)
    end

    currentAmbientTrack = nextAmbientTrack
end

--[[
    Plays appropriate footstep sound based on surface raycast underneath the character.
--]]
function AudioManager.PlayFootstep(rootPart: BasePart, floorMaterial: Enum.Material)
    local soundId = AUDIO_LIBRARY.Footsteps.Concrete

    if floorMaterial == Enum.Material.Fabric then
        soundId = AUDIO_LIBRARY.Footsteps.Carpet
    elseif floorMaterial == Enum.Material.Wood or floorMaterial == Enum.Material.WoodPlanks then
        soundId = AUDIO_LIBRARY.Footsteps.Wood
    elseif floorMaterial == Enum.Material.Water then
        soundId = AUDIO_LIBRARY.Footsteps.Water
    end

    local pitchVariance = 0.92 + (math.random() * 0.16)
    AudioManager.PlaySound(soundId, rootPart, 0.45, pitchVariance)
end

--[[
    Triggered when entering a new floor to set ambient atmosphere.
--]]
function AudioManager.OnFloorEntered(floorNumber: number)
    local theme = GameConfig.GetThemeForFloor(floorNumber)
    local tierIndex = 1
    for idx, t in ipairs(Constants.FloorThemes) do
        if t.Name == theme.Name then
            tierIndex = idx
            break
        end
    end

    local trackId = AUDIO_LIBRARY.Ambience[tierIndex] or AUDIO_LIBRARY.Ambience[1]
    AudioManager.CrossfadeAmbient(trackId, 2.5)
end

AudioManager.AUDIO_LIBRARY = AUDIO_LIBRARY

return AudioManager

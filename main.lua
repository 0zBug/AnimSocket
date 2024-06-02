local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

repeat wait() until Players.LocalPlayer

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(Character)
	Character = Character
	Humanoid = Character:WaitForChild("Humanoid")
end)

local AnimSocket = {}

function AnimSocket.Connect(Channel)
    local Socket = {
        Send = function(self, Message) 
            local Payload = string.format("%s\255%s\255%s", Channel, LocalPlayer.Name, Message)

			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. math.floor(os.clock() * 10000) .. "\255" .. Payload
			
			local AnimationTrack = Humanoid:LoadAnimation(Animation)
			AnimationTrack:Play()
			AnimationTrack:Stop()
        end,
        Close = function(self)
            self.OnClose()
        end,
        OnMessage = {
            Connections = {},
            Connect = function(self, f)
                table.insert(self.Connections, f)
            end,
            Fire = function(self, ...)
                for _, f in pairs(self.Connections) do
                    f(...)
                end
            end
        },
        OnClose = function() end
    }

    local Complete = {}

    RunService.RenderStepped:Connect(function()
        for _, Player in pairs(Players:GetPlayers()) do
            pcall(function()
                local Character = Player.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

                for _, Animation in pairs(Humanoid:GetPlayingAnimationTracks()) do
                    local Data = string.sub(Animation.Animation.AnimationId, 14, -1)
                    Data = string.split(Data, "\255")

                    if not Complete[Data[1]] then
                        if Data[2] == Channel then
                            local Source, Error = pcall(function()
                                Socket.OnMessage:Fire(Players:FindFirstChild(Data[3]), Data[4])
                            end)

                            if not Source then
                                warn(Error)
                            end
                        end

                        Complete[Data[1]] = true
                    end
                end
            end)
        end
    end)

    return Socket
end

return AnimSocket

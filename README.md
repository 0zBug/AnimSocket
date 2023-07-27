# AnimSocket
**Alternative to websockets that communicates with animations.**
# Documentation
### Connect
**Connects to the channel specified**
```html
<Object> AnimSocket:Connect(<string> Channel, <boolean> Secret)
```
### Send
**Sends the message to all connected clients**
```html
<void> Channel:Send(<string> Message)
```
### Close
**Deletes the channel and fires Channel.OnClose**
```html
<void> Channel:Close(<void>)
```
### OnMessage
**Fired when a message is sent in the connected channel**
```html
<void> Channel.OnMessage:Connect(function(<Instance> Player, <string> Message))
```
### OnClose
**Fired when the Close function is called**
```html
<void> Channel.OnClose = function(<void>)
```
# Example
```lua
local AnimSocket =  loadstring(game:HttpGet("https://raw.github.com/0zBug/AnimSocket/main/main.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Channel = AnimSocket.Connect("ChannelName", true)

Channel.OnMessage:Connect(function(Player, Message)
    if Player ~= LocalPlayer then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Message, "All")
    end
end)

Channel:Send("Hello, World!")
```

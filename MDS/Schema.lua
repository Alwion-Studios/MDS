--[[

 __  __                 _                 _  _  _  _ 
|  \/  | __ _  _ _  ___| |_   _ __   ___ | || || || |
| |\/| |/ _` || '_|(_-/|   \ | '  \ / -_)| || | \_. |
|_|  |_|\__/_||_|  /__/|_||_||_|_|_|\___||_||_| |__/ 

Made by xMellylicious. All Rights Reserved.
Contact me at xMellylicious#0001 if any issues arise.

]]
--Imports
local RS = game:GetService("ReplicatedStorage")
local packages = RS.Packages
local Janitor = require(packages.Janitor)

--Settings
local config = require(script.Parent)

--Database
local DS = game:GetService("DataStoreService")

--Main Object
local DataSchema = {}
DataSchema.__index = DataSchema

function DataSchema.New()
    local self = {}

    self.Janitor = Janitor.new()
    self.Name = nil
    self.Player = nil
    self.Data = {}
    self.DataStore = nil
    
    return setmetatable(self, DataSchema)
end

--Getter/Setter for Name
function DataSchema:SetName(name: String)
    if not name then return warn("A name needs to be declared!") end 
    self.Name = name
end

function DataSchema:GetName()
    return self.Name or false
end

--Setter for Datastore
function DataSchema:SetDataStore(name: String)
    if not name then return warn("A name needs to be declared to set any data") end
    
    self.DataStore = DS:GetDataStore(name)

    return true
end

--Getter/Setter for Player
function DataSchema:SetPlayer(plr: Player)
    if not plr then return warn("A player needs to be declared!") end 
    self.Player = plr
end

function DataSchema:GetPlayer()
    return self.Player or false
end

--Getter/Setter for Data
function DataSchema:GetData(name: String)
    if not name then return warn("A name needs to be declared to get any data") end

    if not self.Data[name] then return false end 
    return self.Data[name]
end

function DataSchema:GetAllData()
    return self.Data
end

function DataSchema:SetData(value)
    --if not name then return warn("A name needs to be declared to set any data") end
    if not value then return warn("A value needs to be declared to set any data") end
    --if typeof(value) ~= "table" then return warn("This value needs to be a table!") end

    self.Data = value
end

function DataSchema:InsertData(name, value: table)
    if not name then return warn("A name needs to be declared to set any data") end
    if not value then return warn("A value needs to be declared to set any data") end

    self.Data[name] = value
end

function DataSchema:SetDefaultData(defaultValue)
    if not defaultValue then return false end
    if not self.DataStore then return warn("Before using this, a default datastore value needs to be declared!") end
    if not self.Player then return warn("Before using this, a player value needs to be declared!") end

    local data = self.DataStore:GetAsync(self.Player.UserId)

    if data ~= nil then
        warn("User already has set data! Will be loading predefined information!")
        self:SetData(data)

        if data["Version"] then self.Version = data["Version"] else self:InsertData("Version", 1) self.Version = data["Version"] end

        for defaultName, value in pairs(defaultValue) do
            if not self.Data[defaultName] then
                warn("User does not have this default value in their data structure. Inserting.")
                self:InsertData(defaultName, value)
            end
        end
    else
        self:SetData(defaultValue)
    end

    if config["CreateInstanceValues"] and self:GetName() then
        local data = self:GetAllData()

        local toStoreIn

        if not game:GetService("ServerStorage")[self.Player.UserId] then
            toStoreIn = Instance.new("Folder")
            toStoreIn.Parent = game:GetService("ServerStorage")
            toStoreIn.Name = self.Player.UserId
        else
            toStoreIn = game:GetService("ServerStorage")[self.Player.UserId]
        end

        local function createValue(use, name, value)
            local newValue = Instance.new(use)
            newValue.Name = name
            newValue.Value = value
            newValue.Parent = toStoreIn

            return newValue
        end

        local function onChange(newVal, Inst)
            self:InsertData(Inst.name, newVal)
        end

        for name, value in pairs(data) do
            local valueInst

            if typeof(value) == "number" then
                valueInst = createValue("NumberValue", name, value)
            elseif typeof(value) == "string" then
                valueInst = createValue("StringValue", name, value)
            elseif typeof(value) == "boolean" then
                valueInst = createValue("BoolValue", name, value)
            end

            valueInst.Changed:Connect(function(newVal)
                onChange(newVal, valueInst)
            end)
        end
    end
end

--Save Function
function DataSchema:Save()
    if not self.DataStore then return warn("WARNING: THIS STRUCTURE HAS NO SET DATASTORE! ANY CHANGES WILL NOT BE SAVED.") end
    --if not self:GetScope() then return warn("A scope needs to be declared for this to work!") end
    --if not self:GetValue() then return warn("A value needs to be declared for this to work!") end

    print("Saving ".. self.Player.Name.. "'s ".. self.Name .."!")

    local success, err = pcall(function()
        self.Data["Version"] = (self.Data["Version"]+1) or (self.Version+1) or 1

        local function updateHandler(oldData)
            if oldData["Version"] > self.Data["Version"] then
                warn("WARNING: Data has potentially been corrupted or lost!")
                return oldData
            end
    
            return self.Data
        end

        if self.Player then
            self.DataStore:UpdateAsync(self.Player.UserId, updateHandler)
        else
            self.DataStore:UpdateAsync(self.Name, updateHandler)
        end
    end)

    if success then return true else return false end
end

function DataSchema:Destroy()
    self = nil
end

return DataSchema
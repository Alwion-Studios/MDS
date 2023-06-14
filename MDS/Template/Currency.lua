--[[

 __  __                 _                 _  _  _  _ 
|  \/  | __ _  _ _  ___| |_   _ __   ___ | || || || |
| |\/| |/ _` || '_|(_-/|   \ | '  \ / -_)| || | \_. |
|_|  |_|\__/_||_|  /__/|_||_||_|_|_|\___||_||_| |__/ 

Made by xMellylicious. All Rights Reserved.
Contact me at xMellylicious#0001 if any issues arise.

]]
--Imports

--Data Object
local schema = require(script.Parent.Parent.Schema)

--Base
local base = schema.New()

function base.New(plr) 
    base:SetPlayer(plr)
    base:SetName("Money")
    base:SetDataStore("Currency")
    base:SetDefaultData({
        ["Coins"]=20,
        ["Tokens"]=0,
    })

    return base
end

return base
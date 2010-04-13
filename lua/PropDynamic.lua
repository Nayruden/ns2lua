-- ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PropDynamic.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

class 'PropDynamic' (Actor)

function PropDynamic:OnLoad()

    Actor.OnLoad(self)

    self.modelName = tostring(self.model)
    self.animationName = tostring(self.animation)
    self.propScale = self.scale
    
    Shared.PrecacheModel(self.modelName)    

    if(Server) then
    
        if (self.modelName ~= nil) then
            self:SetModel(self.modelName)
        end

        if (self.animationName ~= nil) then
            self:SetAnimation(self.animationName)
        end

    end        
    
end

Shared.LinkClassToMap( "PropDynamic", "prop_dynamic", {} )
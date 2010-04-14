--=============================================================================
--
-- lua/Weapons/ViewModel.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
--=============================================================================


--ViewModel is the class which handles rendering and animating the view model
--(i.e. weapon model) for a player. To use this class, create a 'view_model'
--entity and set its parent to the player that it will belong to. There should
--be one view model entity per player (the same view model entity is used for
--all of the weapons).

class 'ViewModel' (Entity)

ViewModel.mapName = "view_model"

ViewModel.networkVars =
    {
        modelIndex                  = "resource",
        animationSequence           = "integer (-1 to 60)",
        animationStart              = "float", 
        overlayAnimationSequence    = "integer (-1 to 60)",
        overlayAnimationStart       = "float",
        prevAnimationSequence       = "integer (-1 to 60)",
        prevAnimationStart          = "float",
        blendLength                 = "float"
    }

function ViewModel:OnInit()

    Entity.OnInit(self)
    
    -- Use a custom propagation callback to only propagate to the owning player.
    self:SetPropagate(Entity.Propagate_Callback)
    
    self.modelIndex                 = 0
    self.oldModelIndex              = 0

    self.animationSequence          = Model.invalidSequence
    self.animationStart             = 0

    self.overlayAnimationSequence   = Model.invalidSequence
    self.overlayAnimationStart      = 0
    
    self.prevAnimationSequence      = Model.invalidSequence
    self.prevAnimationStart         = 0
    self.blendLength                = 0.5

    self.poseParams                 = PoseParams()
    
    if (Client) then
        self.model                  = nil
        self.boneCoords             = CoordsArray()
    end

end

function ViewModel:OnDestroy()

    if (Client) then
    
        -- Destroy the view model if we have one
        if (self.model ~= nil) then
            Client.DestroyRenderViewModel(self.model)
            self.model = nil
        end
        
    end

end


--Assigns the model for the view model. modelName is a string specifying the
--file name of the model, which should have been precached by calling
--Shared.PrecacheModel during load time.

function ViewModel:SetModel(modelName)

    self.modelIndex = Shared.GetModelIndex(modelName)
    
    if (self.modelIndex == 0 and modelName ~= "") then
        Shared.Message("Mesh '" .. modelName .. "' wasn't precached\n")
    end
    
    if (Client) then
        self:UpdateRenderModel()
    end

end


--Sets the animation currently playing on the actor. The sequence name is the
--name stored in the current model.

function ViewModel:SetAnimation(sequenceName)

    local model = Shared.GetModel(self.modelIndex, true)
    local animationSequence = Model.invalidSequence
    
    if (model ~= nil) then
        animationSequence = model:GetSequenceIndex(sequenceName)
    else
        Shared.Message("SetAnimation(" .. sequenceName .. ") called on a ViewModel (" ..
            self:GetClassName() .. ") with a nil model. The animation will not be played")
    end

    -- Only play the animation if it isn't already playing.
    if (animationSequence ~= self.animationSequence) then
        self.animationSequence = animationSequence
        self.animationStart    = Shared.GetTime()
    end

end


--Sets the primary animation, blending into it from the currently playing
--animation. The blendLength specifies the time (in seconds) over which
--the new animation will be blended in. Note the view model can only blend
--between two animations at a time, so if an an animation is already being
--blended in, there will be a pop. If nothing passed for blendLength, it
--uses the default blend time.

function ViewModel:SetAnimationWithBlending( animationName, blendLength )

    self.prevAnimationSequence = self.animationSequence
    self.prevAnimationStart    = self.animationStart
    
    if(blendLength ~= nil) then
        self.blendLength           = blendLength
    end
    
    self:SetAnimation( animationName )

end


--Sets the animation which is played on top of the base animation for the view
--model. The overlay animation is generally used to apply a different animation
--to the gun model than to the hands.

function ViewModel:SetOverlayAnimation( sequenceName )

    local animationSequence = Model.invalidSequence

    if (sequenceName ~= nil) then
        
        local model = Shared.GetModel(self.modelIndex, true)
        
        if (model ~= nil) then
            animationSequence = model:GetSequenceIndex(sequenceName)
        else
            Shared.Message("SetOverlayAnimation(" .. sequenceName .. ") called on a ViewModel  (" ..
                self:GetClassName() .. ") with a nil model. The animation will not be played")
        end

    end

    -- Only play the animation if it isn't already playing.
    if (animationSequence ~= self.overlayAnimationSequence) then
        self.overlayAnimationSequence = animationSequence
        self.overlayAnimationStart    = Shared.GetTime()
    end

end

function ViewModel:SetBlendLength( blendLength )
    self.blendLength = blendLength
end


--Sets a parameter used to compute the final pose of an animation. These are
--named in the actor's .model file and are usually things like the amount the
--actor is moving, the pitch of the view, etc. This only applies to the currently
--set model, so if the model is changed, the values will need to be reset.
function ViewModel:SetPoseParam(name, value)

    local paramIndex = self:GetPoseParamIndex(name)

    if (paramIndex ~= -1) then
        self.poseParams:Set(paramIndex, value)
    end

end

function ViewModel:GetModelIndex()
    return self.modelIndex
end


--Returns the value of a parameter used to compute the final pose of an
--animation. These are named in the view model's .model file and are usually
--things like the pitch of the view, etc.

function ViewModel:GetPoseParam(name)

    local paramIndex = self:GetPoseParamIndex(name)

    if (paramIndex ~= -1) then
        return self.poseParams:Get(paramIndex)
    else
        return 0
    end

end


--Returns the index of the named pose parameter on the view model. If the
--actor doesn't have a model set or the pose parameter doesn't exist, the
--method returns -1

function ViewModel:GetPoseParamIndex(name)
  
    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        return model:GetPoseParamIndex(name)
    else
        return -1
    end
        
end


--Called to build the final pose for the actor's bones. This may be overriden
--to apply additional overlay animations, The base class implementation should
--be called to play the base animation for the actor.

function ViewModel:BuildPose(poses)
    
    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        model:GetReferencePose(poses)
        self:AccumulateAnimation(poses, self.animationSequence, self.animationStart)
    end
    
    -- If we have a previous animation, blend it in.
    if (self.prevAnimationSequence ~= Model.invalidSequence) then

        if(self.blendLength ~= nil and self.blendLength > 0) then
        
            local time     = Shared.GetTime()
            local fraction = Math.Clamp( (time - self.animationStart) / self.blendLength, 0, 1 )
            
            if (fraction < 1) then
                self:BlendAnimation(poses, self.prevAnimationSequence, self.prevAnimationStart, 1 - fraction)
            end
            
        end
    
    end

    -- Apply the overlay animation if we have one.
    if (self.overlayAnimationSequence ~= Model.invalidSequence) then
        self:AccumulateAnimation(poses, self.overlayAnimationSequence, self.overlayAnimationStart)
    end
    
end


--Accmuluates the specified animation on the model into the poses.

function ViewModel:AccumulateAnimation(poses, animationIndex, animationStart)

    local model = Shared.GetModel(self.modelIndex)

    if (model ~= nil) then
        local animationTime = Shared.GetTime() - animationStart
        model:AccumulateSequence(animationIndex, animationTime, self.poseParams, poses)
    end

end

function ViewModel:OnGetIsRelevant(player)
    
    -- Only propagate the view model if it belongs to the player (since they're
    -- the only one that can see it)
    return self:GetParent() == player
    
end

function ViewModel:OnUpdate()

    Entity.OnUpdate(self)
    
    if (Client) then
    
        local model = Shared.GetModel(self.modelIndex)

        if (model ~= nil) then

            -- Update the bones based on the currently playing animation.
            local poses = PosesArray()
            self:BuildPose(poses)
            
            model:GetBoneCoords(poses, self.boneCoords)

            self.model:SetBoneCoords( self.boneCoords )
            
            -- If the view model has a camera embedded in it, use that as
            -- the camera for rendering the view model.
            if (model:GetNumCameras() > 0) then

                local camera = model:GetCamera(0, self.boneCoords)

                self.model:SetCoords( camera:GetCoords():GetInverse() )
                self.model:SetFov( camera:GetFov() )

            else
                self.model:SetCoords( Coords.GetIdentity() )
                self.model:SetFov( Math.Radians(65) )
            end             
            
        end
        
    end
    
end


--Blends an animation over the existing pose by the indicated fraction (0 to 1).

function ViewModel:BlendAnimation(poses, animationIndex, animationStart, fraction)

    local model = Shared.GetModel(self.modelIndex)

    if (model ~= nil) then
        
        local animationTime = Shared.GetTime() - animationStart

        local poses2 = PosesArray()
        model:GetReferencePose(poses2)
        model:AccumulateSequence(animationIndex, animationTime, self.poseParams, poses2)

        Model.GetBlendedPoses(poses, poses2, fraction)

    end
    
end


--Overriden from Entity.

function ViewModel:GetAttachPointIndex(attachPointName)

    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        return model:GetAttachPointIndex(attachPointName)
    end

    return -1

end


--Overriden from Entity.

function ViewModel:GetAttachPointCoords(attachPointIndex)

    if (attachPointIndex ~= -1) then
   
        local model = Shared.GetModel(self.modelIndex)
    
        if (model ~= nil) then
                
            -- Make sure the bones are up to date;
            local poses = PosesArray()
            local boneCoords = CoordsArray()
            model:GetReferencePose(poses)
            self:AccumulateAnimation(poses, self.animationSequence, self.animationStart)
            model:GetBoneCoords(poses, boneCoords)
        
            local coords = self:GetCoords()
            return coords--model:GetAttachPointCoords(attachPointIndex, boneCoords)
        end

    end
    
    return Coords.GetIdentity()
    
end

if (Client) then


    --Creates the rendering representation of the model if it doesn't match
    --the currently set model index and update's it state to match the actor.

    function ViewModel:UpdateRenderModel()
    
        if (self.modelIndex ~= self.oldModelIndex) then
    
            -- Create/destroy the model as necessary.
            if (self.modelIndex == 0) then
                Client.DestroyRenderViewModel(self.model)
                self.model = nil
            else
                if(self.model == nil) then
                    self.model = Client.CreateRenderViewModel()
                end
                self.model:SetModel(self.modelIndex)
            end
        
            -- Save off the model index so we can detect when it changes.
            self.oldModelIndex = self.modelIndex
            
        end
        
        if (self.model ~= nil) then
            -- Show or hide the view model depending on whether or not the
            -- entity is visible. This allows the owner to show or hide it
            -- as needed.
            self.model:SetIsVisible( self:GetIsVisible() )
        end
        
    end
        

    --Called when the network variables for the actor are updated from values
    --from the server.

    function ViewModel:OnSynchronized()
    
        Entity.OnSynchronized(self)
        self:UpdateRenderModel()
        
    end
    
end

function ViewModel:GetAnimationLength(sequenceName)

    local model = Shared.GetModel(self.modelIndex, true)
    
    if (model ~= nil) then
    
        local animationSequence = model:GetSequenceIndex(sequenceName)
        
        if (animationSequence ~= Model.invalidSequence) then
            return model:GetSequenceLength(animationSequence)
        end
        
    end
    
    return 0
    
end

function ViewModel:SetAnimationSpeed(speed)
    -- Doesn't currently do anything.
end


Shared.LinkClassToMap( "ViewModel", ViewModel.mapName, ViewModel.networkVars )  
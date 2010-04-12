// ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/Actor.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2008-2010, Unknown Worlds Entertainment, Inc.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

/**
 * An Actor is a type of Entity that has a model associated with it.
 */
class 'Actor' (Entity)

Actor.networkVars = 
    {
        modelIndex          = "resource",
        animationSequence   = "integer (-1 to 100)",
        animationStart      = "float",
        animationLastTime   = "float",
        animationComplete   = "boolean",
        physicsActor        = "boolean",
    }
    
function Actor:OnInit()

    Entity.OnInit(self)
    
    self.modelIndex         = 0
    self.animationSequence  = Model.invalidSequence
    self.animationStart     = 0
    self.animationLastTime  = 0
    self.animationComplete  = false
    self.boneCoords         = CoordsArray()
    self.poseParams         = PoseParams()
    self.physicsActor       = false 
    self.physicsModel       = nil

    if (Client) then
        self.physicsGroup  = 0 // Collision group.
        self.oldModelIndex = 0
    end

end

function Actor:OnDestroy()

    Entity.OnDestroy(self)
    
    if (Client) then
    
        // Destroy the render model.
        if (self.model ~= nil) then
            Client.DestroyRenderModel(self.model)
            self.model = nil
        end
        
    end
        
    if (self.physicsModel ~= nil) then
        Shared.DestroyPhysicsModel(self.physicsModel)
        self.physicsModel = nil
    end
    
end

/**
 * Assigns the model for the actor. modelName is a string specifying the file
 * name of the model, which should have been precached by calling
 * Shared.PrecacheModel during load time.
 */
function Actor:SetModel(modelName)

    self.modelIndex = Shared.GetModelIndex(modelName)
    
    if (self.modelIndex == 0 and modelName ~= "") then
        Shared.Message("Mesh '" .. modelName .. "' wasn't precached\n")
    end
    
    if (Client) then
        self:UpdateRenderModel()
    end

end

function Actor:SetPhysicsActor()
    self.physicsActor = true
end

/**
 * Returns the mesh's center, in world coordinates. Needed because some objects
 * have their origin at the ground and others don't.
 */
function Actor:GetModelOrigin()

    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        return self.origin + model:GetOrigin()
    else
        return self.origin
    end
    
end

/**
 * Sets the animation currently playing on the actor. The sequence name is the
 * name stored in the current model.
 */
function Actor:SetAnimation(sequenceName, force)

    local model = Shared.GetModel(self.modelIndex, true)
    local animationSequence = Model.invalidSequence
    
    if (model ~= nil) then
        animationSequence = model:GetSequenceIndex(sequenceName)
    else
        Shared.Message("SetAnimation(" .. sequenceName .. ") called on an actor (" ..
            self:GetClassName() .. ") with a nil model. The animation will not be played.")
    end

    // Only play the animation if it isn't already playing.
    if (animationSequence ~= self.animationSequence or force) then
        self.animationSequence = animationSequence
        self.animationStart    = Shared.GetTime()
        self.animationComplete = false
    end

end

/**
 * Returns the name of the currently playing animation.
 */
function Actor:GetAnimation()

    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        
        if (self.animationSequence ~= Model.invalidSequence) then
            return model:GetSequenceName(self.animationSequence)
        end
        
    end
    
    return nil

end

/**
 * Returns length of animation sequence in seconds, or 0 if it can't be found.
 */
function Actor:GetAnimationLength(sequenceName)

    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
    
        local animationSequence = model:GetSequenceIndex(sequenceName)
        
        if (animationSequence ~= Model.invalidSequence) then
            return model:GetSequenceLength(animationSequence)
        end
        
    end
    
    return 0
    
end

/**
 * Returns the index of an animation with the specified name. If a model isn't
 * assigned to the actor or the named animation doesn't exist, the method
 * returns -1.
 */
function Actor:GetAnimationIndex(sequenceName)
    
    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        return model:GetSequenceIndex(sequenceName)
    else
        return -1
    end
    
end

/**
 * Sets a parameter used to compute the final pose of an animation. These are
 * named in the actor's .model file and are usually things like the amount the
 * actor is moving, the pitch of the view, etc. This only applies to the currently
 * set model, so if the model is changed, the values will need to be reset.
 */
function Actor:SetPoseParam(name, value)

    local paramIndex = self:GetPoseParamIndex(name)

    if (paramIndex ~= -1) then
        self.poseParams:Set(paramIndex, value)
    end
end

/**
 * Returns the value of a parameter used to compute the final pose of an
 * animation. These are named in the actor's .model file and are usually
 * things like the amount the actor is moving, the pitch of the view, etc.
 */
function Actor:GetPoseParam(name)

    local paramIndex = self:GetPoseParamIndex(name)

    if (paramIndex ~= -1) then
        return self.poseParams:Get(paramIndex)
    else
        return 0
    end

end

/**
 * Returns the index of the named pose parameter on the actor's model. If the
 * actor doesn't have a model set or the pose parameter doesn't exist, the
 * method returns -1
 */
function Actor:GetPoseParamIndex(name)
  
    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        return model:GetPoseParamIndex(name)
    else
        return -1
    end
        
end

function Actor:SetSkin(skinIndex)
    // Doesn't currently do anything
end

function Actor:SetEthereal(ethereal)
    // Doesn't currently do anything
end

function Actor:SetAnimationSpeed(speed)
    // Doesn't currently do anything.
end

/**
 * Returns the model's center, in world coordinates. This is needed because
 * some objects have their origin at the ground and others don't.
 */
function Actor:GetModelOrigin()

    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        return self:GetOrigin() + model:GetOrigin()
    end

    return self:GetOrigin()
    
end
    
/**
 * Called every frame to update the actor. If a derived classe overrides this
 * method, it should call the base class implementation or else animation will
 * not work for the actor.
 */    
function Actor:OnUpdate()

    Entity.OnUpdate(self)
    
    self:UpdateTags()
    
    local model = Shared.GetModel(self.modelIndex)

    if (model ~= nil) then

        // Check to see if the animation has completed.
        if (self.animationSequence ~= Model.invalidSequence) then

            local currentTime     = Shared.GetTime()     
            local animationTime   = currentTime - self.animationStart
            local animationLength = model:GetSequenceLength(self.animationSequence)   

            if ((animationTime >= animationLength) and not self.animationComplete) then
                self.animationComplete = true
                self:OnAnimationComplete( model:GetSequenceName(self.animationSequence) )
            end
            
        end
    
        // Update the bones based on the currently playing animation.
        self:UpdateBoneCoords()
        
        if (self.physicsActor) then
    
            // Update the bones based on the simulation of the physics model.
            if (self.physicsModel ~= nil) then
                self.physicsModel:GetBoneCoords(self:GetCoords(), self.boneCoords)
            end
        
        end
        
    end
    
    if (Client) then

        // Update the model's coordinate frame to match the entity.
        if (self.model ~= nil) then
            self.model:SetCoords( self:GetCoords() )
            self.model:SetBoneCoords( self.boneCoords )
        end 

    end
    
end

function Actor:UpdateBoneCoords()

    local model = Shared.GetModel(self.modelIndex)

    if (model ~= nil) then

        local poses = PosesArray()
        self:BuildPose(poses)
        model:GetBoneCoords(poses, self.boneCoords)
    
    end

end

/**
 * Called when an animation finishes playing.
 */
function Actor:OnAnimationComplete()
end

/**
 * Called to build the final pose for the actor's bones. This may be overriden
 * to apply additional overlay animations, The base class implementation should
 * be called to play the base animation for the actor.
 */
function Actor:BuildPose(poses)

    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        model:GetReferencePose(poses)
        self:AccumulateAnimation(poses, self.animationSequence, self.animationStart)
    end

end

/**
 * Accmuluates the specified animation on the model into the poses.
 */
function Actor:AccumulateAnimation(poses, animationIndex, animationStart)

    local model = Shared.GetModel(self.modelIndex)

    if (model ~= nil) then
        local animationTime = Shared.GetTime() - animationStart
        model:AccumulateSequence(animationIndex, animationTime, self.poseParams, poses)
    end

end

/**
 * Blends an animation over the existing pose by the indicated fraction (0 to 1).
 */
function Actor:BlendAnimation(poses, animationIndex, animationStart, fraction)

    local model = Shared.GetModel(self.modelIndex)

    if (model ~= nil) then
        
        local animationTime = Shared.GetTime() - animationStart

        local poses2 = PosesArray()
        model:GetReferencePose(poses2)
        model:AccumulateSequence(animationIndex, animationTime, self.poseParams, poses2)

        Model.GetBlendedPoses(poses, poses2, fraction)

    end
    
end

/**
 * Called by the engine when a ray is traced through the world.
 */
function Actor:TraceRay(startPos, endPos, trace)

    // Don't trace if this is a physics actor (since we're
    // already tracing against the model in the physics scene).
    
    if (self.physicsActor) then
        trace:Clear()
    else
    
        local model = Shared.GetModel(self.modelIndex)    
        
        if (model ~= nil and model:GetHasHitBoxes()) then

            // Transform the start and end point into the model's local space.
        
            local objectToWorldCoords = self:GetCoords()
            local worldToObjectCoords = objectToWorldCoords:GetInverse()
            
            local localStart = worldToObjectCoords:TransformPoint(startPos)
            local localEnd   = worldToObjectCoords:TransformPoint(endPos)

            model:TraceRay(localStart, localEnd, self.boneCoords, trace)
            trace.endPoint = objectToWorldCoords:TransformPoint(trace.endPoint)

            if (trace.fraction < 1) then
                trace.normal   = objectToWorldCoords:TransformVector(trace.normal)
                trace.entity   = self
            end
            
        else
            trace:Clear()
        end
    
    end
    
end

/**
 * Overriden from Entity.
 */
function Actor:GetAttachPointIndex(attachPointName)

    local model = Shared.GetModel(self.modelIndex)
    
    if (model ~= nil) then
        return model:GetAttachPointIndex(attachPointName)
    end

    return -1

end

/**
 * Overriden from Entity.
 */
function Actor:GetAttachPointCoords(attachPointIndex)

    if (attachPointIndex ~= -1) then
   
        local model = Shared.GetModel(self.modelIndex)
    
        if (model ~= nil) then
                
            self:UpdateBoneCoords()
        
            local coords = self:GetCoords()
            return coords * model:GetAttachPointCoords(attachPointIndex, self.boneCoords)
            
        end

    end
    
    return Coords.GetIdentity()
    
end

function Actor:UpdateTags()

    local model = Shared.GetModel(self.modelIndex)

    if (model ~= nil and self.animationSequence ~= Model.invalidSequence) then
    
        local currentTime     = Shared.GetTime()
        local animationTime   = currentTime - self.animationStart
        local animationLength = model:GetSequenceLength(self.animationSequence)
        
        local frameTagName, lastTime = model:GetTagPassed(self.animationSequence, self.poseParams, self.animationLastTime, animationTime)
        
        if (lastTime < 0) then
            self.animationLastTime = animationTime
        end

        local currentSequence = self.animationSequence

        while (lastTime >= 0 and lastTime < animationTime) do
        
            // tag could have changed the sequence
            if (currentSequence ~= self.animationSequence) then
                return
            end
            self.animationLastTime = lastTime

            self:OnTag(frameTagName)

            frameTagName = model:GetTagPassed(self.animationSequence, self.poseParams, lastTime, animationTime)
            lastTime = animationTime

        end

        // see if we need to check it again, because we started a new loop since the last update
        if (animationTime > animationLength) then
        
            if (model:GetIsLooping(self.animationSequence)) then
            
                // tag could have changed the sequence
                while (animationTime > animationLength) do
                
                    if (currentSequence ~= self.animationSequence) then
                        return
                    end

                    animationTime          = animationTime - animationLength
                    self.animationStart    = self.animationStart + animationLength
                    self.animationLastTime = self.animationLastTime - animationLength

                    local frameTagName, lastTime = model:GetTagPassed(self.animationSequence, self.poseParams, self.animationLastTime, animationTime)
                    
                    if (lastTime < 0) then
                        self.animationLastTime = currentTime - self.animationStart
                    end

                    while (lastTime >= 0 and lastTime < animationTime) do
                        self.animationLastTime = lastTime
                        self:OnTag(frameTagName)
                        frameTagName, lastTime = model:GetTagPassed(self.animationSequence, self.poseParams, lastTime, animationTime)
                    end
                
                end
            
            end
        end
    end
    
end

/**
 * Called when the playing animation passes a frame tag. Derived classes can
 * can override this.
 */
function Actor:OnTag(tagName)
end

if (Client) then

    /**
     * Called when the network variables for the actor are updated from values
     * from the server.
     */
    function Actor:OnSynchronized()
    
        Entity.OnSynchronized(self)
        
        if (self.physicsActor) then
        
            if (self.physicsModel == nil) then
                self.physicsModel = Shared.CreatePhysicsModel(self.modelIndex, self:GetCoords(), self.boneCoords)
                self.physicsModel:SetEntity(self)
                self.physicsModel:SetGroup(self.physicsGroup)
            end
        
        end
        
        self:UpdateRenderModel()
        
    end
    
    /** 
     * Creates the rendering representation of the model if it doesn't match
     * the currently set model index and update's it state to match the actor.
     */
    function Actor:UpdateRenderModel()
    
        if (self.oldModelIndex ~= self.modelIndex) then
    
            // Create/destroy the model as necessary.
            if (self.modelIndex == 0) then
                Client.DestroyRenderModel(self.model)
                self.model = nil
            else
			    Client.DestroyRenderModel(self.model)
                self.model = nil
                self.model = Client.CreateRenderModel()
                self.model:SetModel(self.modelIndex)
            end
        
            // Save off the model index so we can detect when it changes.
            self.oldModelIndex = self.modelIndex
            
        end
        
    end

    /**
     * Shows or hides the actor's model.
     */
    function Actor:ShowModel(show)
        if (self.model ~= nil) then
            self.model:SetIsVisible(show)
        end
    end

end

Shared.LinkClassToMap( "Actor", "actor", Actor.networkVars )
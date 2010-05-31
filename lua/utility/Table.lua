-- ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Table.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- Table related utility functions. 
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

-- Safe equality checking for tables and nested tables.
--  Eg, elementEqualsElement( { {1}, {2} }, { {1}, {2} } returns true
function elementEqualsElement(i, j) 

    if(type(i) == "table" and type(j) == "table") then
    
        local tablesEqual = false
        
        local numIElements = table.maxn(i)
        local numJElements = table.maxn(j)
        
        if(numIElements == numJElements) then
        
            tablesEqual = true
            
            for index = 1, numIElements do
            
                if(not elementEqualsElement(i[index], j[index])) then
                
                    tablesEqual = false
                    break
                    
                end                    
                
            end
        
        end
        
        return tablesEqual
        
    else
    
        return i == j
        
    end
    
end

function table.copy(srcTable, destTable)

    table.clear(destTable)
    
    for index, element in ipairs(srcTable) do
        table.insert(destTable, element)
    end
    
end

function table.getElement(t, index, errorMsg)

    local numEntries = table.maxn(t)
    if(index >= 1 and index < (numEntries + 1)) then
        return t[index]
    else
        Print("Table.getElement(%d) - Index out of range (size = %d)" .. errorMsg, index, numEntries)
    end
    
    return nil
    
end

--
-- Searches a table for the specified value. If the value is in the table
-- the index of the (first) matching element is returned. If its not found
-- the function returns nil.
--/
function table.find(table, value)

    for i,element in ipairs(table) do
        if elementEqualsElement(element, value) then
            return i
        end
    end

    return nil

end

--
-- Returns random element in table.
--/
function table.random(t)
    local max = table.maxn(t)
    if max > 0 then
        return t[math.floor(NetworkRandom(1, max))]
    else
        return nil    
    end
end

--
-- Choose random weighted index according. Pass in table of arrays where the first element in each
-- array is a float that indicates how often that index is chosen.
--
-- {{.9, "chooseOften"}, {.1, "chooseLessOften"}, {.001, "chooseAlmostNever}}
--
-- This returns 1 most often, 2 less often and 3 even less. It adds up all the numbers that are the 
-- first elements in the table to calculate the chance. Returns -1 on error.
--/
function table.chooseWeightedIndex(t)

    local weightedIndex = -1
    
    -- Calculate total weight
    local totalWeight = 0
    for i, element in ipairs(t) do
        totalWeight = totalWeight + element[1]
    end
    
    -- Choose random weighted index of input table data
    local randomNumber = NetworkRandom()*totalWeight
    local total = 0
    
    for i, element in ipairs(t) do
    
        local currentWeight = element[1]
        
        if((total + currentWeight) >= randomNumber) then
            weightedIndex = i
            break
        else
            total = total + currentWeight
        end
        
    end
    
    if(weightedIndex < 0 or weightedIndex > table.count(t)) then
        Print("table.chooseWeightedIndex(%s): returning invalid index %d", table.tostring(t), weightedIndex)
    end
    
    return weightedIndex
    
end

-- Helper function for table.chooseWeightedIndex
function chooseWeightedEntry(t)

    if(t ~= nil) then
        local entry = t[table.chooseWeightedIndex(t)][2]
        return entry
    end
    
    Print("chooseWeightedEntry(nil) - Table is nil.")
    return nil
    
end

function entryInTable(t, entry)
    
    if(t ~= nil) then
    
        for index, subTable in ipairs(t) do
        
            if (subTable[2] == entry) then
            
                return true
                
            end
            
        end
        
    end
    
    return false
    
end

--
-- Removes all elements from a table.
--/
function table.clear(t)

    if(t ~= nil) then
    
        local numElements = table.maxn(t)
    
        for i = 1, numElements do
        
            table.remove(t, 1)
            
        end
        
    end
    
end

--
-- Removes the specified value from the table (note only the first occurance is
-- removed). Returns true if element was found and removed, false otherwise.
--/
function table.removevalue(t, v)

    local i = table.find(t, v)

    if i ~= nil then
    
        table.remove(t, i)
        return true
        
    end
    
    return false

end

function table.insertunique(t, v)

    if(table.find(t, v) == nil) then
    
        table.insert(t, v)
        return true
        
    end
    
    return false
    
end

--
-- Adds the contents of one table to another. Duplicate elements added.
--/
function table.addtable(srcTable, destTable)

    for index, element in ipairs(srcTable) do
    
        table.insert(destTable, element)

    end
    
end

--
-- Adds the contents of onte table to another. Duplicate elements are not inserted.
--/
function table.adduniquetable(srcTable, destTable)

    for index, element in ipairs(srcTable) do
    
        table.insertunique(destTable, element)

    end
    
end

--
-- Call specified functor with every element in the table.
--/
function table.foreachfunctor(t, functor)

    if(table.maxn(t) > 0) then
    
        for index, element in ipairs(t) do
        
            functor(element)
            
        end
        
    end
    
end

function table.count(t)
    if(t ~= nil) then
        return table.maxn(t)
    else
        Print("table.count() - Nil table passed in, returning 0.")
    end
    return 0
end

--
-- Print the table to a string and returns it. Eg, "{ "element1", "element2", {1, 2} }".
--/
function table.tostring(t)

    local buffer = {}
        
    table.insert(buffer, "{")
    
    if(type(t) == "table") then

        local numElements = table.maxn(t)
        local currentElement = 1
        
        for key, value in pairs(t) do
        
            if(type(value) == "table") then
            
                table.insert(buffer, table.tostring(value))
            
            elseif(type(value) == "number") then

                /* For printing out lists of entity ids
                
                local className = "unknown"
                local entity = Shared.GetEntity(value)
                if(entity ~= nil) then
                    className = entity:GetMapName()
                end
                
                table.insert(buffer, string.format("%s (%s)", tostring(value), tostring(className)))
                */
                
                table.insert(buffer, string.format("%s", tostring(value)))
                
            elseif(type(value) == "userdata") then
            
                table.insert(buffer, string.format("class \"%s\"", value:GetClassName()))
                
            else
            
                table.insert(buffer, string.format("\"%s\"", tostring(value)))
                
            end
            
            -- Insert commas between elements
            if(currentElement ~= numElements) then
            
                table.insert(buffer, ",")
                
            end
            
            currentElement = currentElement + 1
        
        end
        
    else
    
        table.insert(buffer, "<data is \"" .. type(t) .. "\", not \"table\">")
        
    end
    
    table.insert(buffer, "}")
    
    return table.concat(buffer)
    
end

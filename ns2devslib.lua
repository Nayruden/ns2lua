--- Group: String Utilities
--[[
    Function: Explode

    Split a string by a string.

    Parameters:

        str - The input *string* to explode.
        separator - An *optional string* to specify what to split on. Defaults to _%s+_.
        plain - An *optional boolean* that turns off pattern matching facilities if true. This
            should make it faster and allows you to specify strings that would otherwise need to be
            escaped. Defaults to _false_.
        limit - An *optional number* that if set, the returned table will contain a maximum of
            limit elements with the last element containing the rest of str. Defaults to
            _no limit_.

    Returns:

        A *table* containing the exploded str.

    Example:

        :Explode( "p1 p2 p3" )

        returns...

        :{ "p1", "p2", "p3" }

    Revisions:

        v1.00 - Initial
]]
function Explode( str, separator, plain, limit )
    separator = separator or "%s+"
    local t = {}
    local curpos = 1

    while true do -- We have a break in the loop
        local newpos, endpos = str:find( separator, curpos, plain ) -- Find the next separator in the string
        if newpos == nil or (limit and #t == limit - 1) then -- If no more separators or we hit our limit...
            table.insert( t, str:sub( curpos ) ) -- Save what's left in our string.
            break
        else -- If found then..
            table.insert( t, str:sub( curpos, newpos - 1 ) ) -- Save it in our table.
            curpos = endpos + 1 -- Save just after where we found it for searching next time.
        end
    end

    return t
end


--[[
    Function: Trim

    Trims leading and tailing whitespace from a string.

    Parameters:

        str - The *string* to trim.

    Returns:

        The stripped *string*.

    Revisions:

        v1.00 - Initial
]]
function Trim( str )
    -- Surrounded in paranthesis to return only the first argument
    return (str:match( "^%s*(.-)%s*$" ))
end


--[[
    Function: Escape

    Makes a string safe for pattern usage, like in string.gsub(). Basically replaces all keywords 
    with % and the keyword.

    Parameters:

        str - The string to make pattern safe.

    Returns:

        The pattern safe string.
]]
function Escape( str )
    -- Surrounded in paranthesis to return only the first argument
    return (str:gsub( "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1" ))
end


--[[
    Function: StripComments

    Strips comments from a string.

    Parameters:

        str - The input *string* to strip from.
        line_comment - The *string* of the comment to remove from str. Removes whenever it finds
            this text until the end of the line.

    Returns:

        A *string* of str with the comments removed.
        
    Notes:
    
        * Only handles line comments, no block comments.
        * Does not parse the document, so it will remove even from inside quotation marks if it 
            finds line_comment inside them.

    Example:

        :StripComments( "Line 1 # My comment\n#Line with only a comment\nLine 2", "#" )

        returns...

        :"Line 1 \n\nLine 2"

    Revisions:

        v1.00 - Initial
]]
function StripComments( str, line_comment )
    -- Surrounded in paranthesis to return only the first argument
    return (str:gsub( Escape( line_comment ) .. "[^\r\n]*", "" ))
end


--[[
    Function: ParseArgs

    This is similar to <Explode> with ( str, "%s+" ) except that it will not split up words within
    quotation marks.

    Parameters:

        args - The input *string* to split from.

    Returns:

        1 - A *table* containing the individual arguments.
        2 - A *boolean* stating whether or not mismatched quotes were found.

    Example:

        :ParseArgs( "This is a \"Cool sentence to\" make \"split up\"" )

        returns...

        :{ "This", "is", "a", "Cool sentence to", "make", "split up" }

    Notes:

        * Mismatched quotes will result in having the last quote grouping the remaining input into
            one argument.
        * Arguments outside of quotes are trimmed (via <Trim>), while what's inside quotes is not
            trimmed at all.

    Revisions:

        v1.00 - Initial
]]
function ParseArgs( args )
    local argv = {}
    local curpos = 1 -- Our current position within the string
    local in_quote = false -- Is the text we're currently processing in a quote?
    local args_len = args:len()

    while curpos <= args_len or in_quote do
        local quotepos = args:find( "\"", curpos, true )

        -- The string up to the quote, the whole string if no quote was found
        local prefix = args:sub( curpos, (quotepos or 0) - 1 )
        if not in_quote then
            local trimmed = Trim( prefix )
            if trimmed ~= "" then -- Something to be had from this...
                local t = Explode( Trim( prefix ) )
                Append( argv, t, true )
            end
        else
            table.insert( argv, prefix )
        end

        -- If a quote was found, reduce our position and note our state
        if quotepos ~= nil then
            curpos = quotepos + 1
            in_quote = not in_quote
        else -- Otherwise we've processed the whole string now
            break
        end
    end

    return argv, in_quote
end


--- Group: Table Utilities

--[[
    Topic: A Discussion On ipairs
    
    ipairs is defined in the lua documentation as... 
    (Taken from <http://www.lua.org/manual/5.1/manual.html#pdf-ipairs>)
    :for i,v in ipairs(t) do body end
    :will iterate over the pairs (1,t[1]), (2,t[2]), ..., up to the first integer key absent from the table.
    
    What isn't mentioned is that ipairs is much faster than pairs when you're iterating over a
    table with only numeric keys. The catch is that it must be sequential numeric keys starting at
    1. Even with this restriction, it is still very much worthwhile to use ipairs to iterate over
    the table instead of pairs if you have a table that meets the requirements to use ipairs.
    
    Because of all this, OTLib lets you make a choice between using pairs or ipairs on anything
    that would make sense to have the choice. Any function that has the same name as another
    function but is just suffixed with the character "I" uses ipairs where the function that is not
    suffixed uses pairs as its iterator. For example, <Copy> and <CopyI>. One should use <CopyI>
    instead of <Copy> whenever the table being copied is known to be a list-like table with
    sequential numeric keys starting at 1.
]]


--[[
    Function: Count

    Counts the number of elements in a table using pairs.

    Parameters:

        t - The *table* to count.

    Returns:

        The *number* of elements in the table.
        
    Notes:
    
        * This is slow and should be avoided if at all possible.

    Revisions:

        v1.00 - Initial
]]
function Count( t )
    local c = 0
    for k, v in pairs( t ) do
        c = c+1
    end
    
    return c
end

local function CopyWith( iterator, t )
    local c = {}
    for k, v in iterator( t ) do
        c[ k ] = v
    end
    
    return c
end


--[[
    Function: Copy

    Make a shallow copy of a table. A shallow copy means that any subtables will still refer to the
    same table.

    Parameters:

        t - The *table* to make a copy of.

    Returns:

        The copied *table*.

    Revisions:

        v1.00 - Initial
]]
function Copy( t )
    return CopyWith( pairs, t )
end


--[[
    Function: CopyI

    Exactly the same as <Copy> except that it uses ipairs instead of pairs. In general, this means
    that it only copies numeric keys. See <A Discussion On ipairs>.
]]
function CopyI( t )
    return CopyWith( ipairs, t )
end

local function InPlaceHelper( iterator, table_a, in_place )
    if in_place then
        return table_a
    else
        return CopyWith( iterator, table_a )
    end
end

local function UnionWith( iterator, table_a, table_b, in_place )
    table_a = InPlaceHelper( iterator, table_a, in_place )

    for k, v in iterator( table_b ) do
        table_a[ k ] = v
    end

    return table_a
end


--[[
    Function: Union

    Merges two tables by key. If both tables have values on the same key, table_b takes precedence.

    Parameters:

        table_a - The first *table* in the union. If in_place is true, table_b is merged to this
            table.
        table_b - The second *table* in the union.
        in_place - An *optional boolean* specifying whether or not this should be an in place union to
            table_a. Defaults to _false_.

    Example:

        :Union( { apple="red", pear="green", kiwi="hairy" },
        :       { apple="green", pear="green", banana="yellow" } )

        returns...

        :{ apple="green", pear="green", kiwi="hairy", banana="yellow" }

    Returns:

        The union *table*. Returns table_a if in_place is true, a new table otherwise.

    Revisions:

        v1.00 - Initial
]]
function Union( table_a, table_b, in_place )
    return UnionWith( pairs, table_a, table_b, in_place )
end


--[[
    Function: UnionI

    Exactly the same as <Union> except that it uses ipairs instead of pairs. In general, this means
    that it only merges on numeric keys. See <A Discussion On ipairs>.
]]
function UnionI( table_a, table_b, in_place )
    return UnionWith( ipairs, table_a, table_b, in_place )
end

local function IntersectionWith( iterator, table_a, table_b, in_place )
    local result
    if not in_place then
        result = {}
    else
        result = table_a
    end
    
    -- Now just fill in each value with whatever the value in table_k is. This takes care of both
    -- elimination and making table b take precedence when both tables have a value on key k.
    for k, v in iterator( table_a ) do
        result[ k ] = table_b[ k ]
    end
    
    return result
end


--[[
    Function: Intersection

    Gets the intersection of two tables by key. If both tables have values on the same key, table_b
    takes precedence.

    Parameters:

        table_a - The first *table* in the intersection. If in_place is true, table_b is merged to 
            this table.
        table_b - The second *table* in the interesection.
        in_place - An *optional boolean* specifying whether or not this should be an in place intersection to
            table_a. Defaults to _false_.

    Example:

        :Intersection( { apple="red", pear="green", kiwi="hairy" },
        :       { apple="green", pear="green", banana="yellow" } )

        returns...

        :{ apple="green", pear="green" }

    Returns:

        The intersection *table*. Returns table_a if in_place is true, a new table otherwise.

    Revisions:

        v1.00 - Initial
]]
function Intersection( table_a, table_b, in_place )
    return IntersectionWith( pairs, table_a, table_b, in_place )
end


--[[
    Function: IntersectionI

    Exactly the same as <Intersection> except that it uses ipairs instead of pairs. In general, 
    this means that it only merges on numeric keys. See <A Discussion On ipairs>.
]]
function IntersectionI( table_a, table_b, in_place )
    return IntersectionWith( ipairs, table_a, table_b, in_place )
end

local function DifferenceWith( iterator, table_a, table_b, in_place )
    table_a = InPlaceHelper( iterator, table_a, in_place )
    
    for k, v in iterator( table_b ) do
        table_a[ k ] = nil
    end
    
    return table_a
end


--[[
    Function: Difference

    Gets the difference of two tables by key. Difference is defined as all the keys in table A that
    are not in table B.

    Parameters:

        table_a - The first *table* in the difference. If in_place is true, keys from table_b are
            removed from this table.
        table_b - The second *table* in the difference.
        in_place - An *optional boolean* specifying whether or not this should be an in place 
            difference operation on table_a. Defaults to _false_.

    Example:

        :Difference( { apple="red", pear="green", kiwi="hairy" },
        :            { apple="green", pear="green", banana="yellow" } )

        returns...

        :{ kiwi="hairy" }

    Returns:

        The difference *table*. Returns table_a if in_place is true, a new table otherwise.

    Revisions:

        v1.00 - Initial
]]
function Difference( table_a, table_b, in_place )
    return DifferenceWith( pairs, table_a, table_b, in_place )
end


--[[
    Function: DifferenceI

    Exactly the same as <Difference> except that it uses ipairs instead of pairs. In general, this means
    that it only performs the difference on numeric keys. See <A Discussion On ipairs>.
]]
function DifferenceI( table_a, table_b, in_place )
    return DifferenceWith( ipairs, table_a, table_b, in_place )
end

local function IntersectionWith( iterator, table_a, table_b, in_place )
    local result
    if not in_place then
        result = {}
    else
        result = table_a
    end
    
    -- Now just fill in each value with whatever the value in table_k is. This takes care of both
    -- elimination and making table b take precedence when both tables have a value on key k.
    for k, v in iterator( table_a ) do
        result[ k ] = table_b[ k ]
    end
    
    return result
end


--[[
    Function: SetFromList
    
    Creates a set from a list. A list is defined as a table with all numeric keys in sequential
    order (such as {"red", "yellow", "green"}). A set is defined as a table that only uses the
    boolean value true for keys that exist in the table. This function takes the values from the
    list and makes them the keys in a set, all with the value of 'true'. Note that you lose
    ordering and duplicates in the list during this conversion, but gain ease of testing for a 
    value's existence in the table (test whether the value of a key is true or nil).
    
    Parameters:
    
        list - The *table* representing the list.
        
    Returns:
    
        The *table* representing the set.
        
    Example:

        :SetFromList( { "apple", "banana", "kiwi", "pear" } )

        returns...

        :{ apple=true, banana=true, kiwi=true, pear=true }
        
    Notes:

        * This function uses ipairs during the conversion process. See <A Discussion On ipairs>.
        
    Revisions:

        v1.00 - Initial
]]
function SetFromList( list )
    local result = {}
    
    for i, v in ipairs( list ) do
        result[ v ] = true
    end
    
    return result
end


--[[
    Function: Append

    Appends values with numeric keys from one table to another.

    Parameters:

        table_a - The first *table* in the append. If in_place is true, table_b is appended to this
            table. Values in this table will not change.
        table_b - The second *table* in the append.
        in_place - An *optional boolean* specifying whether or not this should be an in place append to
            table_a. Defaults to _false_.

    Returns:

        The *table* result of appending table_b to table_a. Returns table_a if in_place is true, a
            new table otherwise.

    Example:

        :Append( { "apple", "banana", "kiwi" },
        :        { "orange", "pear" } )

        returns...

        :{ "apple", "banana", "kiwi", "orange", "pear" }
        
    Notes:

        * This function uses ipairs. See <A Discussion On ipairs>.

    Revisions:

        v1.00 - Initial
]]
function Append( table_a, table_b, in_place )
    local table_a = InPlaceHelper( ipairs, table_a, in_place )

    for i, v in ipairs( table_b ) do
        table.insert( table_a, v )
    end

    return table_a
end

local function HasValueWith( iterator, t, value )
    for k, v in iterator( t ) do
        if v == value then
            return true, k
        end
    end
    
    return false, nil
end


--[[
    Function: HasValue

    Checks for the presence of a value in a table.

    Parameters:

        t - The *table* to check for the value's presence within.
        value - *Any type*, the value to check for within t.

    Example:

        :HasValue( { apple="red", pear="green", kiwi="hairy" }, "green" )

        returns...

        :true

    Returns:

        1 - A *boolean*. True if the table has the value, false otherwise.
        2 - A value of *any type*. The first key the value was found under if it was found, nil 
            otherwise.

    Revisions:

        v1.00 - Initial
]]
function HasValue( t, value )
    return HasValueWith( pairs, t, value )
end


--[[
    Function: HasValueI

    Exactly the same as <HasValue> except that it uses ipairs instead of pairs. In general, 
    this means that it only merges on numeric keys. See <A Discussion On ipairs>.
]]
function HasValueI( t, value )
    return HasValueWith( ipairs, t, value )
end


--- Group: Other Utilities
--[[
    Function: ToBool

    Converts a boolean, nil, string, or number to a boolean value.

    Parameters:

        value - The *boolean, nil, string, or number* to convert.

    Returns:

        The converted *boolean* value.
        
    Notes:
    
        * This function favors returning true if it's not quite sure what to do.
        * 0, strings equating to 0, nil, false, "f", "false", "no", and "n" will all return false.

    Revisions:

        v1.00 - Initial.
]]
function ToBool( value )
    if type( value ) == "boolean" then 
        return value
    elseif value == nil then 
        return false
    elseif tonumber( value ) ~= nil then
        if tonumber( value ) == 0 then
            return false
        else
            return true
        end
    elseif type( value ) == "string" then
        value = value:lower()
        if value == "f" or value == "false" or value == "no" or value == "n" then
            return false
        else
            return true
        end
    end
    
    -- Shouldn't get here with the constraints on type, but just in case...
    return true
end
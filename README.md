luagroups - Group oriented programming in Lua  
BSD license.  
by Sven Nilsen, 2012  
http://www.cutoutpro.com  

Version: 0.001 in angular degrees version notation  
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html


## How To Use It

    require "groups.lua"

## What Is Group Oriented Programming?

Group Oriented Programming is a paradigm where computations are done with "groups". It is that simple.

Here is an example:

    -- First we need some data to calculate with.
    -- Notice that Clark has no hair member.
    local people = {{name="John", hair=true}, {name="Clark"}}

    -- We can extract the groups we need on the fly.
    local name = groups_HasKey(people, "name")
    local hair = groups_HasKey(people, "hair")

    -- Using operator overloading, we combine groups
    -- AND: *
    -- OR: +
    -- EXCEPT: - (same as AND NOT)
    local name_and_hair = name * hair

    -- Iterate through the indices using the group(t) iterator.
    -- This should print out only "John".
    local person
    for i in group(name_and_hair) do
        -- indices start with 0 in a group but 1 in Lua.
        person = people[i+1]
        print(person.name)
    end

## Why Use Group Oriented Programming?

Here are 4 top reasons:

1. Simplicity.
2. Better reuse of code.
3. Easier to handle complex problems.
4. Does not require database and SQL, runs a lot faster.

## Group Generators

A group generator is a function that iterates through an array and creates a group. The group does not contain data, only indices. The group bitstream format stores index ranges to save memory and does algebra operations faster on large amount of data.

A group generator can also take a region group as argument to limit the scope of iterations. Using a region group is faster.

    -- A bit slower.
    local US = groups_HasKey(people, "US")
    local name = groups_HasKey(people, "name")
    local name_and_in_US = US * name

    -- A bit faster.
    local US = groups_HasKey(people, "US")
    local name_and_in_US = groups_HasKey(people, "name", US)

It is the group generator that makes the difference. The performance of the algebra is not depending on the size of data, but how fragmented the information in the group is. This is completely determined by the data. When it comes to speed, it is the generators that matters.



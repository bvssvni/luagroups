luagroups - Group oriented programming in Lua  
BSD license.  
by Sven Nilsen, 2012  
http://www.cutoutpro.com  

Version: 0.001 in angular degrees version notation  
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html


## How To Use It

    require "groups.lua"

## What Is Group Oriented Programming?

Group Oriented Programming is a paradigm where computations are done with "groups". This is how simple it is (real code!):

    A = B + C * D - E

Read this as "B or C and D, except E".

Here is a more complete example example:

    -- First we need some data to calculate with.
    -- Notice that Clark has no hair member.
    local people = {{name="John", hair=true}, {name="Clark"}}

    -- We can extract the groups we need on the fly.
    local name = groups_HasKey(people, "name")
    local hair = groups_HasKey(people, "hair")

    local name_and_hair = name * hair

    -- Loop through each index in group, starting at offset 1 to match Lua index.
    local person
    for i in group(name_and_hair, 1) do
        person = people[i]
        print(person.name)
    end

## Group Generators

A group generator is a function that iterates through an array and creates a group. The easiest way of doing this is by using the 'ByFunction' function, like this:

    function groups_LessThan(data, prop, value, region)
        return groups_ByFunction(data, function (data, i)
            local item = data[i]
            if item[prop] < value then return true
            else return false end
        end, region)
    end

A group generator can also take a region group as argument to limit the scope of iterations. Using a region group is faster.

    -- A bit slower.
    local US = groups_HasKey(people, "US")
    local name = groups_HasKey(people, "name")
    local name_and_in_US = US * name

    -- A bit faster.
    local US = groups_HasKey(people, "US")
    local name_and_in_US = groups_HasKey(people, "name", US)

It is the group generator that makes the difference. The performance of the algebra is not depending on the size of data, but how fragmented the information in the group is. This is completely determined by the data. When it comes to speed, it is the generators that matters.

## Why Use Group Oriented Programming?

4 top reasons I can think of:

1. Simplicity. Makes code easier to understand. Less headache.
2. Better reuse of code. Group generators are often very generic and useful.
3. Easier to handle complex problems and real data which is often imperfect.
4. Does not require database and SQL, runs a lot faster.

## How Are Groups Working Internally?

A group is an array of slices:

    {start0, end0, start1, end1, ...}

Each slice refers to a range of indices. This format uses less memory and is faster to compute with than iterating through each index. It is easier to read than packed bits.

## What is the Philosophy of Group Oriented Programming?

Group oriented programming is as much about exploring data as using it to automate tasks. By getting hands on data early it can improve the decision process later.

Most code consists of if-blocks and for-loops. This structure does not reflect clearly what happens to the data. If-blocks and for-loops are like microscopes. If you want to see the big picture and get a feeling of how much data is processed, then group oriented programming is nicer to use.

A group is which data to process, while your code should be focused on what to do. It helps you with the decision making. It helps you to keep your code clean.

Group oriented programming is good for solving problems quickly. Then you can delay the decision of which algorithm to use to make it optimal.



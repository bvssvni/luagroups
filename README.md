luagroups - Group oriented programming in Lua

Chan - Concurrency in C
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.000 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html


## How To Use It

    require "groups.lua"

## What Is Group Oriented Programming?

Group Oriented Programming is a paradigm that uses Boolean Algebra On Groups to compute the indices before a for-loop rather than using lots of ifs and "continue" statements. It can also give a boost in overall performance.

The reason it can give performance gain is that behind the scenes it uses a special representation of the groups that require fewer operations when "similar data" is neighbors. This is called a "group bitstream".

Here is an example:

    -- First we need some data to calculate with.
    -- Notice that Clark has no hair member.
    local people = {{name="John", hair=true}, {name="Clark"}}

    -- We can extract the groups we need on the fly.
    local name = groups_HasKey(people, "name")
    local hair = groups_HasKey(people, "hair")

    -- Using operator overloading, we combine groups
    -- and: * or: + except: -
    local name_and_hair = name * hair

    -- Iterate through the indices using the group(t) iterator.
    -- This should print out only "John".
    local person
    for i in group(name_and_hair) do
        -- indices start with 0 in a group but 1 in Lua.
        person = people[i+1]
        print(person.name)
    end

Group Oriented Programming spans over any Boolean Algebra On Groups. It can be implemented with raw bitstream where each bit correspond to an index. This works better for high entropy where the average interval between change is less than 2*64 (64 is number of bits in a double).

Group bitstream is easier to read for humans since it is just a list of ranges ex. [2,4, 6,8, 10,13] where even number mark the start and odd the end. Unlike raw bitstream it also can handle continuous spaces.

One area of research is particular responsible for the invention of group oriented programming. Bitstreams associates properties with number indices. This makes lot of number theory directly applicable. It makes it possible to study the properties of a large space of objects without needing a specific application. Later one can use the data achieved from this to study other problems, using the algebra to calculate solutions.

## Why Use Group Oriented Programming?

Here are 4 top reasons:

1. Preprocessing. For N items, algebra has worst case O(N) but average avg(&lt; N). Which means it speeds up program in many cases.
2. Better code reuse as caused by the generic nature of groups.
3. Easier to solve complex problems step by step and makes debugging easier.
4. Does not require database and SQL, runs a lot faster.

## Writing Your Own Stuff

Because there is a lot of generic algorithms in group oriented programming, I decided to write only one function in this library. It will serve as a prototype for your own custom functions. This way it will be easier to maintain this library without having people depending on it. The function returns a group of all items in an array that has a property.

    <group> groups_HasKey(<a (table)>, <prop (string)>, <region (group, optional)>)

The region to search within the array is optional, but is faster since it does not iterate through the whole array.

    -- A bit slower.
    local US = groups_HasKey(people, "US")
    local name = groups_HasKey(people, "name")
    local name_and_in_US = US * name

    -- A bit faster.
    local US = groups_HasKey(people, "US")
    local name_and_in_US = groups_HasKey(people, "name", US)


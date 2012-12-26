--[[

luagroups - Group oriented programming in Lua.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.007 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

0.007 Moved test units, added 'Item' for creating group of single item.
0.006 Added 'EqualTo', 'FindMaxIndex' and 'FindMinIndex'.
0.005 Made Boolean algorithms easier to read.
0.004 Added optional parameter to group iterator.
0.003 Added comparison against numbers.
0.002 Added empty method.
0.001 Changed table.getn to #.

--]]

--[[
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.
--]]
 
function groups_Or(a, b)
	local list = {}
  setmetatable(list, group_bitstream)

  local a_length = #a
  local b_length = #b

  if a_length == 0 and b_length == 0 then
    return list
  end

  if a_length == 0 then
    for i = 1, b_length do list[#list+1] = b[i] end
    
    return list
  end
  if b_length == 0 then
    for i = 1, a_length do list[#list+1] = a[i] end

    return list
  end

  local i, j = 0, 0
  local isA, isB, was, has = false, false, false, false
  local pa, pb, min
  while i < a_length or j < b_length do
    -- Get the least value.
    if i >= a_length then pa = 2^32 else pa = a[i+1] end
    if j >= b_length then pb = 2^32 else pb = b[j+1] end
    
    if pa < pb then min = pa else min = pb end

    -- Advance the least value, both if both are equal.
    if pa == min then
      isA = not isA
      i = i + 1
    end
    if pb == min then
      isB = not isB
      j = j + 1
    end

    -- Add to result if this changes the truth value.
    has = isA or isB
    if has ~= was then
      list[#list+1] = min
    end

    was = isA or isB
  end

  return list
end

-- Union intersection of groups.
function groups_And(a, b)
  local list = {};
  setmetatable(list, group_bitstream)

  local alength = #a
  local blength = #b
  if alength == 0 or blength == 0 then
    return arr
  end

  local i , j = 0, 0
  local isA, isB, was, has = false, false, false, false
  local pa, pb, min
  while i < alength and j < blength do
    -- Get the last value from each group.
    if i >= alength then pa = 2^32 else pa = a[i+1] end
    if j >= blength then pb = 2^32 else pb = b[j+1] end

    if pa < pb then min = pa else min = pb end

    -- Advance the one with least value, both if they got the same.
    if pa == min then
      isA = not isA
      i = i + 1
    end
    if pb == min then
      isB = not isB
      j = j + 1
    end

    -- Find out if the new change should be added to the result.
    has = isA and isB
    if has ~= was then
      list[#list+1] = min
    end

    was = has
  end

  return list
end

-- Subtracts one group from another.
function groups_Except(a, b)
  local list = {};
  setmetatable(list, group_bitstream)
	
  local a_length = #a
  local b_length = #b
  if b_length == 0 then
    for k = 0, #a-1 do list[k+1] = a[k+1] end
		
    return list
  end

  if a_length == 0 or b_length == 0 then
    return list
  end

  local i, j = 0, 0
  local isA, isB, was, has = false, false, false, false
  local pa, pb, min
  while i < a_length do
    -- Get the last value from each group.
    if i >= a_length then pa = 2^32 else pa = a[i+1] end
    if j >= b_length then pb = 2^32 else pb = b[j+1] end
    
    if pa < pb then min = pa else min = pb end

    -- Advance the group with least value, both if they are equal.
    if pa == min then
      isA = not isA;
      i = i + 1
    end
    if pb == min then
      isB = not isB
      j = j + 1
    end

    -- If it changes the truth value, add to result.
    has = isA and not isB
    if has ~= was then
      list[#list+1] = min
    end

    was = has
  end

  return list
end

-- Returns the size of the group.
function groups_Size(a)
  local size = 0
  for i = 0, #a-1, 2 do
    size = size + a[i+2] - a[i+1]
  end
  return size
end

group_bitstream = {__mul = groups_And, __add = groups_Or, __sub = groups_Except}

-- Iterator for for loops.
-- t is the group.
-- off is offset index to use when returning.
function group(t, off)
  local i, j = 0, -1
  local n = #t
  local stop = 0
  if not off then off = 0 end
  return function ()
    j = j + 1
    if j >= stop then 
      if i >= n then return end
      j = t[i+1]
      stop = t[i+2]
      i = i + 2
    end
    return j+off
  end
end

-- Creates a group of all items in array.
function groups_All(a)
  if #a == 0 then return {} end

  local list = {0, #a}
  setmetatable(list, group_bitstream)
  return list
end

-- Creates an empty group.
function groups_Empty()
  local list = {}
  setmetatable(list, group_bitstream)
  return list
end

-- Creates a group consistring of one element.
function groups_Item(a)
  local list = {a, a+1}
  setmetatable(list, group_bitstream)
  return list
end

-- Creates a group of items in array that have a specific property.
-- a = the array to check items.
-- prop = the field to look for.
-- region (optional) = a group to limit the search within the array.
-- Use this function as template for custom group generation.
function groups_HasKey(a, prop, region)
  local list = {}
  setmetatable(list, group_bitstream)
  
  if region ~= nil then
    local had, has = false, false
    local j = -1
    for i in group(region) do
      -- Check for jumping over ranges, add correction.
      if had and j ~= -1 and i-j > 1 then
        list[#list+1] = j+1
        had = false
      end
      j = i
      
      -- Condition that evaluates to true.
      has = a[i+1] ~= nil and a[i+1][prop] ~= nil
      -- End condition.
      
      if has ~= had then
        list[#list+1] = i
      end
      had = has
    end
    if has then list[#list+1] = j + 1 end
  else
    local had, has = false, false
    for i = 0, #a-1 do
      -- Condition that evaluates to true.
      has = a[i+1] ~= nil and a[i+1][prop] ~= nil
      -- End condition.
      
      if has ~= had then
        list[#list+1] = i
      end
      had = has
    end
    if has then list[#list+1] = #a end
  end
  
  return list
end

-- Uses function to construct a group.
-- The region is optional.
-- The arguments of the function must be
--  function (data, index)
-- The function can be a closure (create by another function).
-- A closure allows you to add extra arguments.
function groups_ByFunction(a, func, region)
  local list = {}
  setmetatable(list, group_bitstream)
  
  if region ~= nil then
    local had, has = false, false
    local j = -1
    for i in group(region) do
      -- Check for jumping over ranges, add correction.
      if had and j ~= -1 and i-j > 1 then
        list[#list+1] = j+1
        had = false
      end
      j = i
      
      -- Condition that evaluates to true.
      has = func(a, i+1)
      -- End condition.
      
      if has ~= had then
        list[#list+1] = i
      end
      had = has
    end
    if has then list[#list+1] = j + 1 end
  else
    local had, has = false, false
    for i = 0, #a-1 do
      -- Condition that evaluates to true.
      has = func(a, i+1)
      -- End condition.
      
      if has ~= had then
        list[#list+1] = i
      end
      had = has
    end
    if has then list[#list+1] = #a end
  end
  
  return list
end

--[[

A common method when dealing with numbers is to compare against a number.
The following functions correspond to < <= > >=

--]]

function groups_EqualTo(data, prop, value, region)
  return groups_ByFunction(data, function (data, i)
      local item = data[i]
      if item[prop] == value then return true
      else return false end
    end, region)
end

function groups_LessThan(data, prop, value, region)
  return groups_ByFunction(data, function (data, i)
      local item = data[i]
      if item[prop] < value then return true
      else return false end
    end, region)
end

function groups_LessOrEqualThan(data, prop, value, region)
  return groups_ByFunction(data, function (data, i)
      local item = data[i]
      if item[prop] <= value then return true
      else return false end
    end, region)
end

function groups_MoreThan(data, prop, value, region)
  return groups_ByFunction(data, function (data, i)
      local item = data[i]
      if item[prop] > value then return true
      else return false end
    end, region)
end

function groups_MoreOrEqualThan(data, prop, value, region)
  return groups_ByFunction(data, function (data, i)
      local item = data[i]
      if item[prop] >= value then return true
      else return false end
    end, region)
end

-- Finds the index of the member with least value within a region.
function groups_FindMinIndex(data, prop, region, offset)
  if not offset then offset = 0 end
  local min = nil
  local minIndex = -1
  if not region then
    local n = #data-1
    for i = 0, n do
      if min == nil or data[i+1][prop] < min then
        min = data[i+1][prop]
        minIndex = i
      end
    end
  else
    for i in group(region) do
      if min == nil or data[i+1][prop] < min then
        min = data[i+1][prop]
        minIndex = i
      end
    end
  end
  return minIndex + offset
end

-- Find the index of the member with largest value within a region.
function groups_FindMaxIndex(data, prop, region, offset)
  if not offset then offset = 0 end
  local max = nil
  local maxIndex = -1
  if not region then
    local n = #data-1
    for i = 0, n do
      if max == nil or data[i+1][prop] > max then
        max = data[i+1][prop]
        maxIndex = i
      end
    end
  else
    for i in group(region) do
      if max == nil or data[i+1][prop] > max then
        max = data[i+1][prop]
        maxIndex = i
      end
    end
  end
  return maxIndex + offset
end

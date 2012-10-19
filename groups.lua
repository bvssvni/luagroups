--[[

luagroups - Group oriented programming in Lua.
BSD license.
by Sven Nilsen, 2012
http://www.cutoutpro.com

Version: 0.002 in angular degrees version notation
http://isprogrammingeasy.blogspot.no/2012/08/angular-degrees-versioning-notation.html

0.001 Changed table.getn to #.
0.002 Added empty method.

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


-- Takes group bitstream OR operation between two groups.
function groups_Or(a, b)
	local list = {};
  setmetatable(list, group_bitstream)
	
	if #a == 0 and #b == 0 then return list end
	if #a == 0 then
    for k = 0, #b-1 do list[k+1] = b[k+1] end
    
		return list
	end
	if #b == 0 then
    for k = 0, #a-1 do list[k+1] = a[k+1] end
		
    return list
	end
	
  local i, j, iO, jO, pa, pb = 0, 0, 0, 0, 0, 0
	local ba, bb, oldB = false, false, false
	while i < #a or j < #b do
    if i >= #a then iO = #a-1 else iO = i end
    if j >= #b then jO = #b-1 else jO = j end
    
		pa, pb = a[iO+1], b[jO+1]
		
		if pa == pb then
			ba = not ba; bb = not bb
			if ((ba or bb) ~= oldB) then list[#list+1] = pa end
			
      i, j = i+1, j+1
		elseif (pa < pb or j >= #b) and i < #a then
			ba = not ba
			if (ba or bb) ~= oldB then list[#list+1] = pa end
      
			i = i + 1
		elseif j < #b then
			bb = not bb
			if (ba or bb) ~= oldB then list[#list+1] = pb end
      
			j = j + 1
		else
			break
    end
		
		oldB = ba or bb
	end -- while loop.
	
	return list
end

-- Union intersection of groups.
function groups_And(a, b)
	local list = {};
  setmetatable(list, group_bitstream)
	
	if #a == 0 or #b == 0 then return list end
	
  local i, j, iO, jO, pa, pb = 0, 0, 0, 0, 0, 0
	local ba, bb, oldB = false, false, false
	while i < #a or j < #b do
    if i >= #a then iO = #a-1 else iO = i end
    if j >= #b then jO = #b-1 else jO = j end
    
		pa, pb = a[iO+1], b[jO+1]
		
		if pa == pb then
			ba = not ba; bb = not bb
			if ((ba and bb) ~= oldB) then list[#list+1] = pa end
			
      i, j = i+1, j+1
		elseif (pa < pb or j >= #b) and i < #a then
			ba = not ba
			if (ba and bb) ~= oldB then list[#list+1] = pa end
      
			i = i + 1
		elseif j < #b then
			bb = not bb
			if (ba and bb) ~= oldB then list[#list+1] = pb end
      
			j = j + 1
		else
			break
    end
		
		oldB = ba and bb
	end -- while loop.
	
	return list
end

-- Subtracts one group from another.
function groups_Except(a, b)
	local list = {};
  setmetatable(list, group_bitstream)
	
	if #a == 0 then return list end
  if #b == 0 then
    for k = 0, #a-1 do list[k+1] = a[k+1] end
		
    return list
  end
	
  local i, j, iO, jO, pa, pb = 0, 0, 0, 0, 0, 0
	local ba, bb, oldB = false, true, false
	while i < #a or j < #b do
    if i >= #a then iO = #a-1 else iO = i end
    if j >= #b then jO = #b-1 else jO = j end
    
		pa, pb = a[iO+1], b[jO+1]
		
		if pa == pb then
			ba = not ba; bb = not bb
			if ((ba and bb) ~= oldB) then list[#list+1] = pa end
			
      i, j = i+1, j+1
		elseif (pa < pb or j >= #b) and i < #a then
			ba = not ba
			if (ba and bb) ~= oldB then list[#list+1] = pa end
      
			i = i + 1
		elseif j < #b then
			bb = not bb
			if (ba and bb) ~= oldB then list[#list+1] = pb end
      
			j = j + 1
		else
			break
    end
		
		oldB = ba and bb
	end -- while loop.
	
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
function group(t)
  local i, j = 0, -1
  local n = #t
  local stop = 0
  return function ()
    j = j + 1
    if j >= stop then 
      if i >= n then return end
      j = t[i+1]
      stop = t[i+2]
      i = i + 2
    end
    return j
  end
end

-- Creates a group of all items in array.
function groups_All(a)
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

function test_groups_Or_1()
  local a = {2, 4}
  local b = {0, 10}
  local c = groups_Or(a, b)
  
  assert(#c == 2)
  assert(c[1] == 0)
  assert(c[2] == 10)
end

function test_groups_Or_2()
  local a = {2, 4}
  local b = {4, 6}
  local c = groups_Or(a, b)
  
  assert(#c == 2)
  assert(c[1] == 2)
  assert(c[2] == 6)
end

function test_groups_And_1()
  local a = {2, 4}
  local b = {3, 5}
  local c = groups_And(a, b)
  
  assert(#c == 2)
  assert(c[1] == 3)
  assert(c[2] == 4)
end

function test_groups_Except_1()
  local a = {2, 4}
  local b = {3, 5}
  local c = groups_Except(a, b)
  
  assert(#c == 2)
  assert(c[1] == 2)
  assert(c[2] == 3)
end

function test_groups_Except_2()
  local a = {2, 8}
  local b = {3, 5}
  local c = groups_Except(a, b)
  
  assert(#c == 4)
  assert(c[1] == 2)
  assert(c[2] == 3)
  assert(c[3] == 5)
  assert(c[4] == 8)
end

function test_groups_HasKey_1()
  local a = {{firstName = "Bill", lastName = "Smith"}, {firstName = "Malcolm"}}
  local b = groups_HasKey(a, "firstName")
  local c = groups_HasKey(a, "lastName")
  
  assert(#b == 2, #b)
  assert(#c == 2, #c)
  assert(b[1] == 0)
  assert(b[2] == 2, b[2])
  assert(c[1] == 0, c[1])
  assert(c[2] == 1)
end

function test_groups_HasKey_2()
  local a = {{x=0,y=0}}
  local xy = groups_HasKey(a, "y", groups_HasKey(a, "x"))
  
  assert(#xy == 2, #xy)
  assert(xy[1] == 0)
  assert(xy[2] == 1)
end

function test_groups_HasKey_3()
  local a = {{x=0,y=0}, {x=0,y=0,z=0}}
  local z = groups_HasKey(a, "z")
  local xz = groups_HasKey(a, "x", z)
  
  assert(#xz == 2, #xz)
  assert(xz[1] == 1)
  assert(xz[2] == 2)
end

function test_groups_HasKey_4()
  local a = {{x=0,y=0}, {x=0,y=0,z=0}, {x=0,y=0}, {x=0,y=0,z=0}, {x=0,y=0}, {x=0,y=0,z=0}}
  local z = groups_HasKey(a, "z")
  local xz = groups_HasKey(a, "x", z)
  
  assert(#xz == 6, #xz)
  assert(xz[1] == 1)
  assert(xz[2] == 2)
  assert(xz[3] == 3)
  assert(xz[4] == 4)
  assert(xz[5] == 5)
  assert(xz[6] == 6)
end

function test_groups()
  test_groups_Or_1()
  test_groups_Or_2()
  test_groups_And_1()
  test_groups_Except_1()
  test_groups_Except_2()
  test_groups_HasKey_1()
  test_groups_HasKey_2()
  test_groups_HasKey_3()
  test_groups_HasKey_4()
end

require "groups"

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

function test_groups_Item_1()
  local a = groups_Item(3)
  assert(a[1] == 3)
  assert(a[2] == 4)
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
  test_groups_Item_1()
end

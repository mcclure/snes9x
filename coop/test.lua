require "pl/init"
require "socket"
require "iuplua"
--local iup = package.loadlib ("iuplua51.dll", "luaopen_iuplua")
print()

iup.Message('YourApp','Finished Successfully!')

print(pretty.write({1,2,3},''))

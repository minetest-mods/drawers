# Drawer Controller Digilines Reference

Drawer controllers can be controlled via Digiline. The Drawer Controller accepts Digiline mesages of the type `"string"` and `"table"` that are convertible to `ItemStack` as documented in [lua_api.md](https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md?plain=1), section "Item formats". Any ItemStack information but name and count are ignored.

Examples:

* `"default:dirt 99"`
* `{ name = "default:dirt", count = 99 }`

The controller will then try its best to take that much of items and inject it into the tube behind it. If there are no enough items to fulfill the requirement, all the remaining items of the same name will be taken.

# Drawer Controller Digilines Reference

Drawer controllers can be controlled via Digiline. The Drawer Controller accepts Digiline mesages of the type `"string"` and `"table"` that are convertible to `ItemStack` as documented in [lua_api.md](https://github.com/luanti-org/luanti/blob/master/doc/lua_api.md?plain=1), section "Item formats". Any ItemStack information but name and count are ignored.

Examples:

* `"default:dirt 99"`
* `{ name = "default:dirt", count = 99 }`

The controller will then try its best to take that much of items and inject it into the tube behind it. If there are no enough items to fulfill the requirement, all the remaining items of the same name will be taken.

## Adding tags to injected items

To use this feature, [tag support](https://github.com/mt-mods/pipeworks/pull/107#issuecomment-1925943467) must be present and enabled on pipeworks. Make sure you're on the latest version of pipeworks.

To assign tags to the injected items, you must use the table format when interacting with the drawer controller. Add one of the following fields to your table. If both `tags` and `tag` are specified, `tags` takes the precedence.

* `tags = { <array of tags> } or "<comma-separated tags>"`
* `tag = "<one single tag>"`

For example, to assign the injected item both the `"factory"` and `"furnace"` tags:

```lua
digiline_send("drawer_controller", {
    name = "default:sand",
    count = 99,
    tags = { "factory", "furnace" },
})
```

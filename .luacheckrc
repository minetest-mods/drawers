
unused = false
max_line_length = 240

globals = {
	"drawers"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Luanti
	"vector", "ItemStack",
	"dump", "VoxelArea",

	-- deps
	"core",
	"default",
	"mcl_core",
	"mcl_sounds",
	"pipeworks",
	"screwdriver",
	"digilines",
	"mesecon",
	"techage"
}

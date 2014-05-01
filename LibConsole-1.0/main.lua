require 'inspect'
require 'Apollo'
require "LibConsole"


local slashCommand = {
	{
		strCommand = "ssi",
		tParams = {
			{
				strDescription = "This command toggle the visibility state of the inventory.",
				func = function(self) 
					print('Toggle visibility')
				end
			},
			{
				strParam = "info",
				bNoHelp = true,
				func = function(self) 
					Print('info')
				end
			},
			{
				strParam = "options",
				tParams = {
					{
						strParam = "RowSize",
						tValidators = { strType = "range", tParams = {4, 32}},
						strDescription = "Define the number of item per row you want.",
						func = function(self, args)
							print("setting " .. self._NAME .."Row Size To "..args)
						end
					},{
					 	strParam = "IconSize",
						tValidators = { strType = "range", tParams = {16, math.huge}},
						strDescription = "Define size of item icons.",
						func = function(self, args) 
							print("setting " .. self._NAME .."Row Size To "..args)
						end
					},{
						strParam = "currency",
						strDescription = "Define the currently tracked alternative currency.",
						tValidators = { strType = "enum" , tParams = {"ElderGem","Prestige","Renown","CraftingVouchers"}},
						funcInvalid = function(self, args) 
							print(arg .. " is not a valid currency[ElderGems,Prestige,Renown,CraftingVouchers]")
						end,
						func = function(self, args)
							print("setting " .. self._NAME .."Row Size To "..args)
						end
					}
				}
			},
			{
				strParam = "loc",
				tValidators = {
					{ strType = "enum" , tParams = { LibConsole.enumSimpleValidators.number}},
					{ strType = "enum" , tParams = { LibConsole.enumSimpleValidators.number}},
					{ strType = "enum" , tParams = { LibConsole.enumSimpleValidators.number}},
					{ strType = "enum" , tParams = { LibConsole.enumSimpleValidators.number}}
				}
			},
			{
				strParam = "redraw",
				bNoHelp = true,
				func = function(self)
					Print('redraw')
				end
			}	
		}
	}
}

LibConsole:RegisterSlashCommands(slashCommand,LibConsole)


LibConsole:OnRegisteredCommand("ssi", " options RowSize 15")
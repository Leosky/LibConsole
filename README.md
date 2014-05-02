LibConsole
==========

A lib to handle command building through table with validations (patterns, enum, magic word etc)


Currently the lib isn't usable. Multiple arguments and zero arguments are still to handle and error detection too.


Quick start
===========

Simply build your command definition and then send it to LibConsole with :

    LibConsole.registerSlashCommand(tCommands, tHandler)

Then, if the user us a registred command, LibConsole will validate it given the validators you gave it. Every command have a help command linked to hit if you dont have marked them to not have help.

Here is a self explaining exemple covering the most classical aspects :

    local slashCommand = { {
        strCommand = "ssi",
        tParams = {{
            strDescription = "This command toggle the visibility state of the inventory.",
            func = function(self) self:ToggleVisibility() end
          },{
            strParam = "debug",
            bNoHelp = true,
            func = function(self) self.glog:debug(inspect(self)) end
          },{
            strParam = "options",
            tParams = {{
                strParam = "RowSize",
                tValidators = {{ strType = "range", tParams = {4, 32}}},
                strDescription = "Define the number of item per row you want.",
                func = function(self, args) self.wndMain.FindChild("inventory"):SetBoxPerRow(args[1]) end
              },{
                strParam = "IconSize",
                tValidators = {{ strType = "simple" , tParams = {"number"} }},
                strDescription = "Define size of item icons.",
                func = function(self, args)  self.wndMain.FindChild("inventory"):SetSquareSize(args[1]) end
              },{
                strParam = "currency",
                strDescription = "Define the currently tracked alternative currency.",
                tValidators = { {strType = "enum" , tParams = {"ElderGem","Prestige","Renown","CraftingVouchers"}}},
                funcInvalid = function(self, args) 
                  print(arg .. " is not a valid currency[ElderGems/Prestige/Renown/CraftingVouchers]")
                end,
                func = function(self, args) print("setting " .. self._NAME .."Row Size To "..args) end
              }
            }
          },{
            strParam = "loc",
            tValidators = {
              { strType = "simple" , tParams = { "number" }},
              { strType = "simple" , tParams = { "number" }},
              { strType = "simple" , tParams = { "number" }},
              { strType = "simple" , tParams = { "number" }}
            },
            func = function(self, args) self:MoveToLoc(args) end
          }
        }
      }
    }
    LibConsole.RegisterSlashCommands(slashCommand,self)
        

now if you type cmd '/ssi help', the implicit function is called based on your strParam, strDescription and tValidators and will show this output for the current exemple : 

    /ssi - This command toggle the visibility state of the inventory.
    /ssi options RowSize [number(4 to 32)] - Define the number of item per row you want.
    /ssi options IconSize [number] - Define size of item icons.
    /ssi options currency [ElderGem/Prestige/Renown/CraftingVouchers] - Define the currently tracked alternative currency.
    /ssi loc [number] [number] [number] [number]

If you type a valid instruction the function `func` will be called or will raise an error if the parameters arn't correct and eventually a `funcInvalid` :

    /ssi option IconSize KABOUM
    [Command] Invalid parameter (KABOUM)
    
If you dont want to use the base validators, you can skip tValidators. Then, every args will be accepted for a given command + params, but you are still able to call yourself `LibConsole.validate`. For exemple if your command support a variable number of args.

Bugs
====
Actualy there is only few use case so test havent been very exhausive. And pattern validator havn't been tested at all. So expect error but if you still use it, dont esitate to contact me for help / debug.

-----------------------------------------------------------------------------------------------------------------------
-- LibConsole-1.0.lua - rev1 (TODO DATE)
-- Hendrick "Leosky" Francois - kheless [AT] gmail [DOT] com
-- TODO
-- inspired by AceConsole-3.0
-----------------------------------------------------------------------------------------------------------------------
require "Apollo"

local LibConsole = {
  _NAME = "LibConsole",
  _VERSION = {MAJOR = 'LibConsole-1.0', MINOR = 1},
  _URL     = 'TODO',
  _DESCRIPTION = 'TODO',
  _LICENSE = [[
The MIT License (MIT)

Copyright (c) 2014 Hendrick "Leosky" Francois

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
  ]]
}

-- Lua APIs

LibConsole.RegisteredShashCommand = {}
LibConsole.CommandHandler = {}
function LibConsole:OnLoad()

end

function LibConsole:RegisterSlashCommands( tSlashCommand, tHandler )

	for idx=1,  #tSlashCommand do 
		LibConsole:RegisterSlashCommand( tSlashCommand[idx].strCommand,  tSlashCommand[idx].tParams, tHandler)
		Apollo.RegisterSlashCommand(tSlashCommand[idx].strCommand,"OnRegisteredCommand",self)

	end

end

function LibConsole:RegisterSlashCommand( strName, tParams, tLuaEventHandler )
    LibConsole.RegisteredShashCommand[strName] = tParams
    LibConsole.CommandHandler[strName] = tLuaEventHandler
    print(inspect(LibConsole.RegisteredShashCommand))
	for k, v in pairs(tParams) do
		if k == "strDescription" then

		elseif k == "func" then
		elseif k == "strFunc" then
		elseif k == "bNoHelp" then

		elseif k == "rangeValidator" then
		elseif k == "enumValidator" then
		elseif k == "simpleValidator" then
		elseif k == "patternValidator" then
		elseif k == "tValidators" then
		elseif k == "strParam" then
		elseif k == "nArgsExpected" then
		
		elseif k == "fOnInvalid" then
		elseif k == "tParams" then
			--nested param
		end

		
	end
end

function LibConsole:OnRegisteredCommand(strCommand, strParams)
	local tParams = {}

    for param in string.gmatch(strParams, "[^%s]+") do
	    table.insert(tParams,param)
	end

    local tTemp = LibConsole.RegisteredShashCommand[strCommand]
    local tHandler = LibConsole.CommandHandler[strCommand]
    for k, v in pairs(tParams) do --iterating furnished parameters
        for i,j in pairs(tTemp) do --iterating registered parameters
            local nArgsExpected = j.nArgsExpected or 1  --TODO Change for to handle 0 nedded args
            if #tParams - nArgsExpected < k then -- only func args are present so a func should be present
                --extracting them from tParams to build de args array for func
                local args = {}
                for idx = k, #tParams do
                        table.insert(args, tParams[k])
                end
                tTemp.func(tHandler, v)
                break
            elseif j.strParam == v then
                --there is more parameters neded so 
                if j.tParams then
                    tTemp = j.tParams
                else
                    tTemp = j
                end
                break
            end
            
        end

    end
    
end

function LibConsole:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
    return o
end

Apollo.RegisterPackage(LibConsole, LibConsole._VERSION.MAJOR, {})
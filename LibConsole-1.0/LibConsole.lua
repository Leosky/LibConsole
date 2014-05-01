-----------------------------------------------------------------------------------------------------------------------
-- LibConsole-1.0.lua - rev1 (1 may 2014)
-- Hendrick "Leosky" Francois - kheless [AT] gmail [DOT] com
-- A lib to handle command building through table with validations (patterns, enum, magic word etc) 
-- inspired by AceConsole-3.0
-----------------------------------------------------------------------------------------------------------------------
require "Apollo"
require "ChatSystemLib"

local LibConsole = {
  _NAME = "LibConsole",
  _VERSION = {MAJOR = 'LibConsole-1.0', MINOR = 1},
  _DESCRIPTION = 'A lib to handle command building through table with validations (patterns, enum, magic word etc) ',
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


LibConsole.embeds = {}
LibConsole.RegisteredShashCommands = {}
LibConsole.CommandHandlers = {}

LibConsole.enumTypeValidators = {
    range = "range", 
    simple = "simple", 
    enum = "enum", 
    pattern = "pattern"
}

LibConsole.enumSimpleValidators = {
    number = "number", --integer or floating
    string = "string", --text surounded with quotes "", internal " have to be escaped (/")
    char = "char"
}

function LibConsole.validate(tValidator, arg)
    local eType = LibConsole.enumTypeValidators[tValidator.strType]

    if eType == LibConsole.enumTypeValidators.simple then
        local eSimpleType = tValidator.tParams[1]

        if eSimpleType == LibConsole.enumSimpleValidators.number then
            if type(tonumber(arg)) == "number" then return true end
        elseif eSimpleType == LibConsole.enumSimpleValidators.string then
            if type(arg) == "string" then return true end
        elseif eSimpleType == LibConsole.enumSimpleValidators.char then
            if type(arg) == "string" and #arg == 1 then return true end
        else
            error("SimpleValidator type isn't recognized (".. tValidator.eSimpleType ..').')
        end
    elseif eType == LibConsole.enumTypeValidators.range then
        local assertion = assert(tValidator.tParams and #tValidator.tParams ==2, "LibConsole error : Range  validator isn't well formated. Expected {min, max}.")
        if not assertion then return false end
        local min = tValidator.tParams[1]
        local max = tValidator.tParams[2]

        if tonumber(arg) ~= il and (tonumber(arg) <= max and tonumber(arg) >= min) then return true end
    elseif eType == LibConsole.enumTypeValidators.enum then
        local assertion = assert(type(tValidator.tParams) == "table", "LibConsole error : Enum validator seems to no be well formated.")
        if not assertion then return false end

        for i=1, #tValidator.tParams do
            if tValidator.tParams[i] == arg then 
                return true
            end
        end
    elseif eType == LibConsole.enumTypeValidators.pattern then
        local assertion = assert(type(tValidator.tParams) == "string", "LibConsole error : Pattern should be a string.")
        if not assertion then return false end

        return string.match (arg, tValidator.tParams)
    else
        error("Validator type isnt recognized (".. tValidator.strType ..').')
    end

    return false
end

function LibConsole.RegisterSlashCommands( tSlashCommand, tHandler )

    for idx=1,  #tSlashCommand do 
        LibConsole.RegisteredShashCommands[tSlashCommand[idx].strCommand] = tSlashCommand[idx].tParams
        LibConsole.CommandHandlers[tSlashCommand[idx].strCommand] = tHandler
        Apollo.RegisterSlashCommand( tSlashCommand[idx].strCommand,"OnRegisteredCommand", tHandler )

    end

end

function LibConsole.appendHelp(tTable, strBuffer)

    local strCloneBuffer = strBuffer
    for k, v in pairs(tTable) do
        if not (v.tParams or v.bNoHelp) then
            if  v.tValidators then
                Print(strCloneBuffer.. (v.strParam and " " .. v.strParam or "") .. LibConsole.appendValidators(v.tValidators) .. (v.strDescription and " - " .. v.strDescription or ""))
            else
                Print(strCloneBuffer.. (v.strParam and " " .. v.strParam or "") .. (v.strDescription and " - " .. v.strDescription or ""))
            end
            
        elseif v.tParams then 
            LibConsole.appendHelp(v.tParams, strCloneBuffer .. " " .. v.tParams)
        end
    end
end

function LibConsole.appendValidators(tValidators)
    local str = ""
    for i=1,#tValidators do

        str = str .. " " .. LibConsole.appendValidator(tValidators[i])
    end
    return str
end

function LibConsole.appendValidator(tValidator)
    local eType = LibConsole.enumTypeValidators[tValidator.strType]

    if eType == LibConsole.enumTypeValidators.simple then

        local eSimpleType = tValidator.tParams[1]
        if eSimpleType == "number" then
            return "[number]"
        elseif eSimpleType == "string" then
            return "[string]"
        elseif eSimpleType == "char" then
            return "[char]"
        end

    elseif eType == LibConsole.enumTypeValidators.range then

        local min = tValidator.tParams[1]
        local max = tValidator.tParams[2]

        return  "[number(".. min.." to " .. max .. ")]"
    elseif eType == LibConsole.enumTypeValidators.enum then


        local str = "["
        for i=1, #tValidator.tParams do
            str = str .. tValidator.tParams[i] .. ((i ~= #tValidator.tParams and "/") or "")
        end
        return str .. "]"
    elseif eType == LibConsole.enumTypeValidators.pattern then

        return "[pattern(".. tValidator.tParams .. ")]"
    else
        error("Validator type isnt recognized (".. tValidator.strType ..').')
    end

    return "[arg]"
end

function LibConsole.OnRegisteredCommand(strCommand, strParams)
    local tParams = {}

    local stringParam
    local isStringParam = false
    for param in string.gmatch(strParams, "[^%s]+") do
        
        if isStringParam then
            stringParam = stringParam .. " " ..param
            if param:sub(#param,#param) == '"' then
                isStringParam = false
                table.insert(tParams,stringParam)
                stringParam = ""
            end
        elseif param:sub(1,1) == '"' then
            isStringParam = true
            stringParam = param
        else
            table.insert(tParams,param)
        end
    end
    
    if tParams[1] == "help" then
        local tTemp = LibConsole.RegisteredShashCommands[strCommand]
        for k, v in pairs(tTemp) do

            if not (v.tParams or v.bNoHelp) then

                if v.tValidators then
                    Print("/".. strCommand .. (v.strParam and " " .. v.strParam or "") .. LibConsole.appendValidators(v.tValidators) .. (v.strDescription and " - " .. v.strDescription or ""))
                else
                    Print("/".. strCommand .. (v.strParam and " " .. v.strParam or "") .. (v.strDescription and " - " .. v.strDescription or ""))
                end 
            elseif v.tParams then 
                LibConsole.appendHelp(v.tParams, "/"..strCommand .. " " .. v.strParam)
            end
        end
    else

        local tTemp = LibConsole.RegisteredShashCommands[strCommand]
        local tHandler = LibConsole.CommandHandlers[strCommand]
        local nLastParamUsedIdx = 0
        if #tParams == 0 then --simple command without parameters
            for k, v in pairs(tTemp) do
                if not v.strParam then
                    v.func(tHandler)
                    break
                end
            end
        else
            for k, v in pairs(tParams) do --iterating furnished parameters
                nLastParamUsedIdx = k
                for i,j in pairs(tTemp) do --iterating registered parameters

                    if ((j.strParam ~= nil) and (v == "" or nil)) or j.strParam == v then
                        if j.tParams then
                            tTemp = j.tParams
                            
                        else
                            tTemp = j
                            goto final_param_found
                        end
                        break
                    end
                    
                end

            end
            ::final_param_found::
            
            local nArgsExpected = (tTemp.tValidators and #tTemp.tValidators) or 0

            if #tParams - nLastParamUsedIdx >= nArgsExpected  or tTemp.bArgValidation == false then
                local args = {}
                    for idx = nLastParamUsedIdx+1, #tParams do
                        table.insert(args, tParams[idx])
                    end

                    local valid
                    for i=1,#tTemp.tValidators do
                        valid = LibConsole.validate(tTemp.tValidators[i], args[i])
                        if not valid then
                            ChatSystemLib.PostOnChannel( ChatSystemLib.ChatChannel_Command,"Invalid parameter (".. args[i] ..")")
                            if tTemp.funcInvalid then tTemp.funcInvalid(tHandler, args) end
                            return
                        end
                    end
                    tTemp.func(tHandler, args)
            else
                ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Command,"Invalid number of parameters (".. nArgsExpected .." value(s) expected)")
            end
        end
    end
end

local mixins = {
    "RegisterSlashCommands",
    "validate"
} 

-- Embeds AceConsole into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed AceBucket in
function LibConsole:Embed( target )
    for k, v in pairs( mixins ) do
        target[v] = self[v]
    end
    self.embeds[target] = true
    return target
end

Apollo.RegisterPackage(LibConsole, LibConsole._VERSION.MAJOR, {})

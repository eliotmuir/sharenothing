local Project = require 'iguana.project'

local function ReadFile(Name)
   local F = io.open(Name, "rb")
   local C = F:read('*a')
   F:close()
   return C
end

local function ProjectDir(Tree)
   for K in pairs(Tree) do
      if K ~= "shared" and K ~= 'other' then
        return K 
      end
   end
end

local function GetLocalContent(Path, Tree)
   local Parts = Path:split("/")
   for i=1,#Parts do
      Tree = Tree[Parts[i]]
   end
   return Tree
end

local function GetSharedContent(Path, Tree)
   local Parts = Path:split(".")
   Parts[#Parts] = Parts[#Parts]..".lua"
   for i=1,#Parts do
      Tree = Tree[Parts[i]]
   end
   return Tree
end

local function GetOtherContent(Path, Tree)
   local Parts = Path:split("/")
   for i=1,#Parts do
      Tree = Tree[Parts[i]]
   end
   return Tree
end

local function Convert(T)
   local FileName = T.project
   local Zip = ReadFile(FileName)
   local Out = filter.zip.inflate(Zip)
   local Dir = ProjectDir(Out)
   local Prj = json.parse{data=Out[Dir]["project.prj"]}
   local P = Project()
   for i=1, #Prj.LocalDependencies do
      P:addLocalFile(Prj.LocalDependencies[i], GetLocalContent(Prj.LocalDependencies[i], Out[Dir]))
   end
   for i=1, #Prj.LuaDependencies do
      P:addLocalFile(Prj.LuaDependencies[i]:gsub("%.", "/")..".lua", GetSharedContent(Prj.LuaDependencies[i], Out['shared']))     
   end
   for i=1, #Prj.OtherDependencies do
      P:addLocalFile(Prj.OtherDependencies[i], GetOtherContent(Prj.OtherDependencies[i], Out['other']))
   end
   P:main(Out[Dir]["main.lua"])
   return P:compile()
end

return Convert
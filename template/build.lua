----------------------------------------------------------------------------------------------------------------
--
-- groverburger's love2d game build script for macos
-- windows and mac export are currently supported
--
----------------------------------------------------------------------------------------------------------------
--
-- basic usage:
--
-- put this file in the same directory as your main.lua file
-- run 'luajit build.lua --setup' for first-time setup (note: setup expects wget and unzip to be installed)
-- just run this script with 'luajit build.lua' to invoke the build process
-- this script will by default automatically build a .love file and export to windows and mac
-- if you want to build to only one platform, specify it directly with arguments listed below
--
--
-- argument list:
--
-- '--windows' or '--win' build to windows
-- '--mac' build to mac
-- '--compile' compile to a .love file
-- '--setup' sets up a proper build environment
-- '--to' specifies a custom build name for this build, expects another argument after it for use as its name
--
--
-- what this script DOESN'T do:
--
-- you still must manually change the Info.plist file in your macos app
-- you still must manually change your game's icon
-- for more details, check the wiki: https://love2d.org/wiki/Game_Distribution

local date = os.date("%B%d_T%H%M")
local dir = date
local game = nil -- change this to the name of your game
local loveVersion = 11.4 -- keep this up to date with the latest version of love

function CompileDotLove()
    print("----------------------------------------------------------------------------------------------------")
    print("compiling .love file")
    print("----------------------------------------------------------------------------------------------------")

    -- zip all game assets
    -- automatically excludes unnecessary files, especially .git and anything that contains the word 'unused'
    os.execute("zip -r builds/game.zip . -x '*.git*' '*unused*' '*.DS_Store' '*builds*' 'tags' '*.wiki'")

    -- rename the zip file to a love file
    os.execute("mv builds/game.zip builds/game.love")
end

function Windows()
    print("----------------------------------------------------------------------------------------------------")
    print("building windows")
    print("----------------------------------------------------------------------------------------------------")

    -- combine the love.exe and and game.love to game.exe
    os.execute("cat builds/love.exe builds/game.love > builds/" .. game .. ".exe")

    -- zip the exe and all dlls into win.zip
    -- cd into ./builds to make this a flat zip with no folder inside it
    os.execute("cd ./builds && zip win.zip " .. game .. ".exe *.dll")

    -- clean the unnecessary game.exe file from the builds folder
    os.execute("rm -r ./builds/" .. game .. ".exe")

    -- make a directory for this build if it doesn't already exist
    os.execute("mkdir builds/"..dir)

    -- move the build into the build directory and give it a more verbose name
    os.execute("cd ./builds && mv win.zip " .. dir .. "/" .. game .. "" .. date .. "_win.zip")
end

function Mac()
    print("----------------------------------------------------------------------------------------------------")
    print("building mac")
    print("----------------------------------------------------------------------------------------------------")

    -- put the game.love file inside the given game.app
    -- f option to mv means to force an overwrite if it encounters a name conflict (which it will)
    os.execute("cp -f builds/game.love builds/" .. game .. ".app/Contents/Resources/game.love")

    os.execute("codesign --remove-signature --deep builds/" .. game .. ".app")

    -- zip game.app and keep links (might not be necessary)
    -- cd to make it a flat zip with no folder inside it
    os.execute("cd ./builds && zip -r -y mac.zip " .. game .. ".app")

    -- make a directory for this build if it doesn't already exist
    os.execute("mkdir builds/"..dir)

    -- move the build into the build directory and give it a more verbose name
    os.execute("cd ./builds && mv mac.zip " .. dir .. "/" .. game .. "" .. date .. "_mac.zip")
end

function Setup()
    print("----------------------------------------------------------------------------------------------------")
    print("setting up")
    print("----------------------------------------------------------------------------------------------------")

    -- create the builds folder
    os.execute("mkdir builds")

    -- get mac stuff
    -- and move it into the builds folder
    os.execute("wget https://github.com/love2d/love/releases/download/" .. loveVersion .. "/love-" .. loveVersion .. "-macos.zip")
    os.execute("unzip love-" .. loveVersion .. "-macos.zip")
    os.execute("mv love.app builds/" .. game .. ".app")

    -- get windows stuff
    -- and move it into the builds folder
    os.execute("wget https://github.com/love2d/love/releases/download/" .. loveVersion .. "/love-" .. loveVersion .. "-win64.zip")
    os.execute("unzip love-" .. loveVersion .. "-win64.zip")
    os.execute("mv love-" .. loveVersion .. "-win64/*.dll builds/")
    os.execute("mv love-" .. loveVersion .. "-win64/love.exe builds/")

    -- cleanup
    os.execute("rm love-" .. loveVersion .. "-macos.zip")
    os.execute("rm love-" .. loveVersion .. "-win64.zip")
    os.execute("rm -r love-" .. loveVersion .. "-win64")
end

assert(game, "Please name your game in build.lua!")

local doall = true
for i=1, #arg do
    if arg[i] == "--compile" then
        CompileDotLove()
        doall = false
    end
    if arg[i] == "--win" or arg[i] == "--windows" then
        Windows()
        doall = false
    end
    if arg[i] == "--mac" then
        Mac()
        doall = false
    end

    if arg[i] == "--setup" then
        Setup()
        doall = false
    end

    -- give this build a custom name
    if (arg[i] == "--file" or arg[i] == "--to") and arg[i+1] then
        dir = arg[i+1]
    end
end

-- by default recompile .love file and build do both platforms
if doall then
    CompileDotLove()
    Windows()
    Mac()
end

print("----------------------------------------------------------------------------------------------------")
print("done")
print("----------------------------------------------------------------------------------------------------")
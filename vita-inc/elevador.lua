-- lock
local _pullEvent = os.pullEvent
os.pullEvent = os.pullEventRaw

local FLOORS = {
    "andar 1", "andar 2", "andaer 3", "andar quatr"
}

local THIS_FLOOR = 1 --mudar pra cada andar
local curr_floor = 1
local curr_sel = THIS_FLOOR --mudar se quiserr
local modem = peripheral.wrap("back") --mudar o lado caso prec8ise

if not modem then
    error("modem nao encontrado")
end

if not rednet.isOpen("back") then
    print("modem desligado, ligando")
    rednet.open("back")
    sleep(1)
end

-- liga os pc
local names = modem.getNamesRemote()
for i, name in ipairs(names) do
    if not modem.callRemote(name, "isON") then
        local _id = modem.callRemote(name, "getID")
        local _label = modem.callRemote(name, "getLabel")
        write("terminal ")
        if _label then
            write(_label)
        else
            write("n".._id)
        end
        print(" desligado, ligando. . .")
        modem.callRemote(name, "turnOn")
        sleep(0.1)
    end
end

-- UI
local function display()
    term.clear()
    term.setCursorBlink(false)
    term.setCursorPos(1, 1)

    print("terminal do andar "..THIS_FLOOR)
    print("atualmente no andar "..curr_floor)
    --print("s "..curr_sel)
    print("")

    for i=1, #FLOORS do
        if i == curr_sel then
            write("> ")
        else
            write("  ")
        end
        print(FLOORS[i])
    end
end

local function main()
    display()

    -- rednet_message: event, senderID, message, protocol
    -- key: event, key, is_hold
    local e, key, msg = os.pullEvent()

    if e == "key" then
        if key == keys.down and curr_sel < #FLOORS then
            curr_sel = curr_sel + 1
        elseif key == keys.up and curr_sel > 1 then
            curr_sel = curr_sel - 1
        elseif key == keys.enter then
            if curr_sel == curr_floor then
                print("")
                print("vc ja ta nesse andar")
                sleep(1)
            else
                curr_floor = curr_sel
                print("mudando estado dos pistoes. . .")
                redstone.setOutput("top", (curr_sel > THIS_FLOOR))
                sleep(1)
                print("pront o")
                print("")

                --write("enviando dados para rede. . .")
                rednet.broadcast(curr_floor)
                --print( ("enviado: (%d)"):format(curr_floor) )
                --sleep(5)
            end
        end
    elseif e == "rednet_message" then
        curr_floor = tonumber(msg)
        --print( ("dados recebidos: (%d)"):format(tonumber(msg)) )
        --sleep(5)
        redstone.setOutput("top", (curr_floor > THIS_FLOOR) )
        sleep(1)
    end
end

while true do
    local drive = peripheral.find("drive")
    if drive ~= nil and drive.getDiskLabel() == "MOD_DISK" then
        term.setCursorPos(1, 12)
        print("disco de modificacao inserido")
        print("terminandoo programa")
        sleep(1)
        break
    end
    main()
end

os.pullEvent = _pullEvent

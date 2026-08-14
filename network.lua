-- network.lua - Network Library

local network = {}

function network.init()
    local modem = peripheral.find("modem")
    if modem then
        rednet.open(peripheral.getName(modem))
        return true
    end
    return false
end

function network.broadcast(message, protocol)
    if rednet.isOpen() then
        rednet.broadcast(message, protocol)
    end
end

function network.receive(protocol, timeout)
    if rednet.isOpen() then
        return rednet.receive(protocol, timeout)
    end
    return nil
end

return network

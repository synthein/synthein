local Timer = require("timer")

local Repair = class()

function Repair:__create(bodyList)
    self.bodyList = bodyList
end

function Repair:update(moduleInputs, location)
    local findNew = true

    local cb = self.currentBody
    local cf = self.currentFixture
    local bl = self.bodyList
    local t = self.timer

    if cb and cf and t and bl[cb] and bl[cb][cf] then
        if t:ready(moduleInputs.dt) then
            cf:getUserData().repair(1)
            self.currentBody = nil
            self.currentFixture = nil
            self.currentHealth = nil
            self.timer = nil
        else
            findNew = false
        end
    else
        self.currentBody = nil
        self.currentFixture = nil
        self.currentHealth = nil
        self.timer = nil
    end

    if findNew then
        for body, fixtures in pairs(self.bodyList) do
            -- check hostility
            local bodyObject = body:getUserData()
            local teamHostility = moduleInputs.teamHostility

            if bodyObject and bodyObject.getTeam and not teamHostility:test(self.team, bodyObject:getTeam()) then
                for fixture, visable in pairs(fixtures) do
                    local object = fixture:getUserData()
                    if object.getScaledHealth then
                        local health = object:getScaledHealth()
                        if health ~= 1 then
                            if not self.timer or self.currentHealth > health then
                                self.currentBody = body
                                self.currentFixture = fixture
                                self.currentHealth = health
                                self.timer = Timer(1)
                            end
                        end
                    end
                end
            end
        end
    end

    if self.timer then
        self.active = true
    else
        self.active = false
    end
end

function Repair:setTeam(team)
    self.team = team
end

return Repair

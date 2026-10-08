local api = require("api")
local Theme = require("aa-perfection/core/theme")
local Guard = require("aa-perfection/core/api_guard")
local Settings = require("aa-perfection/core/settings")
local Mover = require("aa-perfection/core/mover")
local Scanner = require("aa-perfection/modules/inventory/bag_scanner")
local Categories = require("aa-perfection/modules/inventory/categories")

local BagView = {
    window = nil,
    slots = {},
    activeCategory = Categories.KEYS.ALL,
    searchQuery = "",
    isOpen = false,
    itemButtons = {},
    maxDisplaySlots = 100
}

local COLUMNS = 10
local SLOT_SIZE = 42
local SLOT_GAP = 4
local PADDING = 12

function BagView:Init()
    local x, y = Settings:GetPosition("inventory", 600, 200)

    local wnd = api.Interface:CreateEmptyWindow("pui_bag_window", "UIParent")
    wnd:SetExtent((COLUMNS * (SLOT_SIZE + SLOT_GAP)) + (PADDING * 2) - SLOT_GAP, 580)
    wnd:AddAnchor("TOPLEFT", "UIParent", x, y)
    wnd:SetUILayer("game")

    Theme.ApplyBackdrop(wnd, Theme.Colors.BgDark, Theme.Colors.BorderSubtle)
    Theme.ApplyBorder(wnd, Theme.Colors.BorderActive)

    -- Header Title
    local title = wnd:CreateChildWidget("label", "title", 0, true)
    title:SetText("INVENTORY")
    Theme.StyleLabel(title, 14, ALIGN.LEFT, Theme.Colors.TextGold, true)
    title:AddAnchor("TOPLEFT", wnd, PADDING, PADDING)

    -- Capacity Indicator
    local capacityLabel = wnd:CreateChildWidget("label", "capacity", 0, true)
    capacityLabel:SetText("0 / 0")
    Theme.StyleLabel(capacityLabel, 11, ALIGN.RIGHT, Theme.Colors.TextSecondary, true)
    capacityLabel:AddAnchor("TOPRIGHT", wnd, -PADDING - 24, PADDING + 2)
    wnd.capacityLabel = capacityLabel

    -- Close Button
    local closeBtn = wnd:CreateChildWidget("button", "closeBtn", 0, true)
    closeBtn:SetExtent(18, 18)
    closeBtn:AddAnchor("TOPRIGHT", wnd, -PADDING, PADDING)
    closeBtn:SetText("X")
    Theme.StyleLabel(closeBtn, 12, ALIGN.CENTER, Theme.Colors.TextMuted, false)
    closeBtn:SetHandler("OnClick", function()
        BagView:Show(false)
    end)

    -- Search Bar
    local searchEdit = W_CTRL.CreateEdit("pui_bag_search", wnd)
    searchEdit:SetExtent(wnd:GetWidth() - (PADDING * 2), 24)
    searchEdit:AddAnchor("TOPLEFT", title, "BOTTOMLEFT", 0, 8)
    searchEdit:SetText("")
    searchEdit:SetHandler("OnTextChanged", function(selfEdit)
        BagView.searchQuery = tostring(selfEdit:GetText() or ""):lower()
        BagView:Refresh()
    end)
    wnd.searchEdit = searchEdit

    -- Category Tabs Row
    local catNames = {
        { id = Categories.KEYS.ALL, label = "All" },
        { id = Categories.KEYS.GEAR, label = "Gear" },
        { id = Categories.KEYS.CONSUMABLE, label = "Consumables" },
        { id = Categories.KEYS.REGRADE, label = "Regrade" },
        { id = Categories.KEYS.MATERIALS, label = "Materials" },
        { id = Categories.KEYS.TRADE, label = "Trade" }
    }
    local tabX = PADDING
    wnd.catButtons = {}
    for _, tab in ipairs(catNames) do
        local btn = wnd:CreateChildWidget("button", "cat_" .. tab.id, 0, true)
        btn:SetExtent(68, 22)
        btn:AddAnchor("TOPLEFT", searchEdit, "BOTTOMLEFT", tabX - PADDING, 6)
        btn:SetText(tab.label)
        Theme.StyleLabel(btn, 10, ALIGN.CENTER, Theme.Colors.TextSecondary, false)
        api.Interface:ApplyButtonSkin(btn, BUTTON_BASIC.DEFAULT)

        btn:SetHandler("OnClick", function()
            BagView.activeCategory = tab.id
            BagView:Refresh()
        end)
        wnd.catButtons[tab.id] = btn
        tabX = tabX + 72
    end

    -- Currency Footer
    local goldLabel = wnd:CreateChildWidget("label", "goldLabel", 0, true)
    goldLabel:SetText("0g 00s 00c")
    Theme.StyleLabel(goldLabel, 12, ALIGN.RIGHT, Theme.Colors.TextPrimary, true)
    goldLabel:AddAnchor("BOTTOMRIGHT", wnd, -PADDING, -PADDING)
    wnd.goldLabel = goldLabel

    -- Item Slots Container
    local gridStartY = PADDING + 24 + 8 + 24 + 6 + 26
    local slotParent = wnd:CreateChildWidget("emptywidget", "slotGrid", 0, true)
    slotParent:SetExtent(COLUMNS * (SLOT_SIZE + SLOT_GAP), 400)
    slotParent:AddAnchor("TOPLEFT", wnd, PADDING, gridStartY)
    wnd.slotParent = slotParent

    -- Pre-create slot buttons
    for i = 1, self.maxDisplaySlots do
        local col = (i - 1) % COLUMNS
        local row = math.floor((i - 1) / COLUMNS)
        local posX = col * (SLOT_SIZE + SLOT_GAP)
        local posY = row * (SLOT_SIZE + SLOT_GAP)

        local btn = CreateItemIconButton("pui_bag_slot_" .. i, slotParent)
        btn:SetExtent(SLOT_SIZE, SLOT_SIZE)
        btn:AddAnchor("TOPLEFT", slotParent, posX, posY)
        F_SLOT.ApplySlotSkin(btn, btn.back, SLOT_STYLE.BAG_DEFAULT)
        btn:Show(false)

        local countLabel = btn:CreateChildWidget("label", "count", 0, true)
        countLabel:SetExtent(SLOT_SIZE, 12)
        countLabel:AddAnchor("BOTTOMRIGHT", btn, -2, -2)
        Theme.StyleLabel(countLabel, 10, ALIGN.RIGHT, Theme.Colors.TextPrimary, true)
        btn.countLabel = countLabel

        btn:SetHandler("OnClick", function(selfBtn)
            if selfBtn.__item and selfBtn.__item.slot then
                Guard.EquipBagItem(selfBtn.__item.slot, false)
            end
        end)

        btn:SetHandler("OnEnter", function(selfBtn)
            if selfBtn.__item and selfBtn.__item.rawInfo then
                local px, py = selfBtn:GetOffset()
                local text = selfBtn.__item.name
                if selfBtn.__item.rawInfo.linkText then
                    text = selfBtn.__item.rawInfo.linkText
                end
                api.Interface:SetTooltipOnPos(text, selfBtn, px + SLOT_SIZE, py)
            end
        end)

        self.itemButtons[i] = btn
    end

    Mover:RegisterFrame("inventory", wnd, "Inventory (Bag)")
    self.window = wnd
    wnd:Show(false)

    -- Intercept stock bag keybind and window
    if UIC ~= nil and UIC.BAG ~= nil then
        Guard.RegisterContentTriggerFunc(UIC.BAG, function(show)
            BagView:Toggle()
        end)
        Guard.ShowStockContent(UIC.BAG, false)
    end
end

function BagView:Refresh()
    if not self.isOpen or self.window == nil then return end

    local items, usedCount, capacity = Scanner:ScanBag()
    self.window.capacityLabel:SetText(string.format("%d / %d", usedCount, capacity))

    -- Format Currency
    local curGold = Guard.GetCurrency()
    self.window.goldLabel:SetText(Theme.FormatMoney(curGold))

    -- Filter items by Category & Search
    local filtered = {}
    for _, item in ipairs(items) do
        local catMatch = (self.activeCategory == Categories.KEYS.ALL) or (item.category == self.activeCategory)
        local searchMatch = true
        if self.searchQuery ~= "" then
            searchMatch = item.name:lower():find(self.searchQuery, 1, true) ~= nil
        end

        if catMatch and searchMatch then
            table.insert(filtered, item)
        end
    end

    -- Render Slots
    for i = 1, self.maxDisplaySlots do
        local btn = self.itemButtons[i]
        local item = filtered[i]
        if item ~= nil then
            btn.__item = item
            if item.icon ~= "" then
                F_SLOT.SetIconBackGround(btn, item.icon)
            end
            if item.count > 1 then
                btn.countLabel:SetText(tostring(item.count))
                btn.countLabel:Show(true)
            else
                btn.countLabel:Show(false)
            end
            btn:Show(true)
        else
            btn.__item = nil
            btn:Show(false)
        end
    end
end

function BagView:Show(show)
    self.isOpen = show and true or false
    if self.window ~= nil then
        self.window:Show(self.isOpen)
        if self.isOpen then
            self:Refresh()
        end
    end
end

function BagView:Toggle()
    self:Show(not self.isOpen)
end

return BagView

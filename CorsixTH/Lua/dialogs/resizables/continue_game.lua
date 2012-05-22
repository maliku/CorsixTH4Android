
class "ContinueGame"

function ContinueGame:ContinueGame(ui)
  -- Initialize the tree node
  local root = ui.app.savegame_dir
  local treenode = LoadSaveFileTreeNode(root)
  treenode.label = "Saves"
  local idx = 1

  print (self:getLastSaveFile(treenode))
  -- LoadGameFile(node.path)
  --ui.app:load(node.path)
end

function ContinueGame:getLastSaveFile(root)
    root:checkForChildren()
    root:reSortChildren("date", "descending")
    print (root.path)
    for i, child in ipairs(root.children) do
        print (child.path)
        if child:hasChildren() then
            local node = self:getLastSaveFile(child)
            if (node) then 
                return node 
            end
        elseif child:isValidFile(child.path) then
            return child.path
        else
            print (child.path .. " is a empty dir or invalid save file.")
        end
    end
end

--[[ function ContinueGame:listChildren(root)
    root:checkForChildren()
    root:reSortChildren("date", "descending")
    for i, child in ipairs(root.children) do
        print (child.path)
        if child:hasChildren() then
            self:listChildren(child)
        end
    end
end ]]

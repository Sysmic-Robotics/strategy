-- sysmickit/file_reader.lua

local FileReader = {}
FileReader.__index = FileReader

function FileReader.new(filepath)
  local self = setmetatable({}, FileReader)
  self.filepath = filepath
  self.file = io.open(filepath, "r")

  if not self.file then
    error(" Failed to open file: " .. filepath)
  end

  return self
end

function FileReader:lines()
  return self.file:lines()
end

function FileReader:close()
  if self.file then
    self.file:close()
    self.file = nil
  end
end

return FileReader

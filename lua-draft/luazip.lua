require "zip"

local zfile, err = zip.open('build-vs13.zip')

-- print the filenames of the files inside the zip
for file in zfile:files() do
	print(file.filename)
end

zfile:close()
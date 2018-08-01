-- Copyright (c) Robert 'Bobby' Zenz
--
-- Licensed under CC0 or Public Domain


--- Creates a new card element from the given range.
-- 
-- A "card" is a simple group which represents a single item, for example
-- a project. The only assumption that should be met is that card starts with
-- a header as first element.
-- 
-- @param blocks The list of blocks to use.
-- @param startIndex The index at which the card content starts (inclusive).
-- @param endIndex The index at which the card content ends (inclusive).
-- @return The card element.
function createCard(blocks, startIndex, endIndex)
	local content = {}
	local image = nil
	
	local startAtIndex = startIndex
	
	-- Add the first element because that is always a header.
	table.insert(content, blocks[startIndex])
	startAtIndex = startAtIndex + 1
	
	-- If the first element (after the header) is a paragraph containing
	-- a single single image, we will skip it. Later the remaining content and
	-- the image will be placed in separate elements.
	if isParagraphWithImage(blocks[startAtIndex]) then
		image = blocks[startAtIndex]
		startAtIndex = startAtIndex + 1
	end
	
	-- If the next element is a bullet list, mark it as the "Technologies" list.
	if blocks[startAtIndex].t == "BulletList" then
		table.insert(content, wrap({ blocks[startAtIndex] }, "technologies"))
		startAtIndex = startAtIndex + 1
	end
	
	-- Add the remaining content to the card.
	for index = startAtIndex, endIndex - 1 do
		table.insert(content, blocks[index])
	end
	
	-- If the last element is a list, mark it as the "Links" list.
	-- Otherwise just add it.
	if blocks[endIndex].t == "BulletList" then
		table.insert(content, wrap({ blocks[endIndex] }, "links"))
	else
		table.insert(content, blocks[endIndex])
	end
	
	-- Create an ID for the card from the header.
	local id = createId(blocks[startIndex]);
	
	-- If an image was found, wrap the content into its own element and make
	-- them siblings.
	if image ~= nil then
		local wrappedContent = wrap(content, "content", "content-" .. id)
		
		content = {
			image,
			wrappedContent
		}
	end
	
	-- Return the created card element.
	return wrap(content, "card", "card-" .. id)
end

--- Creates an ID from the content of the given block.
-- 
-- An ID in this case is a string which does only contain the characters from
-- A-Z and hyphens, and is all in lower case.
-- 
-- @param block The block to use.
-- @return The created ID.
function createId(block)
	local id = pandoc.utils.stringify(block)
	id = string.lower(id)
	id = string.gsub(id, "[^a-z0-9- ]", "")
	id = string.gsub(id, " ", "-")
	
	return id;
end

--- Creates a section element from the given range.
-- 
-- A "section" is an overall group of cards.
-- 
-- @param blocks The list of blocks to use.
-- @param startIndex The index at which the section content starts (inclusive).
-- @param endIndex The index at which the section content ends (inclusive).
-- @return The section element.
function createSection(blocks, startIndex, endIndex)
	local content = {}
	
	-- Find all "sections", meaning everything between two headers of level 2.
	processPart(blocks, 2, startIndex, endIndex, function(blocks, startIndex, endIndex)
		table.insert(content, createCard(blocks, startIndex, endIndex))
	end)
	
	-- Create an ID for the section from the header.
	local id = createId(blocks[startIndex]);
	
	-- Wrap the content once.
	local wrappedContent = wrap(
			content,
			"section-wrapper",
			"section-wrapper-" .. id)
	
	-- Gather up the content of the section.
	local sectionContent = {
		blocks[startIndex],
		wrappedContent
	}
	
	-- Return the created section.
	return wrap(sectionContent, "section", "section-" .. id)
end

--- Tests if the given block is a header of a certain level.
-- 
-- @param block The Block to test.
-- @param level The level to test for, can be nil for no specific level.
-- @param true if the given block is a header of the requested level.
function isHeader(block, level)
	return block ~= nil
			and block.t == "Header"
			and (level == nil or block.level == level)
end

--- Tests if the given block is a paragraph with a single image.
-- 
-- @param block The block to test.
-- @return true if the given block is a paragraph with a single image inside.
function isParagraphWithImage(block)
	return block ~= nil
			and block.t == "Para"
			and #block.c == 1
			and block.c[1].t == "Image"
end

--- Finds the index of the next header block.
-- 
-- @param blocks The blocks to search through.
-- @param level The level of the header to find, can be nil to find any.
-- @param startIndex The index at which to start the search (inclusive).
-- @param endIndex The index at which to stop (inclusive), can be nil for
--                 searching through all blocks.
-- @return The index of the found header, 0 if none was found.
function findNextHeaderIndex(blocks, level, startIndex, endIndex)
	if endIndex == nil then
		endIndex = #blocks
	end
	
	for index = startIndex, endIndex do
		if isHeader(blocks[index], level) then
			return index
		end
	end
	
	return 0
end

--- Invokes the given processor for each part.
-- 
-- A "part" in this case is a list of blocks which is framed by headers of
-- the given level.
-- 
-- @param blocks The blocks to use.
-- @param level The level of the header, can be nil for any.
-- @param startIndex The index at which to start (inclusive).
-- @param endIndex The index at which to stop (inclusive).
-- @param partProcessor The processor, a function which accepts the blocks,
--                      the start index and the end index of the part.
function processPart(blocks, level, startIndex, endIndex, partProcessor)
	local index = findNextHeaderIndex(blocks, level, startIndex, endIndex)
	local limit = math.min(#blocks, endIndex)
	
	while index > 0 and index < limit do
		local nextIndex = findNextHeaderIndex(blocks, level, index + 1)
		
		if nextIndex < 1 or nextIndex >= limit then
			nextIndex = limit + 1
		end
		
		partProcessor(blocks, index, nextIndex - 1)
		
		index = nextIndex
	end
end

--- Wraps the given content (a list of blocks) into a new Div element.
-- 
-- @param content The content to wrap, a list of blocks.
-- @param class The class to assign to the created element.
-- @param id The ID to assign to the created element.
-- @return A new Div element which wraps the given content.
function wrap(content, class, id)
	local attributes = {}
	
	if class ~= nil then
		table.insert(attributes, { "class", class })
	end
	
	if id ~= nil then
		table.insert(attributes, { "id", id })
	end
	
	return pandoc.Div(content, pandoc.Attr("", {}, attributes))
end


-- The main function follows.

return {{
	Image = function(image)
		-- If there is an image which starts with "svg:" we'll convert it to
		-- an inlined SVG icon.
		if string.sub(image.src, 1, 4) == "svg:" then
			local iconName = string.sub(image.src, 5)
			
			return pandoc.RawInline(
					"html",
					"<svg class=\"icon\"><use xlink:href=\"./icons.svg#" .. iconName .. "\"></use></svg>")
		end
	end,
	
	Pandoc = function(document)
		local blocks = document.blocks
		
		local content = {}
		
		processPart(document.blocks, 1, 1, #document.blocks, function(blocks, startIndex, endIndex)
			table.insert(content, createSection(blocks, startIndex, endIndex))
		end)
		
		return pandoc.Pandoc(content, document.meta)
	end
}}

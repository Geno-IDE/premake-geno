local p = premake
local project = p.project
local tree = p.tree
local m = { }

-- Alphabetic Compare
local function alphabeticCompare( a, b )
	local len = math.min( a:len(), b:len() )
	for i = 1, len do
		local CharA = a:sub( i, i )
		local CharB = b:sub( i, i )

		local LowerCharA = CharA:lower()
		local LowerCharB = CharB:lower()

		if LowerCharA == LowerCharB then
			if CharA > CharB then
				return true
			elseif CharA < CharB then
				return false
			end
		elseif LowerCharA < LowerCharB then
			return true
		elseif LowerCharA > LowerCharB then
			return false
		end
	end

	return a:len() < b:len()
end

-- Properties
local props = function()
	return {
		m.name,
		m.kind,
		m.fileFilters,
		m.files,
		m.includedirs,
		m.librarydirs,
		m.defines,
		m.libraries,
	}
end

-- Generate project
function p.extensions.geno.generateproject( prj )
	p.indent( "\t" )
	p.callArray( props, prj )
end

-- Name
function m.name( prj )
	p.w( "Name:%s", prj.name )
end

-- Kind
function m.kind( prj )
	local map = {
		WindowedApp = "Application",
		ConsoleApp  = "Application",
		StaticLib   = "StaticLibrary",
		SharedLib   = "DynamicLibrary",
	}
	p.w( "Kind:%s", map[ prj.kind ] )
end

-- File Filters
function m.fileFilters( prj )
	if ( #prj.files > 0 ) then
		local fileFilters     = {}
		local fileFilterStack = {}
		local curFileFilter

		local tr = project.getsourcetree( prj )
		tree.traverse( tr, {
			onbranchenter = function( node, depth )
				table.insert( fileFilterStack, curFileFilter )
				curFileFilter = node.path
			end,
			onbranch = function( node, depth )
				fileFilters[ node.path ] = {
					Name  = node.path,
					Path  = nil,
					Files = {}
				}
			end,
			onbranchexit = function( node, depth )
				curFileFilter = table.remove( fileFilterStack )
			end,
			onleaf = function( node, depth )
				if curFileFilter then
					local fileFilter = fileFilters[ curFileFilter ]
					if not fileFilter.Path then
						fileFilter.Path = path.getdirectory( node.relpath )
					end
					table.insert( fileFilter.Files, node.relpath )
				end
			end
		} )

		local sortedFileFilters = {}
		for _, v in pairs( fileFilters ) do
			if v.Files and #v.Files > 0 then
				table.sort( v.Files, alphabeticCompare )
			end
			table.insert( sortedFileFilters, v )
		end
		table.sort( sortedFileFilters, function( a, b )
			return alphabeticCompare( a.Name, b.Name )
		end )
		fileFilters = sortedFileFilters

		p.push "FileFilters:"
		for _, v in ipairs( fileFilters ) do
			if v.Files and #v.Files > 0 and v.Path then
				p.push( "%s:", v.Name )
				p.w( "Path:%s", v.Path )
				
				p.push "Files:"
				for _, file in ipairs( v.Files ) do
					p.w( "%s", file )
				end
				p.pop()

				p.pop()
			end
		end
		p.pop()
	end
end

-- Files
function m.files( prj )
	if( #prj.files > 0 ) then
		p.push "Files:"

		tree.traverse( project.getsourcetree( prj ), {
			onleaf = function( node, depth )
				p.w( "%s", node.relpath )
			end,
		} )

		p.pop()
	end
end

-- IncludeDirs
function m.includedirs( prj )
	if( #prj.includedirs > 0 or #prj.sysincludedirs > 0 ) then
		p.push "IncludeDirs:"
		for _, dir in ipairs( prj.includedirs ) do
			local relativepath = path.getrelative( prj.location, dir )
			p.w( "%s", relativepath )
		end
		for _, dir in ipairs( prj.sysincludedirs ) do
			local relativepath = path.getrelative( prj.location, dir )
			p.w( "%s", relativepath )
		end
		p.pop()
	end
end

-- LibraryDirs
function m.librarydirs( prj )
	local dependencies = p.project.getdependencies( prj, "linkOnly" )
	if( #dependencies > 0 ) then
		p.push "LibraryDirs:"
		for _, dep in ipairs( dependencies ) do
			local relativepath = path.getrelative( prj.location, dep.location )
			p.w( "%s", relativepath )
		end
		p.pop()
	end
end

-- Defines
function m.defines( prj )
	if( #prj.defines > 0 ) then
		p.push "Defines:"
		for _, define in ipairs( prj.defines ) do
			p.w( "%s", define )
		end
		p.pop()
	end
end

-- Libraries
function m.libraries( prj )
	if( #prj.links > 0 ) then
		p.push "Libraries:"
		for _, link in ipairs( prj.links ) do
			p.w( "%s", link )
		end
		p.pop()
	end
end

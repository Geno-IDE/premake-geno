local p = premake
local m = { }

-- Properties
local props = function()
	return {
		m.name,
		m.matrix,
		m.projects,
	}
end

-- Generate workspace
function p.extensions.geno.generateworkspace( wks )
	p.indent( "\t" )
	p.callArray( props, wks )
end

-- Name
function m.name( wks )
	p.w( "Name:%s", wks.name )
end

-- Matrix
function m.matrix( wks )
	p.push "Matrix:"

	p.push "Platforms:"
	for _, platform in ipairs( wks.platforms ) do
		p.w( "%s", platform )
	end
	p.pop()

	p.push "Configurations:"
	for _, configuration in ipairs( wks.configurations ) do
		p.w( "%s", configuration )
	end
	p.pop()

	p.pop()
end

-- Projects
function m.projects( wks )
	if( #wks.projects > 0 ) then
		p.push "Projects:"
		for _, prj in ipairs( wks.projects ) do
			local relativelocation = path.getrelative( wks.location, prj.location )
			local projectpath = path.join( relativelocation, prj.name )
			p.w( projectpath )
		end
		p.pop()
	end
end

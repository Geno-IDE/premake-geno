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
		p.push( "%s:", platform )
		-- TODO: Override this per-project based on 'toolset'
		p.w( "Compiler:%s", iif( os.istarget( "windows" ), "MSVC", "GCC" ) )
		p.pop()
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

		-- Build the list in an order such that no project is built before its dependencies
		local projects = { }
		local addprojectrecursive
		addprojectrecursive = function( subprojects )
			for _, subproject in ipairs( subprojects ) do
				addprojectrecursive( p.project.getdependencies( subproject ) )
				table.insert( projects, subproject )
			end
		end
		addprojectrecursive( wks.projects )
		projects = table.unique( projects )

		for i = #projects,1,-1 do
			local prj = projects[ i ]
			local relativelocation = path.getrelative( wks.location, prj.location )
			local projectpath = path.join( relativelocation, prj.name )
			p.w( projectpath )
		end
		p.pop()
	end
end

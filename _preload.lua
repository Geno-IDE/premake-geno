local p           = premake
p.extensions.geno = { _VERSION = "1.0.0" }

--
-- Create the Geno action
--

newaction {
	-- Metadata
	trigger     = "geno",
	shortname   = "Geno",
	description = "Generate project files for the Geno IDE: https://github.com/Geno-IDE/Geno",

	-- Capabilities
	valid_kinds = {
		"ConsoleApp",
		"WindowedApp",
		"StaticLib",
		"SharedLib",
	},
	valid_languages = {
		"C",
		"C++",
	},
	valid_tools = {
		cc = {
			"msc",
			"gcc",
		}
	},

	-- Workspace generatorn
	onWorkspace = function( wks )
		p.generate( wks, ".gwks", p.extensions.geno.generateworkspace )
	end,

	-- Project generator
	onProject = function( prj )
		p.generate( prj, ".gprj", p.extensions.geno.generateproject )
	end,
}

--
-- Decide when the full module should be loaded.
--
return function( cfg )
	return ( _ACTION == "geno" )
end

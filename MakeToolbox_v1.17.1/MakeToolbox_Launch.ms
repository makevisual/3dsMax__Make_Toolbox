global MakeToolbox 				-- The UI item for the  Main toolbox
global MT_Settings 				-- The UI item for the settings dialog box
global MT_SidebarCustomPresets 	-- The UI item for the custom presets
global MT_functions				-- The functions for the toolbox
global MT_files 				= @"U:/Make_Tools/MakeToolbox/Release/MakeToolbox_v1.17.1/"
global MT_VersionNumber		    = "1.17.1"

filein ( MT_files + @"/bin/MakeToolboxSidebar.ms" )
filein ( MT_files + @"/bin/MakeToolboxAutobak.ms" )

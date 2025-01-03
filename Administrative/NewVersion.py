# NewVersion.py build by Aaron Dabelow theonlyaaron@gmail.com for aiding in versioning maxscripts and their installers
# Source information block must be updated each time the script is run to specify the original and new versions
# Update elements block must be updated for each script that this is used for. It is designed to help version easily

import shutil
from datetime import date

# Source information to be populated throughout the installation
versionedBy = "Aaron Dabelow theonlyaaron@gmail.com"
srcVersion = "1.17.2"
newVersion = "1.18"
curDir = "U:/Make_Tools/MakeToolbox/Release/"
folderName = "MakeToolbox_v"

# Copy the current state to a new directory
srcVersionDir = curDir + folderName + srcVersion + "/"
newVersionDir = curDir + folderName + newVersion + "/"
shutil.copytree(srcVersionDir, newVersionDir, symlinks=False, ignore=None)

# Update MakeToolbox_Launch.ms
launchFile = open(newVersionDir + "MakeToolbox_Launch.ms", 'w')
contents = 'global MakeToolbox 				-- The UI item for the  Main toolbox\n'
contents += 'global MT_Settings 				-- The UI item for the settings dialog box\n'
contents += 'global MT_SidebarCustomPresets 	-- The UI item for the custom presets\n'
contents += 'global MT_functions				-- The functions for the toolbox\n'
contents += 'global MT_files 				= @"' + newVersionDir + '"\n'
contents += 'global MT_VersionNumber		    = "' + newVersion + '"\n\n'
contents += 'filein ( MT_files + @"/bin/MakeToolboxSidebar.ms" )\n'
# contents += 'filein ( MT_files + @"/bin/MakeToolboxAutobak.ms" )\n'
launchFile.write(contents)
launchFile.close()

# Update Readme
readmeFile = open(srcVersionDir + "readme.txt", 'r')
contentsOld = readmeFile.read()
readmeFile.close()

contentsNew = "---- " + folderName + newVersion + " ----\n"
contentsNew += "-- Date: " + str(date.today()) + "\n"
contentsNew += "-- Modifications by: " + versionedBy + "\n"
contentsNew += "-- Change Log:\n"
contentsNew += "\n"
contents = contentsNew + contentsOld

readmeFile = open(newVersionDir + "readme.txt", 'w')
readmeFile.write(contents)
readmeFile.close()

print"Complete!"
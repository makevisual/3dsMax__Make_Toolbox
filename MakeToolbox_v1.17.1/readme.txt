---- MakeToolbox_v1.17.1 ----
-- Date: 2015-08-26
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
	* Fixed toolbar height on displays up to 1440 pixels in height
	* Added global Version Number control

---- MakeToolbox_v1.16 ----
-- Date: 2015-08-26
-- Modifications by: Aaron Dabelow theonlyaaron@gmail.com
-- Change Log:
	* Added versioning tool

Build V1.15 Update - 5/11/2015
	* Main UI
		* Changed toolobx to run off of the network module repository instead of relying on a locally installed version
		* Updated for installation to 3dsmax 2016
		* Bug Fixes
	* Point Cache Batch
		* Added automatic enable/disable point caches during caching and loading

Build V1.14 Update - 2/10/2015
	* Main UI
		* Remembers last used panel on startup
		* Improved default module sets
	* IK Stretch 
		* Now functions propertly
	* Modifier globals
		* Added class 'Displace'
		* Added class 'Quad Champfer'
		* Fixed off index dropdown
	* Mirror Rig - impliment homebuilt version
		* Rename Issue
		* Flip normals on geometry
		* Parent / Unparent bug

Build V1.13 Update - 1/8/2014
	* Added the quick pick right to the main UI, making the MT_ModuleLoader.ms unnessary.
	* Toolbox now remembers previous tab selections, including custom presets.
	* MT_AE-TransformsExporter.ms
		Added version number
		Introduced (replaces old position exporter) It is ported from the standalone script
		Has camera FOV exporting now (no need for .rpf cameras anymore)
	* MT_AE-PositionExporter.ms
		Decommisioned (replaced by TransformsExporter)
	* MT_Cluster_attach.ms
			Added version number
		Fixed bug where attaching instanced objects can end in recursive geo generation
	* MT_ColorsThinger.ms
		Added version number
		Added 2 custom color fields
	* MT_ControllerTools.ms
		Added version number
		Added Copy/Paste and Save/Load toggle
	* MT_EditPivots.ms
		Added version number
		removed floor pivot function
		added bottom pivot function - which sets the pivot to center x and center y, but min z. Good for assets
	* MT_LayoutTools.ms
		Decommisioned ( unnessary in max 2013+ )
	* MT_Lock_Transforms.ms
		Added version number
		Made the locks into a smaller version, which can be display by the "more" button, and removed by the "less" button.
	* MT_ModuleLoader.ms
		Decommisioned ( unnessary with the 1.13 sidebar )
	* MT_PointCacheBatch.ms
		Added version number
		added rig check - checks the objects selected for a point_cache modifier
		added rig setup - places a point_cache modifier at an appropriate place in the modifier stack, if the is no place, it reports bad object.
	* MT_Raymaker.ms
		added version number
		fixed 2013 skin envelope bug
	* MT_Rivetmaker.ms
		Decommisioned (replaced by MT_RivetObjects.ms)
	* MT_RivetObjects.ms
		Added version number
		Fixed error on selecting an object without a skin modifier
	* MT_WheelMaker.ms
		Added version number
		Added to toolbox

Build V1.2 Update - 12/14/2012
	* Toolbox now remembers previous docking and position settings on startup.
	* Toolbox now remembers previous tab selections, including custom presets.
	* Updated presets to read and write to file
	* Changed the default sets of modules for each tab
	* Created installers / uninstallers for 3dsMax2011 and 3dsMax2013
	* Fixed the logs formatting, by making it bigger, faster, and more intense.
	* Added Module - Geometry Primitives, creates spheres and cylinders that are all quads.
	* Added Module - TurntableMaker, create turntables, with cameras.
	* Added Module - Module Loader, allows faster and simpler access to all modules.
	* Added Module - Texture Resizer, creates various lod versions of selected textures.
	* Added Module - Basic Rigs, which has stretchPoint, pistonMaker, gimbal chain, ctrl ring, and ik Stretch.
	* Added Module - AE Transforms Exporter - Replaced the old exporter, now with rotation and scale!
	* Updated Module - Particle Bake, Now you can cancel baking during process.
	* Removed Module - AE Position Exporter - Now obsolete
		
Build V1.1 Update - 6/11/2012
	* Added Module - Group Cache, for applying a point cache to a group of objects and saves as a new file.
	* Added Module - Raymaker, for creating a spline ray between points
	* Updated 'Skinnin tools' - to fix a bug when running when not on the modify panel
		
Build V1.1 Update - 6/6/2012
	* Added Module - Turntable Maker, makes turntables with a rotating camera, for set frame range.
	* Added Module - Skinning Tools, allows you to skin to parent with a rigid bind. Usefull for point caches.
	* Updated the MT_autobak to not save a file during animation playback.
	* Updated updating .bat files
		
Build V1.0 Update - 3/29/2012
	* Added links to the Video Help, and Minor bug fixes.
	* http://www.makevisual.com/learning/
		
Initial Build V1.0 - 3/27/2012
	* This is the first build, code contributed by Aaron Dabelow, Tyson Ibele, and Romain Faure, for MAKE.
	* If there are any issues with this script package, please contact me at aarond@makevisual.com
	and include as much information as possible regarding the error.
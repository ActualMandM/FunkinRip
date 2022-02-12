#if polymod
import polymod.backends.OpenFLBackend;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules.LinesParseFormat;
import polymod.format.ParseRules.TextFileFormat;
import polymod.Polymod;
#end

/**
 * Okay now this is epic.
 */
class ModCore
{
	/**
	 * The current API version.
	 * Must be formatted in Semantic Versioning v2; <MAJOR>.<MINOR>.<PATCH>.
	 * 
	 * Remember to increment the major version if you make breaking changes to mods!
	 */
	static final API_VERSION = "0.1.0";

	static final MOD_DIRECTORY = "mods";

	public static function initialize()
	{
		#if polymod
		trace("Initializing ModCore..."); // logInfo
		loadModsById(getModIds());
		#else
		trace("ModCore not initialized; not supported/enabled on this platform.");
		#end
	}

	#if polymod
	public static function loadModsById(ids:Array<String>)
	{
		trace('Attempting to load ${ids.length} mods...'); // logInfo
		var loadedModList = polymod.Polymod.init({
			// Root directory for all mods.
			modRoot: MOD_DIRECTORY,
			// The directories for one or more mods to load.
			dirs: ids,
			// Framework being used to load assets. We're using a CUSTOM one which extends the OpenFL one.
			framework: CUSTOM,
			// The current version of our API.
			apiVersion: API_VERSION,
			// Call this function any time an error occurs.
			errorCallback: onPolymodError,
			// Enforce semantic version patterns for each mod.
			// modVersions: null,
			// A map telling Polymod what the asset type is for unfamiliar file extensions.
			// extensionMap: [],

			frameworkParams: buildFrameworkParams(),

			// Use a custom backend so we can get a picture of what's going on,
			// or even override behavior ourselves.
			customBackend: ModCoreBackend,

			// List of filenames to ignore in mods. Use the default list to ignore the metadata file, etc.
			ignoredFiles: Polymod.getDefaultIgnoreList(),

			// Parsing rules for various data formats.
			parseRules: buildParseRules(),
		});

		trace('Mod loading complete. We loaded ${loadedModList.length} / ${ids.length} mods.'); // logInfo

		for (mod in loadedModList)
			trace('  * ${mod.title} v${mod.modVersion} [${mod.id}]'); // logTrace

		var fileList = Polymod.listModFiles("IMAGE");
		trace('Installed mods have replaced ${fileList.length} images.'); // logInfo
		for (item in fileList)
			trace('  * $item'); // logTrace

		fileList = Polymod.listModFiles("TEXT");
		trace('Installed mods have replaced ${fileList.length} text files.'); // logInfo
		for (item in fileList)
			trace('  * $item'); // logTrace

		fileList = Polymod.listModFiles("MUSIC");
		trace('Installed mods have replaced ${fileList.length} music files.'); // logInfo
		for (item in fileList)
			trace('  * $item'); // logTrace

		fileList = Polymod.listModFiles("SOUND");
		trace('Installed mods have replaced ${fileList.length} sound files.'); // logInfo
		for (item in fileList)
			trace('  * $item'); // logTrace
	}

	static function getModIds():Array<String>
	{
		trace('Scanning the mods folder...'); // logInfo
		var modMetadata = Polymod.scan(MOD_DIRECTORY);
		trace('Found ${modMetadata.length} mods when scanning.'); // logInfo
		var modIds = [for (i in modMetadata) i.id];
		return modIds;
	}

	static function buildParseRules():polymod.format.ParseRules
	{
		var output = polymod.format.ParseRules.getDefault();
		// Ensure TXT files have merge support.
		output.addType("txt", TextFileFormat.LINES);

		// You can specify the format of a specific file, with file extension.
		// output.addFile("data/introText.txt", TextFileFormat.LINES)
		return output;
	}

	static inline function buildFrameworkParams():polymod.FrameworkParams
	{
		return {
			assetLibraryPaths: [
				"default" => "./"
			]
		}
	}

	static function onPolymodError(error:PolymodError):Void
	{
		// Perform an action based on the error code.
		switch (error.code)
		{
			// case "parse_mod_version":
			// case "parse_api_version":
			// case "parse_mod_api_version":
			// case "missing_mod":
			// case "missing_meta":
			// case "missing_icon":
			// case "version_conflict_mod":
			// case "version_conflict_api":
			// case "version_prerelease_api":
			// case "param_mod_version":
			// case "framework_autodetect":
			// case "framework_init":
			// case "undefined_custom_backend":
			// case "failed_create_backend":
			// case "merge_error":
			// case "append_error":
			default:
				// Log the message based on its severity.
				switch (error.severity)
				{
					case NOTICE:
						trace(error.message, null); // logInfo
					case WARNING:
						trace(error.message, null); // logWarn
					case ERROR:
						trace(error.message, null); // logError
				}
		}
	}
	#end
}

#if polymod
class ModCoreBackend extends OpenFLBackend
{
	public function new()
	{
		super();
		trace('Initialized custom asset loader backend.'); // logTrace
	}

	public override function clearCache()
	{
		super.clearCache();
		trace('Custom asset cache has been cleared.'); // logWarn
	}

	public override function exists(id:String):Bool
	{
		trace('Call to ModCoreBackend: exists($id)'); // logTrace
		return super.exists(id);
	}

	public override function getBytes(id:String):lime.utils.Bytes
	{
		trace('Call to ModCoreBackend: getBytes($id)'); // logTrace
		return super.getBytes(id);
	}

	public override function getText(id:String):String
	{
		trace('Call to ModCoreBackend: getText($id)'); // logTrace
		return super.getText(id);
	}

	public override function list(type:PolymodAssetType = null):Array<String>
	{
		trace('Listing assets in custom asset cache ($type).'); // logTrace
		return super.list(type);
	}
}
#end

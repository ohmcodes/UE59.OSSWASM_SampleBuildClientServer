using UnrealBuildTool;
using System.Collections.Generic;

// Dedicated server build of the same game (needs a source-built engine).
public class OSSWASM_SampleServerTarget : TargetRules
{
	public OSSWASM_SampleServerTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Server;
		DefaultBuildSettings = BuildSettingsVersion.V8;

		ExtraModuleNames.AddRange(new string[] { "OSSWASM_Sample" });
	}
}

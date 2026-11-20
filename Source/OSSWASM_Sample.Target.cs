// Fill out your copyright notice in the Description page of Project Settings.

using UnrealBuildTool;
using System.Collections.Generic;

public class OSSWASM_SampleTarget : TargetRules
{
	public OSSWASM_SampleTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Game;
		DefaultBuildSettings = BuildSettingsVersion.V8;

		ExtraModuleNames.AddRange( new string[] { "OSSWASM_Sample" } );
	}
}

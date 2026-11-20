// Fill out your copyright notice in the Description page of Project Settings.

using UnrealBuildTool;
using System.Collections.Generic;

public class OSSWASM_SampleEditorTarget : TargetRules
{
	public OSSWASM_SampleEditorTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V8;

		ExtraModuleNames.AddRange( new string[] { "OSSWASM_Sample" } );
	}
}

#import "ical_application.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "iCal.h"

// ---------------------------------- Application ---------------------------------

void iCal_TERMINATE(sLONG_PTR *pResult, PackagePtr pParams){	
	//requires 10.6 or later
	
	if(NSClassFromString(@"NSRunningApplication")){
		NSArray *array = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iCal"];
		if([array count]) 
			[(NSRunningApplication *)[array objectAtIndex:0] terminate];
	}
}

void iCal_LAUNCH(sLONG_PTR *pResult, PackagePtr pParams){	
	[[NSWorkspace sharedWorkspace]launchApplication:@"iCal"];		
}

// ---------------------------------- iCal Direct ---------------------------------

void iCal_SHOW_EVENT(PA_PluginParameters params){
/*
	PackagePtr pParams = (PackagePtr)params->fParameters;
	
	C_TEXT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	NSString *eventId = Param1.copyUTF16String();
		
	appleScriptExecuteFunction(@"show_event", @"show_event", eventId, nil, nil);
	
	[eventId release];	
 */
}

void iCal_SHOW_TASK(PA_PluginParameters params){
/*	
	PackagePtr pParams = (PackagePtr)params->fParameters;
	
	C_TEXT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	NSString *taskId = Param1.copyUTF16String();
	
	appleScriptExecuteFunction(@"show_task", @"show_task", taskId, nil, nil);
	
	[taskId release];
 */
}

void iCal_SET_VIEW(PA_PluginParameters params){
	
	iCalApplication *iCal = [SBApplication applicationWithBundleIdentifier:@"com.apple.iCal"];
	
	PackagePtr pParams = (PackagePtr)params->fParameters;
	
	C_LONGINT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	switch (Param1.getIntValue()){
		case 0:
		//	appleScriptExecuteFunction(@"switch_view", @"switch_view", @"Day", nil, nil);
			[iCal switchViewTo:iCalCALViewTypeForScriptingDayView];
			break;
		case 1:
		//	appleScriptExecuteFunction(@"switch_view", @"switch_view", @"Week", nil, nil);
			[iCal switchViewTo:iCalCALViewTypeForScriptingWeekView];
			break;
		case 2:
		//	appleScriptExecuteFunction(@"switch_view", @"switch_view", @"Month", nil, nil);			
			[iCal switchViewTo:iCalCALViewTypeForScriptingMonthView];
			break;			
		default:
			break;
	}
	
}

void iCal_SHOW_DATE(PA_PluginParameters params){
	
	PackagePtr pParams = (PackagePtr)params->fParameters;
	
	C_DATE Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	NSString *yearValue = [[NSNumber numberWithShort:Param1.getYear()]stringValue];
	NSString *monthValue = [[NSNumber numberWithShort:Param1.getMonth()]stringValue];
	NSString *dayValue = [[NSNumber numberWithShort:Param1.getDay()]stringValue];	
	
	appleScriptExecuteFunction(@"show_date", @"show_date", yearValue, monthValue, dayValue);
}

void iCal_app_Get_task_property(sLONG_PTR *pResult, PackagePtr pParams){	

}

void iCal_app_Get_event_property(sLONG_PTR *pResult, PackagePtr pParams){
	
}

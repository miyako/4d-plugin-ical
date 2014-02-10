#include "ical_application.h"

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

void iCal_SHOW_EVENT(sLONG_PTR *pResult, PackagePtr pParams){

	C_TEXT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	NSString *eventId = Param1.copyUTF16String();
	
	appleScriptExecuteFunction(@"show_event", @"show_event", eventId, nil, nil);
	
	[eventId release];
	
}

void iCal_SHOW_TASK(sLONG_PTR *pResult, PackagePtr pParams){
	
	C_TEXT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	NSString *taskId = Param1.copyUTF16String();
	
	appleScriptExecuteFunction(@"show_task", @"show_task", taskId, nil, nil);
	
	[taskId release];		
}

void iCal_SET_VIEW(sLONG_PTR *pResult, PackagePtr pParams){
	
	C_LONGINT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	switch (Param1.getIntValue()){
		case 0:
			appleScriptExecuteFunction(@"switch_view", @"switch_view", @"Day", nil, nil);
			break;
		case 1:
			appleScriptExecuteFunction(@"switch_view", @"switch_view", @"Week", nil, nil);
			break;
		case 2:
			appleScriptExecuteFunction(@"switch_view", @"switch_view", @"Month", nil, nil);
			break;			
		default:
			break;
	}
	
}

void iCal_SHOW_DATE(sLONG_PTR *pResult, PackagePtr pParams){
	
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

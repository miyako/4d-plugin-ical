#include "ical_application.h"

// ---------------------------------- Application ---------------------------------

void iCal_TERMINATE(sLONG_PTR *pResult, PackagePtr pParams)
{	
	//requires 10.6 or later
	
	if(NSClassFromString(@"NSRunningApplication")){
		NSArray *array = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iCal"];
		if([array count]) 
			[(NSRunningApplication *)[array objectAtIndex:0] terminate];
	}
	
}

void iCal_LAUNCH(sLONG_PTR *pResult, PackagePtr pParams)
{	
	[[NSWorkspace sharedWorkspace]launchApplication:@"iCal"];		
}

// ---------------------------------- iCal Direct ---------------------------------

void iCal_SHOW_EVENT(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_SHOW_EVENT here...
	
	NSString *eventId = Param1.copyUTF16String();
	
	appleScriptExecuteFunction(@"show_event", @"show_event", eventId, nil, nil);
	
	[eventId release];
	
}

void iCal_SHOW_TASK(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_SHOW_TASK here...
	
	NSString *taskId = Param1.copyUTF16String();
	
	appleScriptExecuteFunction(@"show_task", @"show_task", taskId, nil, nil);
	
	[taskId release];	
	
}

void iCal_SET_VIEW(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_LONGINT Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_SET_VIEW here...
	
	switch (Param1.getIntValue()) {
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

void iCal_SHOW_DATE(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_DATE Param1;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_SHOW_DATE here...
	
	NSString *yearValue = [[NSNumber numberWithShort:Param1.getYear()]stringValue];
	NSString *monthValue = [[NSNumber numberWithShort:Param1.getMonth()]stringValue];
	NSString *dayValue = [[NSNumber numberWithShort:Param1.getDay()]stringValue];	
	
	appleScriptExecuteFunction(@"show_date", @"show_date", yearValue, monthValue, dayValue);
	
}

void iCal_app_Get_task_property(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	// --- write the code of iCal_app_Get_task_property here...
	
	int success = 0;
	
	NSString *returnString = nil;	
	NSString *taskId = Param1.copyUTF16String();
	NSString *taskPropertyKey = Param2.copyUTF16String();	
	
	NSArray *taskProperties = [NSArray arrayWithObjects:
							   @"completedDate", @"dueDate", 
							   @"priority", @"sequence", 
							   @"stampDate" ,@"title", 
							   @"notes", @"url", nil];
	
	NSUInteger pid = [taskProperties indexOfObject:taskPropertyKey];
	
	switch (pid){
			
		case 2://priority	
		case 3://sequence
		case 5://title
		case 6://notes	
		case 7://url				
			returnString = appleScriptExecuteFunction(@"get_task_property", @"get_task_property", taskId, taskPropertyKey, nil);
			if(returnString){
				success = 1;
				Param3.setUTF16String(returnString);
			}
			break;
			
		case 0://completedDate
		case 1://dueDate	
		case 4://stampDate
			returnString = appleScriptExecuteFunction(@"get_task_property", @"get_task_property", taskId, taskPropertyKey, nil);
			
			if(returnString){
				
				NSDate *currentDate = [[NSDate alloc]init];
				NSString *ds = [currentDate description];
				
				if([ds length] > 19){
					
					NSDate *d = [NSDate dateWithString:[returnString stringByAppendingString:[ds substringFromIndex:19]]];
					
					if(d){
						success = 1;					
						Param3.setUTF16String([d description]);
					}
					
					[currentDate release];
					
				}
				
			}
			break;			
			
		default:
			break;
			
	}		
	
	[taskId release];
	[taskPropertyKey release];
	
	if(success)
		Param3.toParamAtIndex(pParams, 3);
	
	returnValue.setIntValue(success);	
	returnValue.setReturn(pResult);
	
}

void iCal_app_Get_event_property(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	// --- write the code of iCal_app_Get_event_property here...
	
	int success = 0;
	
	NSString *returnString = nil;	
	NSString *eventId = Param1.copyUTF16String();
	NSString *eventPropertyKey = Param2.copyUTF16String();	
	
	NSArray *eventProperties = [NSArray arrayWithObjects:
								@"notes", @"startDate", 
								@"endDate", @"isAllDay", 
								@"recurrence" ,@"dateStamp", 
								@"sequence", @"status", 
								@"title", @"location", 
								@"url", @"calendar", nil];
	
	NSUInteger pid = [eventProperties indexOfObject:eventPropertyKey];
	
	switch (pid){
			
		case 0://notes	
		case 3://isAllDay	
		case 4://recurrence
		case 6://sequence
		case 7://status
		case 8://title
		case 9://location	
		case 10://url				
			returnString = appleScriptExecuteFunction(@"get_event_property", @"get_event_property", eventId, eventPropertyKey, nil);
			if(returnString){
				success = 1;
				Param3.setUTF16String(returnString);
			}
			break;	
			
		case 1://startDate
		case 2://endDate	
		case 5://dateStamp				
			returnString = appleScriptExecuteFunction(@"get_event_property", @"get_event_property", eventId, eventPropertyKey, nil);
			
			if(returnString){
				
				NSDate *currentDate = [[NSDate alloc]init];
				NSString *ds = [currentDate description];
				
				if([ds length] > 19){
					
					NSDate *d = [NSDate dateWithString:[returnString stringByAppendingString:[ds substringFromIndex:19]]];
					
					if(d){
						success = 1;					
						Param3.setUTF16String([d description]);
					}
					
					[currentDate release];
					
				}
				
			}
			break;			
		case 11://calendar	
			returnString = appleScriptExecuteFunction(@"get_event_property", @"get_event_property", eventId, eventPropertyKey, nil);
			if(returnString){
				success = 1;
				Param3.setUTF16String(returnString);
			}			
			break;
		default:
			break;
			
	}		
	
	[eventId release];
	[eventPropertyKey release];
	
	if(success)
		Param3.toParamAtIndex(pParams, 3);
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
	
}

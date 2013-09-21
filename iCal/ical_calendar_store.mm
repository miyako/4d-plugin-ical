#include "ical_calendar_store.h"

// -------------------------------- Calendar Store --------------------------------

void iCal_QUERY_EVENT(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_TEXT Param2;
	ARRAY_TEXT Param3;
	ARRAY_TEXT Param4;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	// --- write the code of iCal_QUERY_EVENT here...
	
	NSString *startDateString = Param1.copyUTF16String();
	NSString *endDateString = Param2.copyUTF16String();
	
	NSMutableArray *calendars = [[NSMutableArray alloc]init];
	
	unsigned int i;	
	CalCalendar *calendar;
	NSDate *startDate = [NSDate dateWithString:startDateString];
	NSDate *endDate = [NSDate dateWithString:endDateString];	
	
	if((startDate) && (endDate))
	{
		for(i = 0; i < Param3.getSize(); i++)
		{
			CUTF16String calendarId;
			Param3.copyUTF16StringAtIndex(&calendarId, i);
			NSString *c = [[NSString alloc]initWithCharacters:(const unichar *)calendarId.c_str() length:calendarId.length()];
			calendar = [[CalCalendarStore defaultCalendarStore]calendarWithUID:c];
			if(calendar) [calendars addObject:calendar];
			[c release];
		}
		
		NSPredicate *predicate = [CalCalendarStore eventPredicateWithStartDate:startDate endDate:endDate calendars:calendars];
		
		Param4.appendUTF16String(@"");
		
		if(predicate)
		{
			NSArray *events = [[CalCalendarStore defaultCalendarStore]eventsWithPredicate:predicate];
			
			for(i = 0; i < [events count]; i++)
			{
				Param4.appendUTF16String([[events objectAtIndex:i]uid]);
			}
		}					
	}
	
	[calendars release];	
	[startDateString release];
	[endDateString release];		
	
	Param4.toParamAtIndex(pParams, 4);
}

void iCal_GET_CALENDAR_LIST(sLONG_PTR *pResult, PackagePtr pParams)
{
	ARRAY_TEXT Param1;
	ARRAY_TEXT Param2;
	
	// --- write the code of iCal_GET_CALENDAR_LIST here...
	
	NSArray *calendars = [[CalCalendarStore defaultCalendarStore]calendars];
	
	unsigned int i;
	
	Param1.appendUTF16String(@"");
	Param2.appendUTF16String(@"");		
	
	for(i = 0; i < [calendars count]; i++)
	{
		Param1.appendUTF16String([[calendars objectAtIndex:i]uid]);
		Param2.appendUTF16String([[calendars objectAtIndex:i]title]);		
	}
	
	Param1.toParamAtIndex(pParams, 1);
	Param2.toParamAtIndex(pParams, 2);
}

void iCal_QUERY_TASK(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	ARRAY_TEXT Param2;
	ARRAY_TEXT Param3;
	C_LONGINT Param4;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param4.fromParamAtIndex(pParams, 4);
	
	// --- write the code of iCal_QUERY_TASK here...
	
	NSString *dueDateString = Param1.copyUTF16String();
	NSDate *dueDate = [NSDate dateWithString:dueDateString];
	
	NSMutableArray *calendars = [[NSMutableArray alloc]init];
	
	unsigned int i;		
	CalCalendar *calendar;
	
	for(i = 0; i < Param2.getSize(); i++){
		CUTF16String theCalendar;
		Param2.copyUTF16StringAtIndex(&theCalendar, i);
		NSString *calendarId = [[NSString alloc]initWithCharacters:(const unichar *)theCalendar.c_str() length:theCalendar.length()];
		calendar = [[CalCalendarStore defaultCalendarStore]calendarWithUID:calendarId];
		[calendarId release];
		
		if(calendar) [calendars addObject:calendar];
	}		
	
	NSPredicate *predicate;
	
	switch (Param4.getIntValue()) {
		case 1:
			if(dueDate){	
				predicate = [CalCalendarStore taskPredicateWithTasksCompletedSince:dueDate calendars:calendars];
			}else{
				predicate = [CalCalendarStore taskPredicateWithTasksCompletedSince:[NSDate distantPast] calendars:calendars];
			} 
			break;
		default:
			if(dueDate){					
				predicate = [CalCalendarStore taskPredicateWithUncompletedTasksDueBefore:dueDate calendars:calendars]; 		
			}else{
				predicate = [CalCalendarStore taskPredicateWithUncompletedTasks:calendars]; 					
			}
			break;
	}		
	
	Param3.appendUTF16String(@"");
	
	if(predicate){
		NSArray *tasks = [[CalCalendarStore defaultCalendarStore]tasksWithPredicate:predicate];
		
		for(i = 0; i < [tasks count]; i++){
			Param3.appendUTF16String([[tasks objectAtIndex:i]uid]);
		}
	}	
	
	[calendars release];
	[dueDateString release];	
	
	Param3.toParamAtIndex(pParams, 3);
}
#import "ical_calendar_store.h"
#import "helper.h"

// -------------------------------- Calendar Store --------------------------------

void iCal_QUERY_EVENT(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	ARRAY_TEXT Param3;
	ARRAY_TEXT Param4;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	C_LONGINT _returnValue;
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(_returnValue);
	
	if(defaultCalendarStore){
	
		NSString *startDateString = Param1.copyUTF16String();
		NSString *endDateString = Param2.copyUTF16String();
		NSDate *startDate = [NSDate dateWithString:startDateString];
		NSDate *endDate = [NSDate dateWithString:endDateString];	
		NSArray *calendars = _getCalendars(defaultCalendarStore, Param3);
		[startDateString release];
		[endDateString release];	
		
		NSPredicate *predicate;
		
		if((startDate) && (endDate)){
			
			predicate = [CalCalendarStore eventPredicateWithStartDate:startDate endDate:endDate calendars:calendars];
			
			Param4.appendUTF16String(@"");
			
			if(predicate){
				NSArray *events = [[CalCalendarStore defaultCalendarStore]eventsWithPredicate:predicate];
				for(unsigned int i = 0; i < [events count]; ++i){
					Param4.appendUTF16String([[events objectAtIndex:i]uid]);
				}
			}					
		}		
	}
	Param4.toParamAtIndex(pParams, 4);
}

void iCal_GET_CALENDAR_LIST(sLONG_PTR *pResult, PackagePtr pParams){
	ARRAY_TEXT Param1;
	ARRAY_TEXT Param2;
	
	C_LONGINT _returnValue;
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(_returnValue);
	
	if(defaultCalendarStore){
		NSArray *calendars = [defaultCalendarStore calendars];
		Param1.appendUTF16String(@"");
		Param2.appendUTF16String(@"");			
		for(unsigned int i = 0; i < [calendars count]; ++i){
			Param1.appendUTF16String([[calendars objectAtIndex:i]uid]);
			Param2.appendUTF16String([[calendars objectAtIndex:i]title]);		
		}
	}	
	
	Param1.toParamAtIndex(pParams, 1);
	Param2.toParamAtIndex(pParams, 2);
}

void iCal_QUERY_TASK(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	ARRAY_TEXT Param2;
	ARRAY_TEXT Param3;
	C_LONGINT Param4;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param4.fromParamAtIndex(pParams, 4);
		
	C_LONGINT _returnValue;
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(_returnValue);
	
	if(defaultCalendarStore){
		
		NSString *dueDateString = Param1.copyUTF16String();
		NSDate *dueDate = [NSDate dateWithString:dueDateString];
		[dueDateString release];
		
		NSArray *calendars = _getCalendars(defaultCalendarStore, Param2);
		
		NSPredicate *predicate;
		
		switch (Param4.getIntValue()){
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
			NSArray *tasks = [defaultCalendarStore tasksWithPredicate:predicate];
			for(unsigned int i = 0; i < [tasks count]; ++i){
				Param3.appendUTF16String([[tasks objectAtIndex:i]uid]);
			}
		}	
	}
	Param3.toParamAtIndex(pParams, 3);
}
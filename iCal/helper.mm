#import "helper.h"

NSDate *_getDate(NSString *recordTime, C_LONGINT &returnValue)
{
	NSDate *date = nil;
	
	date = [NSDate dateWithString:recordTime];
	
	if(!date)
	{
		returnValue.setIntValue(ERROR_INVALID_DATE);
	}
	
	return date; 
}

CalCalendarStore *_getCalendarStore(C_LONGINT &returnValue)
{
	CalCalendarStore *calendarStore = nil;
	
	calendarStore = [CalCalendarStore defaultCalendarStore];
	
	if(!calendarStore)
	{
		returnValue.setIntValue(ERROR_ACCESS_DENIED);
	}
	
	return calendarStore;
}

#pragma mark -

CalCalendar *_getCalendar(CalCalendarStore *calendarStore, NSString *calendarName, C_LONGINT &returnValue){
	NSArray * calendars = _getCalendars(calendarStore, [NSArray arrayWithObject:calendarName], returnValue);
	
	if([calendars count]){
		return [calendars objectAtIndex:0];
	}else{
		return nil;
	}
}

NSArray * _getCalendars(CalCalendarStore *calendarStore, ARRAY_TEXT &calendarNames){
	NSArray *calendars;
	NSMutableArray *calendarIds = [[NSMutableArray alloc]init];
	for(unsigned int i = 0; i < calendarNames.getSize(); ++i){
		CUTF16String calendar;
		calendarNames.copyUTF16StringAtIndex(&calendar, i);
		NSString *calendarId = [[NSString alloc]initWithCharacters:(const unichar *)calendar.c_str() length:calendar.length()];
		[calendarIds addObject:calendarId];
		[calendarId release];
	}
	C_LONGINT _returnValue;
	calendars = _getCalendars(calendarStore, calendarIds, _returnValue);
	[calendarIds release];
	return calendars;
}

NSArray * _getCalendars(CalCalendarStore *calendarStore, NSArray *calendarNames, C_LONGINT &returnValue){	
	NSArray *calendars = [calendarStore calendars];
	NSMutableArray *foundCalendars = [NSMutableArray array];
	CalCalendar *calendar;
    unsigned int i, j;
	for(i = 0; i < [calendarNames count]; ++i){
		calendar = [calendarStore calendarWithUID:[calendarNames objectAtIndex:i]];
		if(calendar){
			[foundCalendars addObject:calendar];
		}else{
            for(j = 0; j < [calendars count]; ++j){
                calendar = [calendars objectAtIndex:j];
                if([calendarNames containsObject:[calendar title]]){
                    [foundCalendars addObject:calendar];
                }
            }        
        }
    }

	if(![foundCalendars count]){
		returnValue.setIntValue(ERROR_CALENDAR_NOT_FOUND);
	}
	
	return foundCalendars;
}

#pragma mark -

int _newProcess(void* procPtr, int stackSize, NSString *name )
{
	C_TEXT t;
	t.setUTF16String(name);
	
	return PA_NewProcess(procPtr, stackSize, (PA_Unichar *)t.getUTF16StringPtr());	
}

PA_Unistring _setUnistringVariable(PA_Variable *v, NSString *s)
{
	C_TEXT t;
	t.setUTF16String(s);	
	PA_Unistring u = PA_CreateUnistring((PA_Unichar *)t.getUTF16StringPtr());
	PA_SetStringVariable(v, &u);
	return u;
}
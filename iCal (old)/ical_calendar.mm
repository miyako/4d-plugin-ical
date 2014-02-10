#include "ical_calendar.h"

// ----------------------------------- Calendar -----------------------------------

void iCal_Create_calendar(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	// --- write the code of iCal_Create_calendar here...
	
	NSError *error = nil;	
	
	NSString *title = Param1.copyUTF16String();
	NSString *dictionary = Param2.copyUTF16String();
	NSColor *color;
	
	CalCalendar *calendar = [CalCalendar calendar];
	
	calendar.title = title;
	
	color = getColorFromString(dictionary);
	if(color)	calendar.color = color;	
	
	[[CalCalendarStore defaultCalendarStore]saveCalendar:calendar error:&error];
	
	if(error)	
	{
		NSLog(@"can't save calendar: %@", [error localizedDescription]);
	}else{
		returnValue.setUTF16String([calendar uid]);
	}
	
	[title release];	
	[dictionary release];	
	
	returnValue.setReturn(pResult);	
	
}

void iCal_Set_calendar_property(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	// --- write the code of iCal_Set_calendar_property here...
	
	int success = 0;
	NSError *error = nil;
	
	NSString * uid = Param1.copyUTF16String();
	NSString * key = Param2.copyUTF16String();
	NSString * value = Param3.copyUTF16String();
	
	CalCalendar *calendar = [[CalCalendarStore defaultCalendarStore]calendarWithUID:uid];
	NSColor *color;
	
	NSArray *calendarProperties = [NSArray arrayWithObjects:
								   @"color", @"isEditable", 
								   @"notes", @"title", 
								   @"type", nil];
	
	if(calendar)
	{
		NSUInteger pid = [calendarProperties indexOfObject:key];
		
		switch (pid)
		{
			case 0://color
				
				color = getColorFromString(value);
				
				if(color){
					calendar.color = color;
					success = [[CalCalendarStore defaultCalendarStore]saveCalendar:calendar error:&error];
				}		
				break;
			case 1://isEditable (readonly)
				break;
			case 2://notes
				calendar.notes = value;			
				success = [[CalCalendarStore defaultCalendarStore]saveCalendar:calendar error:&error];	
				break;
			case 3://title 
				calendar.title = value;		
				success = [[CalCalendarStore defaultCalendarStore]saveCalendar:calendar error:&error];
				break;
			case 4://type (readonly)
				break;																
			default:
				break;
		}
	}
	
	if(error){
		success = [error code];
		NSLog(@"can't update calendar: %@", [error localizedDescription]);
	}
	
	[uid release];
	[key release];
	[value release];
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Get_calendar_property(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	// --- write the code of iCal_Get_calendar_property here...
	
	int success = 0;
	
	NSString * uid = Param1.copyUTF16String();
	NSString * key = Param2.copyUTF16String();
	
	CalCalendar *calendar = [[CalCalendarStore defaultCalendarStore]calendarWithUID:uid];
	
	NSArray *calendarProperties = [NSArray arrayWithObjects:
								   @"color", @"isEditable", @"notes", @"title", @"type", nil];
	
	if(calendar)
	{
		NSUInteger pid = [calendarProperties indexOfObject:key];
		NSString *colorString;
		
		switch (pid)
		{
			case 0://color
				colorString = copyColorString(calendar.color);
				Param3.setUTF16String(colorString);	
				[colorString release];					
				success = 1;		
				break;
			case 1://isEditable
				if(calendar.isEditable)
				{
					Param3.setUTF16String(@"YES");	
				}else{
					Param3.setUTF16String(@"NO");		
				}
				success = 1;								
				break;
			case 2://notes
				Param3.setUTF16String(calendar.notes);					
				success = 1;					
				break;
			case 3://title
				Param3.setUTF16String(calendar.title);				
				success = 1;					
				break;
			case 4://type
				Param3.setUTF16String(calendar.type);
				success = 1;				
				break;																
			default:
				break;
		}
	}
	
	[uid release];
	[key release];	
	
	if(success)
		Param3.toParamAtIndex(pParams, 3);
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Remove_calendar(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_Remove_calendar here...
	
	int success = 0;
	NSError *error = nil;
	
	NSString * calendarId = Param1.copyUTF16String();
	CalCalendar *calendar = [[CalCalendarStore defaultCalendarStore]calendarWithUID:calendarId];
	
	if(calendar) success = [[CalCalendarStore defaultCalendarStore]removeCalendar:calendar error:&error];
	
	if(error)	
	{
		success = [error code];
		NSLog(@"can't remove calendar: %@", [error localizedDescription]);
	}
	
	[calendarId release];	
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

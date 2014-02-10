#import "ical_calendar.h"
#import "helper.h"

// ----------------------------------- Calendar -----------------------------------

void iCal_Create_calendar(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	NSError *error = nil;	
	
	NSString *title = Param1.copyUTF16String();
	NSString *dictionary = Param2.copyUTF16String();
	NSColor *color;
	
	CalCalendar *calendar = [CalCalendar calendar];
	
	calendar.title = title;
	
	color = getColorFromString(dictionary);
	if(color)	calendar.color = color;	
	
	[[CalCalendarStore defaultCalendarStore]saveCalendar:calendar error:&error];
	
	if(error){
		NSLog(@"can't save calendar: %@", [error localizedDescription]);
	}else{
		returnValue.setUTF16String([calendar uid]);
	}
	
	[title release];	
	[dictionary release];	
	
	returnValue.setReturn(pResult);	
}

void iCal_Set_calendar_property(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	int success = 0;
	
	NSError *error = nil;
	CalCalendar *calendar;
	
	NSString * calendarId = Param1.copyUTF16String();
	NSString * key = Param2.copyUTF16String();
	NSString * value = Param3.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if (defaultCalendarStore){
		calendar = _getCalendar(defaultCalendarStore, calendarId, returnValue);		
		if(calendar){
			NSColor *color;
			
			NSArray *calendarProperties = [NSArray arrayWithObjects:
										   @"color", @"isEditable", 
										   @"notes", @"title", 
										   @"type", nil];			
			NSUInteger pid = [calendarProperties indexOfObject:key];
			switch (pid){
				case 0://color
					color = getColorFromString(value);
					if(color){
						calendar.color = color;
						success = [defaultCalendarStore saveCalendar:calendar error:&error];
					}		
					break;
				case 1://isEditable (readonly)
					break;
				case 2://notes
					calendar.notes = value;			
					success = [defaultCalendarStore saveCalendar:calendar error:&error];	
					break;
				case 3://title 
					calendar.title = value;		
					success = [defaultCalendarStore saveCalendar:calendar error:&error];
					break;
				case 4://type (readonly)
					break;																
				default:
					break;
			}
			if(error){
				success = [error code];
				NSLog(@"can't update calendar: %@", [error localizedDescription]);
			}
		}
	}
	
	[calendarId release];
	[key release];
	[value release];
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Remove_calendar(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	int success = 0;
	
	NSError *error = nil;
	CalCalendar *calendar;
	
	NSString * calendarId = Param1.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		calendar = _getCalendar(defaultCalendarStore, calendarId, returnValue);	
		if(calendar){
			success = [defaultCalendarStore removeCalendar:calendar error:&error];
			if(error){
				success = [error code];
				NSLog(@"can't remove calendar: %@", [error localizedDescription]);
			}
		}
	}

	[calendarId release];	
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

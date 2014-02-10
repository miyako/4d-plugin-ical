#include "ical_timezome.h"

// ----------------------------------- Timezone -----------------------------------

void iCal_TIMEZONE_LIST(sLONG_PTR *pResult, PackagePtr pParams)
{
	ARRAY_TEXT Param1;
	
	NSArray *knownTimeZoneNames = [NSTimeZone knownTimeZoneNames];
		
	Param1.appendUTF16String(@"");	
	
	for(unsigned int i = 0; i < [knownTimeZoneNames count]; i++)
	{
		Param1.appendUTF16String([knownTimeZoneNames objectAtIndex:i]);	
	}
	
	Param1.toParamAtIndex(pParams, 1);
}

void iCal_Get_timezone_info(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_DATE Param1;
	C_TIME Param2;
	C_TEXT Param3;
	C_LONGINT Param4;
	C_LONGINT Param5;
	C_DATE Param6;
	C_TIME Param7;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
		
	NSString *name = Param3.copyUTF16String();
	NSTimeZone *zone = [NSTimeZone timeZoneWithName:name];
	if(!zone) 
		zone = [NSTimeZone localTimeZone];
	[name release];
	
	CFGregorianDate gregDate;
	
	gregDate.year = Param1.getYear();
	gregDate.month = Param1.getMonth();
	gregDate.day = Param1.getDay();
	gregDate.hour = 0;
	gregDate.minute = 0;
	gregDate.second = 0;
	
	CFGregorianUnits offset;
	
	offset.years = 0;
	offset.months = 0;
	offset.days = 0;	
	offset.minutes = 0;
	offset.hours = 0;
	offset.seconds = Param2.getSeconds();
	
	NSTimeInterval daylightSavingTimeOffsetForDate;
	NSInteger secondsFromGMTForDate;
	NSDate *nextDaylightSavingTimeTransitionAfterDate;
	
	if(CFGregorianDateIsValid(gregDate, 
							  kCFGregorianUnitsYears+kCFGregorianUnitsMonths+kCFGregorianUnitsDays)){
		
		CFAbsoluteTime at = CFGregorianDateGetAbsoluteTime(gregDate, (CFTimeZoneRef)zone);
		CFAbsoluteTime seconds = CFAbsoluteTimeAddGregorianUnits(at, (CFTimeZoneRef)zone, offset);		
		
		NSDate *nsd = (NSDate *)CFDateCreate(kCFAllocatorDefault, seconds);
		
		daylightSavingTimeOffsetForDate = [zone daylightSavingTimeOffsetForDate:nsd];
		secondsFromGMTForDate = [zone secondsFromGMTForDate:nsd];
		nextDaylightSavingTimeTransitionAfterDate = [zone nextDaylightSavingTimeTransitionAfterDate:nsd];

		[nsd release];
		
		Param4.setIntValue(secondsFromGMTForDate);
		Param5.setIntValue(daylightSavingTimeOffsetForDate);
		
		NSString *description = [nextDaylightSavingTimeTransitionAfterDate description];
		
		if([description length] == 25){
			
			int year = [[description substringWithRange:NSMakeRange(0,4)]integerValue];
			int month = [[description substringWithRange:NSMakeRange(5,2)]integerValue];
			int day = [[description substringWithRange:NSMakeRange(8,2)]integerValue];	
			
			int hour = [[description substringWithRange:NSMakeRange(11,2)]integerValue]; 		
			int minute = [[description substringWithRange:NSMakeRange(14,2)]integerValue]; 
			int second = [[description substringWithRange:NSMakeRange(17,2)]integerValue]; 	
			
			int offset = [zone secondsFromGMTForDate:nextDaylightSavingTimeTransitionAfterDate];
			
			Param6.setYearMonthDay(year, month, day);
			Param7.setSeconds(second + (minute * 60) + (hour * 3600) - offset);
			returnValue.setIntValue(1);
			
		}
		
	}
	
	Param4.toParamAtIndex(pParams, 4);
	Param5.toParamAtIndex(pParams, 5);
	Param6.toParamAtIndex(pParams, 6);
	Param7.toParamAtIndex(pParams, 7);
	returnValue.setReturn(pResult);
}

void iCal_Get_timezone_for_offset(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_LONGINT Param1;
	C_TEXT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	returnValue.setUTF16String([[NSTimeZone timeZoneForSecondsFromGMT:Param1.getIntValue()]name]);
	
	returnValue.setReturn(pResult);
}

void iCal_Get_system_timezone(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT returnValue;
	
	returnValue.setUTF16String([[NSTimeZone systemTimeZone]name]);
	
	returnValue.setReturn(pResult);
}
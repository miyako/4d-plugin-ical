#include "ical_tools.h"

// ----------------------------------- Type Cast ----------------------------------

void iCal_Make_date(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_DATE Param1;
	C_TIME Param2;
	C_TEXT Param3;
	C_TEXT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	// --- write the code of iCal_Make_date here...
	
	PA_Date date;
	date.fYear = Param1.getYear();
	date.fMonth = Param1.getMonth();
	date.fDay = Param1.getDay();	
	
	int seconds = Param2.getSeconds();
	NSString *name = Param3.copyUTF16String();
	
	NSString *description = copyDateTimeZoneString(&date, seconds, name);
	
	returnValue.setUTF16String(description);
	returnValue.setReturn(pResult);
	
	[description release];
	[name release];
	
}

void iCal_GET_DATE(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_DATE Param2;
	C_TIME Param3;
	C_LONGINT Param4;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_GET_DATE here...
	
	NSString *dateString = Param1.copyUTF16String();
	
	PA_Date date;
	int time = 0;
	int offset = 0;
	
	getDateTimeOffsetFromString(dateString, &date, &time, &offset);
	
	Param2.setYearMonthDay(date.fYear, date.fMonth, date.fDay);
	Param3.setSeconds(time);
	Param4.setIntValue(offset);
	
	[dateString release];	
	
	Param2.toParamAtIndex(pParams, 2);
	Param3.toParamAtIndex(pParams, 3);
	Param4.toParamAtIndex(pParams, 4);
	
}

void iCal_Make_color(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_REAL Param1;
	C_REAL Param2;
	C_REAL Param3;
	C_REAL Param4;
	C_TEXT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	Param4.fromParamAtIndex(pParams, 4);
	
	// --- write the code of iCal_Make_color here...
	
	float red = Param1.getDoubleValue();
	float green = Param2.getDoubleValue();
	float blue = Param3.getDoubleValue();
	float alpha = Param4.getDoubleValue();
	
	NSColor *color = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
	NSString *colorString = copyColorString(color);
	
	returnValue.setUTF16String(colorString);	
	returnValue.setReturn(pResult);
	
	[colorString release];
	
}

void iCal_GET_COLOR(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_TEXT Param1;
	C_REAL Param2;
	C_REAL Param3;
	C_REAL Param4;
	C_REAL Param5;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_GET_COLOR here...
	
	NSString *colorString = Param1.copyUTF16String();
	NSColor *color = getColorFromString(colorString);
	
	Param2.setDoubleValue((double)[color redComponent]);
	Param3.setDoubleValue((double)[color greenComponent]);
	Param4.setDoubleValue((double)[color blueComponent]);
	Param5.setDoubleValue((double)[color alphaComponent]);
	
	Param2.toParamAtIndex(pParams, 2);
	Param3.toParamAtIndex(pParams, 3);
	Param4.toParamAtIndex(pParams, 4);
	Param5.toParamAtIndex(pParams, 5);
	
	[colorString release];
	
}

void iCal_Make_color_from_index(sLONG_PTR *pResult, PackagePtr pParams)
{
	C_LONGINT Param1;
	C_TEXT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	// --- write the code of iCal_Make_color_from_index here...
	
	NSColor *color = getColorIndex(Param1.getIntValue());
	NSString *colorString = copyColorString(color);
	
	returnValue.setUTF16String(colorString);	
	returnValue.setReturn(pResult);
	
	[colorString release];	
}

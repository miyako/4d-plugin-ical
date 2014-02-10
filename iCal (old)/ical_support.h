#include "4DPluginAPI.h"
#include <Cocoa/Cocoa.h>
#include <CalendarStore/CalendarStore.h>
#define THIS_BUNDLE_ID @"com.4D.4DPlugin.miyako.iCal"

NSString * appleScriptExecuteFunction(NSString *fileName, NSString *functionName, NSString *argument1, NSString *argument2, NSString *argument3);
CalAlarm *getAlarmFromString(NSString *dictionary);
NSString *copyAlarmString(CalAlarm *alarm);
NSColor *getColorIndex(int index);
NSColor *getColorFromString(NSString *dictionary);
NSString *copyColorString(NSColor *color);
NSString *copyAttendeesDictionary(NSArray *attendees);
NSString *copyDateTimeZoneString(PA_Date *date, int time, NSString *name);
void getDateTimeOffsetFromString(NSString *dateString, PA_Date *date, int *time, int *offset);

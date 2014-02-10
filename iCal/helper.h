#import "4DPluginAPI.h"
#import <CalendarStore/CalendarStore.h>

#define ERROR_ACCESS_DENIED 1
#define ERROR_CALENDAR_NOT_FOUND 2
#define ERROR_INVALID_DATE 3

void _getRecordByLocation();
void _getRecordById();

void _getRecord(BOOL useRecordId = false);

NSDate *_getDate(NSString *recordTime, C_LONGINT &returnValue);
CalCalendarStore *_getCalendarStore(C_LONGINT &returnValue);

CalCalendar *_getCalendar(CalCalendarStore *calendarStore, NSString *calendarName, C_LONGINT &returnValue);
NSArray *_getCalendars(CalCalendarStore *calendarStore, NSArray *calendarNames, C_LONGINT &returnValue);
NSArray * _getCalendars(CalCalendarStore *calendarStore, ARRAY_TEXT &calendarIds);
	
NSArray *_getEvents(NSString *location, NSArray *calendarNames, NSString *recordTime, C_LONGINT &returnValue, BOOL isPrefixMatch = false);
CalEvent *_getEvent(NSString *location, NSString *calendarName, NSString *recordTime, C_LONGINT &returnValue, BOOL isPrefixMatch = false);

typedef struct RecordSpecifier
{
	NSString *uid;
	NSString *key;
	C_TEXT value;	
	NSString *date;
	NSUInteger index;
	NSUInteger count;	
	BOOL	isOK;	
	BOOL	isLocked;
	BOOL	isDone;
};

typedef struct RecordSpecifiers
{
	C_TEXT			location;
	C_TEXT			startDate;
	
	ARRAY_TEXT		titles;
	ARRAY_TEXT		notes;
	ARRAY_TEXT		calendarTitles;
	ARRAY_TEXT		uids;
	
	ARRAY_TEXT		locations;
	ARRAY_TEXT		startDates;
	
	ARRAY_LONGINT	durations;
	
	int				resultCode;
	BOOL			isLocked;
	BOOL			isDone;
};

int _newProcess(void* procPtr, int stackSize, NSString *name);
PA_Unistring _setUnistringVariable(PA_Variable *v, NSString *s);

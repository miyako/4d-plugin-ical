/* --------------------------------------------------------------------------------
 #
 #	4DPlugin.h
 #	source generated by 4D Plugin Wizard
 #	Project : iCal
 #	author : miyako
 #	2016/10/03
 #
 # --------------------------------------------------------------------------------*/

#import <CalendarStore/CalendarStore.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "iCal.h"
#include "sqlite3.h"

#include <mutex>

#define ERROR_ACCESS_DENIED 1
#define ERROR_CALENDAR_NOT_FOUND 2
#define ERROR_INVALID_DATE 3

#define DATE_FORMAT_ISO_GMT @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#define DATE_FORMAT_ISO @"yyyy-MM-dd'T'HH:mm:ss"

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

void listenerInit(void);
void listenerLoop(void);
void listenerLoopStart(void);
void listenerLoopFinish(void);
void listenerLoopExecute(void);
void listenerLoopExecuteMethod(void);

@interface Listener : NSObject
{
    FSEventStreamRef stream;
}

- (void)setPaths;

@end

void listener_start(void);
void listener_end(void);

typedef PA_long32 process_number_t;
typedef PA_long32 process_stack_size_t;
typedef PA_long32 method_id_t;
typedef PA_Unichar* process_name_t;

void onStartup();
void onCloseProcess();
bool isProcessOnExit();

void get_calendar_paths(ARRAY_TEXT &paths);

typedef enum
{
	
	notification_create = 0,
	notification_update = 1,
	notification_delete = 2
	
} notification_t;

// --- Event
void iCal_Create_event(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_event_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_event_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_event(sLONG_PTR *pResult, PackagePtr pParams);

// --- Task
void iCal_Create_task(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_task_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_task_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_task(sLONG_PTR *pResult, PackagePtr pParams);

// --- Calendar
void iCal_Create_calendar(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_calendar_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_calendar_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_calendar(sLONG_PTR *pResult, PackagePtr pParams);

// --- Calendar Store
void iCal_QUERY_EVENT(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_GET_CALENDAR_LIST(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_QUERY_TASK(sLONG_PTR *pResult, PackagePtr pParams);

// --- Type Cast
void iCal_Make_date(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_GET_DATE(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Make_color(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_GET_COLOR(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Make_color_from_index(sLONG_PTR *pResult, PackagePtr pParams);

// --- Recurrence Rule
void iCal_Remove_event_recurrence(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_event_recurrence(sLONG_PTR *pResult, PackagePtr pParams);

// --- Alarm
void iCal_Make_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_alarm_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_alarm_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Add_alarm_to_event(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Add_alarm_to_task(sLONG_PTR *pResult, PackagePtr pParams);

// --- Application
void iCal_TERMINATE(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_LAUNCH(sLONG_PTR *pResult, PackagePtr pParams);

// --- iCal Direct
void iCal_SHOW_EVENT(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_SHOW_TASK(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_SET_VIEW(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_SHOW_DATE(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_app_Get_task_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_app_Get_event_property(sLONG_PTR *pResult, PackagePtr pParams);

// --- Notification
void iCal_Set_notification_method(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_notification_method(sLONG_PTR *pResult, PackagePtr pParams);

// --- Alarm II
void iCal_Get_event_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Count_event_alarms(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_event_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_event_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Count_task_alarms(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_task_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_task_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_task_alarm(sLONG_PTR *pResult, PackagePtr pParams);

// --- Timezone
void iCal_TIMEZONE_LIST(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_timezone_info(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_timezone_for_offset(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_system_timezone(sLONG_PTR *pResult, PackagePtr pParams);

// --- Event II
void iCal_Set_event_properties(sLONG_PTR *pResult, PackagePtr pParams);

// --- v2
void iCal_Get_calendars(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_timezones(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Add_event(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Modify_event(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Find_event(sLONG_PTR *pResult, PackagePtr pParams);

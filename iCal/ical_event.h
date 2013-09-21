#include "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>
#import "ical_support.h"

// --- Event
void iCal_Create_event(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_event_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_event_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_event(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_event_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Count_event_alarms(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_event_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_event_alarm(sLONG_PTR *pResult, PackagePtr pParams);

// --- Recurrence Rule
void iCal_Remove_event_recurrence(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_event_recurrence(sLONG_PTR *pResult, PackagePtr pParams);
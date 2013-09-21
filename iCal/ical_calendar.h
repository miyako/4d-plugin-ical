#include "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>
#import "ical_support.h"

// --- Calendar
void iCal_Create_calendar(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_calendar_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_calendar_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_calendar(sLONG_PTR *pResult, PackagePtr pParams);
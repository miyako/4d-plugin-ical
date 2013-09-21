#include "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>

// --- Calendar Store
void iCal_QUERY_EVENT(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_GET_CALENDAR_LIST(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_QUERY_TASK(sLONG_PTR *pResult, PackagePtr pParams);
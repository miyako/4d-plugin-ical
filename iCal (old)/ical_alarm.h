#include "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>

// --- Alarm
void iCal_Make_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_alarm_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_alarm_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Add_alarm_to_event(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Add_alarm_to_task(sLONG_PTR *pResult, PackagePtr pParams);


#import "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>
#import "ical_support.h"

// --- Task
void iCal_Create_task(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_task_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_task_property(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_task(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Count_task_alarms(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_task_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Remove_task_alarm(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Set_task_alarm(sLONG_PTR *pResult, PackagePtr pParams);
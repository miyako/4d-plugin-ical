#include "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>
#import "ical_support.h"

// --- Application
void iCal_TERMINATE(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_LAUNCH(sLONG_PTR *pResult, PackagePtr pParams);

// --- iCal Direct
void iCal_SHOW_EVENT(PA_PluginParameters params);
void iCal_SHOW_TASK(PA_PluginParameters params);
void iCal_SET_VIEW(PA_PluginParameters params);
void iCal_SHOW_DATE(PA_PluginParameters params);
void iCal_app_Get_task_property(PA_PluginParameters params);
void iCal_app_Get_event_property(PA_PluginParameters params);

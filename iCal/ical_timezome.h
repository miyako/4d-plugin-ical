#include "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>

// --- Timezone
void iCal_TIMEZONE_LIST(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_timezone_info(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_timezone_for_offset(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Get_system_timezone(sLONG_PTR *pResult, PackagePtr pParams);

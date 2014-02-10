#include "4DPluginAPI.h"

#import <CalendarStore/CalendarStore.h>
#import "ical_support.h"

// --- Type Cast
void iCal_Make_date(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_GET_DATE(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Make_color(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_GET_COLOR(sLONG_PTR *pResult, PackagePtr pParams);
void iCal_Make_color_from_index(sLONG_PTR *pResult, PackagePtr pParams);
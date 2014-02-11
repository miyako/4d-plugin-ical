#import "ical_task.h"
#import "helper.h"

// ------------------------------------- Task -------------------------------------

void iCal_Create_task(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
		
	NSError *error = nil;
	
	CalCalendar *calendar;
	
	NSString *calendarId = Param1.copyUTF16String();
	NSString *dueDateString = Param2.copyUTF16String();
	
	C_LONGINT _returnValue;
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(_returnValue);
	
	if(defaultCalendarStore){
		calendar = _getCalendar(defaultCalendarStore, calendarId, _returnValue);
		if(calendar){	
			CalTask *task = [CalTask task];
			task.calendar = calendar;
			
			NSDate *dueDate = [NSDate dateWithString:dueDateString]; 
			
			if(dueDate) task.dueDate = dueDate;	
			
			[defaultCalendarStore saveTask:task error:&error];
			
			if(error){
				NSLog(@"can't save task: %@", [error localizedDescription]);
			}else{
				returnValue.setUTF16String([task uid]);
			}					
		}
	}

	[calendarId release];
	[dueDateString release];
	
	returnValue.setReturn(pResult);
}

void iCal_Set_task_property(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
		
	int success = 0;
	
	NSError *error = nil;
	
	NSString *uid = Param1.copyUTF16String();
	NSString *key = Param2.copyUTF16String();
	NSString *value = Param3.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
			CalTask *task = [defaultCalendarStore taskWithUID:uid];
			NSArray *taskProperties = [NSArray arrayWithObjects:
									   @"dueDate", @"isCompleted", 
									   @"priority", @"completedDate" ,
									   @"hasAlarm", @"nextAlarmDate", 
									   @"calendar", @"dateStamp", 
									   @"notes", @"title", 
									   @"url", nil];	
		if(task){
			NSUInteger pid = [taskProperties indexOfObject:key];
			
			switch (pid){
				case 0://dueDate
					task.dueDate = [NSDate dateWithString:value];		
					success = [defaultCalendarStore saveTask:task error:&error];
					break;
				case 1://isCompleted
					task.isCompleted = [value boolValue];
					success = [defaultCalendarStore saveTask:task error:&error];				
					break;
				case 2://priority
					task.priority = [value integerValue];
					success = [defaultCalendarStore saveTask:task error:&error];					
					break;
				case 3://completedDate
					task.completedDate = [NSDate dateWithString:value];		
					success = [defaultCalendarStore saveTask:task error:&error];	
					break;
				case 4://hasAlarm (readonly)		
					break;
				case 5://nextAlarmDate (readonly)								
					break;
				case 6://calendar
				{
					CalCalendar *calendar = [defaultCalendarStore calendarWithUID:value];
					if(calendar){
						task.calendar = calendar;
						success = [defaultCalendarStore saveTask:task error:&error];	
					}
				}
					break;
				case 7://dateStamp (readonly)
					break;																																																								
				case 8://notes	
					task.notes = value;		
					success = [defaultCalendarStore saveTask:task error:&error];						
					break;
				case 9://title	
					task.title = value;		
					success = [defaultCalendarStore saveTask:task error:&error];				
					break;
				case 10://url
				{
					NSURL *url = [NSURL URLWithString:value];
					if(url){
						task.url = url;
						success = [defaultCalendarStore saveTask:task error:&error];	
					}
				}
					break;
					
				default:
					break;
			}		
			
		}
		
		if(error){
			success = [error code];
			NSLog(@"can't update task: %@", [error localizedDescription]);
		}		
	}
	
	[uid release];
	[key release];
	[value release];	
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Get_task_property(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	int success = 0;
	
	NSString *uid = Param1.copyUTF16String();
	NSString *key = Param2.copyUTF16String();
	
	CalTask *task = [[CalCalendarStore defaultCalendarStore]taskWithUID:uid];
	
	NSArray *taskProperties = [NSArray arrayWithObjects:
							   @"dueDate", @"isCompleted", 
							   @"priority", @"completedDate" ,
							   @"hasAlarm", @"nextAlarmDate", 
							   @"calendar", @"dateStamp", 
							   @"notes", @"title", 
							   @"url", nil];
	
	if(task){
		NSUInteger pid = [taskProperties indexOfObject:key];
		
		switch (pid){
			case 0://dueDate
				Param3.setUTF16String([task.dueDate description]);
				success = 1;
				break;
			case 1://isCompleted
				if(task.isCompleted)
				{
					Param3.setUTF16String(@"YES");	
				}else{
					Param3.setUTF16String(@"NO");		
				}	
				success = 1;	
				break;
			case 2://priority	
				//	Param3.setUTF16String([NSString stringWithFormat:@"%@", task.priority]);
				
				if(task.priority){
					Param3.setUTF16String([[NSNumber numberWithInt:task.priority]stringValue]);
					success = 1;
				}else{
					Param3.setUTF16String(@"0");
					success = 1;				
				}					
				break;
			case 3://completedDate	
				Param3.setUTF16String([task.completedDate description]);						
				success = 1;					
				break;
			case 4://hasAlarm	
				if(task.hasAlarm)
				{
					Param3.setUTF16String(@"YES");						
				}else{
					Param3.setUTF16String(@"NO");	
				}
				success = 1;				
				break;
			case 5://nextAlarmDate
				Param3.setUTF16String([task.nextAlarmDate description]);
				success = 1;											
				break;
			case 6://calendar
				Param3.setUTF16String([task.calendar uid]);						
				success = 1;	
				break;
			case 7://dateStamp
				Param3.setUTF16String([task.dateStamp description]);					
				success = 1;			
				break;																																																								
			case 8://notes
				Param3.setUTF16String(task.notes);								
				success = 1;		
				break;
			case 9://title	
				Param3.setUTF16String(task.title);						
				success = 1;		
				break;
			case 10://url
				Param3.setUTF16String([task.url absoluteString]);					
				success = 1;
				break;
				
			default:
				break;
		}		
		
	}
	
	[uid release];
	[key release];	
	
	if(success)
		Param3.toParamAtIndex(pParams, 3);
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Remove_task(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	int success = 0;
	
	NSError *error = nil;	
	
	NSString * taskId = Param1.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
	
		CalTask *task = [[CalCalendarStore defaultCalendarStore]taskWithUID:taskId];
		
		if(task) success = [[CalCalendarStore defaultCalendarStore]removeTask:task error:&error];
		
		if(error){
			success = [error code];
			NSLog(@"can't remove task: %@", [error localizedDescription]);
		}		
	}
		
	[taskId release];
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Remove_task_alarm(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT Param2;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);

	int success = 0;
	
	NSError *error = nil;	
	
	NSString *taskId = Param1.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		
		CalTask *task = [defaultCalendarStore taskWithUID:taskId];
		if(task){ 
			int count = [[task alarms]count];
			int index = Param2.getIntValue();
			
			if((count >= index) && (index > 0)){
				CalAlarm *alarm = [[task alarms]objectAtIndex:(NSUInteger)(index - 1)];
				[task removeAlarm:alarm];
				success = 1;			
			}else{
				NSLog(@"invalid alarm index: %i", index);				
			}
			
		}else{
			success = [error code];
			NSLog(@"invalid task: %@", taskId);	
		}		
	}
		
	[taskId release];	
	
	returnValue.setIntValue(success);	
	returnValue.setReturn(pResult);
}

void iCal_Set_task_alarm(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
		
	int success = 0;
	
	NSError *error = nil;
	
	NSString *taskId = Param1.copyUTF16String();
	NSString *dictionary = Param3.copyUTF16String();	
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalTask *task = [defaultCalendarStore taskWithUID:taskId];		
		if(task){ 
			
			int count = [[task alarms]count];
			int index = Param2.getIntValue();
			
			if((count >= index) && (index > 0)){
				
				NSMutableArray *alarms = [[task alarms]mutableCopy];		
				CalAlarm *newAlarm = getAlarmFromString(dictionary);
				
				if(newAlarm){
					[alarms replaceObjectAtIndex:(NSUInteger)(index - 1) withObject:newAlarm];
					[task removeAlarms:[task alarms]];
					[task addAlarms:alarms];
					success = [defaultCalendarStore saveTask:task error:&error];	
				}
				
				[alarms release];
				
			}else{
				NSLog(@"invalid alarm index: %i", index);				
			}
			
		}else{
			success = [error code];
			NSLog(@"invalid task: %@", taskId);	
		}		
	}
	
	[taskId release];
	[dictionary release];
	
	returnValue.setIntValue(success);	
	returnValue.setReturn(pResult);
}

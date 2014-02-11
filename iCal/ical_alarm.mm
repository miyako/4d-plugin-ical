#import "ical_alarm.h"
#include "ical_support.h"
#import "helper.h"

// ------------------------------------- Alarm ------------------------------------

void iCal_Make_alarm(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT returnValue;
		
	CalAlarm *alarm = [CalAlarm alarm];
	NSString *alarmString = copyAlarmString(alarm);
	
	returnValue.setUTF16String(alarmString);
	returnValue.setReturn(pResult);
	
	[alarmString release];
}

void iCal_Get_alarm_property(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
		
	int success = 0;
	
	NSString *dictionary = Param1.copyUTF16String();
	NSString *key = Param2.copyUTF16String();
	
	CalAlarm *alarm = getAlarmFromString(dictionary);
	
	NSArray *alarmProperties = [NSArray arrayWithObjects:
								@"action", @"absoluteTrigger", 
								@"emailAddress", @"relativeTrigger",
								@"sound", @"url", nil];
	
	if(alarm){
		
		NSUInteger pid = [alarmProperties indexOfObject:key];
		
		switch (pid){
				
			case 0://action	
				if(alarm.action){
					Param3.setUTF16String(alarm.action);
					success = 1;	
				}				
				break;
			case 1://absoluteTrigger	
				if(alarm.absoluteTrigger){
					Param3.setUTF16String([alarm.absoluteTrigger description]);
					success = 1;					
				}	
				break;
			case 2://emailAddress	
				if(alarm.emailAddress){
					Param3.setUTF16String(alarm.emailAddress);
					success = 1;					
				}
				break;
			case 3://relativeTrigger
				if(alarm.relativeTrigger){
					Param3.setUTF16String([NSString stringWithFormat:@"%f", alarm.relativeTrigger]);
					success = 1;					
				}
				break;
			case 4://sound	
				if(alarm.sound){
					Param3.setUTF16String(alarm.sound);
					success = 1;
				}
				break;	
			case 5://url
				if(alarm.url){
					Param3.setUTF16String([alarm.url absoluteString]);
					success = 1;	
				}
				break;																				
		}		
	}
	
	[dictionary release];
	[key release];	
	
	if(success)
		Param3.toParamAtIndex(pParams, 3);
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Set_alarm_property(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	int success = 0;
	
	NSString *dictionary = Param1.copyUTF16String();
	NSString *key = Param2.copyUTF16String();
	NSString *value = Param3.copyUTF16String();
	
	CalAlarm *alarm = getAlarmFromString(dictionary);
	
	NSArray *alarmProperties = [NSArray arrayWithObjects:
								@"action", @"absoluteTrigger", 
								@"emailAddress", @"relativeTrigger" ,
								@"sound", @"url", nil];
	
	if(alarm){
		
		NSUInteger pid = [alarmProperties indexOfObject:key];
		NSDate *d = nil;
		NSURL *u = nil;
		
		switch (pid){
				
			case 0://action	
				alarm.action = value;
				success = 1;
				break;
			case 1://absoluteTrigger
				d = [NSDate dateWithString:value];
				if(d){
					alarm.absoluteTrigger = d;
					success = 1;
				}
				break;
			case 2://emailAddress	
				alarm.emailAddress = value;		
				success = 1;
				break;
			case 3://relativeTrigger
				alarm.relativeTrigger = [value doubleValue];		
				success = 1;	
				break;
			case 4://sound	
				alarm.sound = value;		
				success = 1;	
				break;	
			case 5://url
				u = [[NSURL alloc]initWithString:value];
				if(u){
					if([u isFileURL]){
						alarm.url = u;
						success = 1;
					}
					[u release];
				}
				break;																				
		}		
	}
	
	[dictionary release];
	dictionary = copyAlarmString(alarm);
	Param1.setUTF16String(dictionary);
	Param1.toParamAtIndex(pParams, 1);
	[dictionary release];	
	
	[key release];
	[value release];
	
	returnValue.setIntValue(success);		
	returnValue.setReturn(pResult);	
}

void iCal_Add_alarm_to_event(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	NSString *eventId = Param1.copyUTF16String();
	NSString *dictionary = Param2.copyUTF16String();
	
	int success = 0;
	
	NSError *error = nil;
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalEvent *event = [defaultCalendarStore eventWithUID:eventId occurrence:nil];	
		CalAlarm *alarm = getAlarmFromString(dictionary);
		if(event){		
			[event addAlarm:alarm];
			success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];
		}
		
		if(error){
			success = [error code];
			NSLog(@"can't update event: %@", [error localizedDescription]);
		}		
	}
	
	[eventId release];
	[dictionary release];
	
	returnValue.setIntValue(success);	
	returnValue.setReturn(pResult);
}

void iCal_Add_alarm_to_task(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	
	int success = 0;
	
	NSError *error = nil;

	NSString *taskId = Param1.copyUTF16String();
	NSString *dictionary = Param2.copyUTF16String();	
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
	
		CalTask *task = [defaultCalendarStore taskWithUID:taskId];	
		CalAlarm *alarm = getAlarmFromString(dictionary);
		
		if(task){
			[task addAlarm:alarm];
			success = [defaultCalendarStore saveTask:task error:&error];
		}
		
		if(error){
			success = [error code];
			NSLog(@"can't update task: %@", [error localizedDescription]);
		}		
		
	}
	
	[taskId release];
	[dictionary release];		
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}


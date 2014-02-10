#import "ical_event.h"
#import "helper.h"

// ------------------------------------- Event ------------------------------------

void iCal_Create_event(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_TEXT returnValue;
	C_LONGINT _returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	NSError *error = nil;
	
	CalCalendar *calendar;
	
	NSString *calendarId = Param1.copyUTF16String();
	NSString *startDateString = Param2.copyUTF16String();
	NSString *endDateString = Param3.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(_returnValue);

	if(defaultCalendarStore){
		calendar = _getCalendar(defaultCalendarStore, calendarId, _returnValue);			
		if(calendar){		
			CalEvent *event = [CalEvent event];
			NSDate *startDate = _getDate(startDateString, _returnValue);
			NSDate *endDate = _getDate(endDateString, _returnValue);
			if((startDate) && (endDate)){
				event.startDate = startDate;
				event.endDate = endDate;
				event.calendar = calendar;
				if(![defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error]){
					NSLog(@"can't save event: %@", [error localizedDescription]);
				}else{
					returnValue.setUTF16String([event uid]);
				}			
			}else{
				NSLog(@"invalid start date: %@, end date: %@", startDateString, endDateString);		
			}
		}else{
			NSLog(@"invalid calendar: %@", calendarId);	
		}		
	}

	[calendarId release];
	[startDateString release];
	[endDateString release];	
	
	returnValue.setReturn(pResult);
}

void iCal_Set_event_property(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_TEXT Param3;
	C_TEXT Param4;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	Param4.fromParamAtIndex(pParams, 4);
	
	int success = 0;
	
	NSError *error = nil;
	
	NSString *uid = Param1.copyUTF16String();
	NSString *key = Param2.copyUTF16String();
	NSString *value = Param3.copyUTF16String();
	NSString *date = Param4.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalEvent *event = [defaultCalendarStore eventWithUID:uid occurrence:[NSDate dateWithString:date]];	
		NSArray *eventProperties = [NSArray arrayWithObjects:
									@"isAllDay", @"isDetached", 
									@"location", @"occurrence", 
									@"recurrenceRule" ,@"startDate", 
									@"calendar", @"hasAlarm", 
									@"nextAlarmDate", @"dateStamp", 
									@"notes", @"title", 
									@"url", @"endDate", nil];
		if(event){
			NSUInteger pid = [eventProperties indexOfObject:key];
			switch (pid){
				case 0://isAllDay
					event.isAllDay = [value boolValue];		
					success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];
					break;
				case 1://isDetached (readonly)			
					break;
				case 2://location
					event.location = value;	
					success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];					
					break;
				case 3://occurrence (readonly) 
					break;
				case 4://recurrenceRule (dedicated command)
					break;
				case 5://startDate
					if([NSDate dateWithString:value]){
						event.startDate = [NSDate dateWithString:value];
						success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];
					}
					break;
				case 6://calendar
					{
						CalCalendar *calendar = _getCalendar(defaultCalendarStore, value, returnValue);
						if(calendar)
						{
							event.calendar = calendar;
							success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];	
						}
					}
					break;
				case 7://hasAlarm (readonly)
					break;
				case 8://nextAlarmDate (readonly)
					break;
				case 9://dateStamp (readonly)
					break;																																																								
				case 10://notes
					event.notes = value;	
					success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];			
					break;
				case 11://title
					event.title = value;	
					success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];						
					break;
				case 12://url
					{
						NSURL *url = [NSURL URLWithString:value];
						if(url)
						{
							event.url = url;
							success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];
						}
					}
					break;
				case 13://endDate
					if([NSDate dateWithString:value]){
						event.endDate = [NSDate dateWithString:value];	
						success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];
					}			
					break;				
				default:
					break;
			}		
			
		}
		
		if(error){
			success = [error code];
			NSLog(@"can't update event: %@", [error localizedDescription]);
		}		
	}

	[uid release];
	[key release];
	[value release];
	[date release];	
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Remove_event(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	
	int success = 0;

	NSError *error = nil;
	
	NSString *uid = Param1.copyUTF16String();

	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalEvent *event = [defaultCalendarStore eventWithUID:uid occurrence:nil];	
		if(event){ 
			success = [defaultCalendarStore removeEvent:event span:CalSpanAllEvents error:&error];
			if(error){
				success = [error code];
				NSLog(@"can't remove event: %@", [error localizedDescription]);
			}	
		}
	}
	
	[uid release];
	
	returnValue.setIntValue(success);	
	returnValue.setReturn(pResult);
}

void iCal_Remove_event_alarm(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT Param2;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);

	int success = 0;
	
	NSString *uid = Param1.copyUTF16String();
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalEvent *event = [defaultCalendarStore eventWithUID:uid occurrence:nil];	
		if(event){ 
			int count = [[event alarms]count];
			int index = Param2.getIntValue();
			if((count >= index) && (index > 0)){
				CalAlarm *alarm = [[event alarms]objectAtIndex:(NSUInteger)(index - 1)];
				[event removeAlarm:alarm];
				success = 1;			
			}else{
				NSLog(@"invalid alarm index: %@", index);				
			}
		}
	}
	
	[uid release];	
	
	returnValue.setIntValue(success);	
	returnValue.setReturn(pResult);
}

void iCal_Set_event_alarm(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT Param2;
	C_TEXT Param3;
	C_LONGINT returnValue;
	
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	
	int success = 0;
	
	NSError *error = nil;
	
	NSString *uid = Param1.copyUTF16String();
	NSString *dictionary = Param3.copyUTF16String();	
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalEvent *event = [defaultCalendarStore eventWithUID:uid occurrence:nil];	
		if(event){
			int count = [[event alarms]count];
			int index = Param2.getIntValue();
			if((count >= index) && (index > 0)){
				NSMutableArray *alarms = [[event alarms]mutableCopy];		
				CalAlarm *newAlarm = getAlarmFromString(dictionary);
				if(newAlarm){
					[alarms replaceObjectAtIndex:(NSUInteger)(index - 1) withObject:newAlarm];
					[event removeAlarms:[event alarms]];
					[event addAlarms:alarms];
					success = [defaultCalendarStore saveEvent:event span:CalSpanThisEvent error:&error];				
				}
				[alarms release];
			}else{
				NSLog(@"invalid alarm index: %@", index);				
			}
		}
	}
			
	[uid release];
	[dictionary release];
	
	returnValue.setIntValue(success);	
	returnValue.setReturn(pResult);
}

// -------------------------------- Recurrence Rule -------------------------------

void iCal_Remove_event_recurrence(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_LONGINT returnValue;
    
	Param1.fromParamAtIndex(pParams, 1);
    
	int success = 0;
	
	NSString *uid = Param1.copyUTF16String();

	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalEvent *event = [defaultCalendarStore eventWithUID:uid occurrence:nil];	
		if(event){
			event.recurrenceRule = nil;
			success = [[CalCalendarStore defaultCalendarStore]saveEvent:event span:CalSpanAllEvents error:NULL];
		}
	}
	
	[uid release];
    
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}

void iCal_Set_event_recurrence(sLONG_PTR *pResult, PackagePtr pParams){
	C_TEXT Param1;
	C_TEXT Param2;
	C_LONGINT Param3;
	C_TEXT Param4;
	C_TEXT Param5;
	C_TEXT Param6;
	C_TEXT Param7;
	C_LONGINT returnValue;
    
	Param1.fromParamAtIndex(pParams, 1);
	Param2.fromParamAtIndex(pParams, 2);
	Param3.fromParamAtIndex(pParams, 3);
	Param4.fromParamAtIndex(pParams, 4);
	Param5.fromParamAtIndex(pParams, 5);
	Param6.fromParamAtIndex(pParams, 6);
	Param7.fromParamAtIndex(pParams, 7);
    
	int success = 0;
	
	NSError *error = nil;
	
	NSString *uid = Param1.copyUTF16String();
	NSString *type = Param2.copyUTF16String();
	NSUInteger interval = Param3.getIntValue();
	NSString *dateString = Param4.copyUTF16String();
	NSString *param1 = Param5.copyUTF16String();	
	NSString *param2 = Param6.copyUTF16String();		
	NSString *param3 = Param7.copyUTF16String();
	NSDate *date = [NSDate dateWithString:dateString];
	
	CalCalendarStore *defaultCalendarStore = _getCalendarStore(returnValue);
	
	if(defaultCalendarStore){
		CalEvent *event = [defaultCalendarStore eventWithUID:uid occurrence:nil];
		if(event){
			
			NSArray *ruleTypes = [NSArray arrayWithObjects:
								  @"Daily", @"Weekly", @"Monthly", @"Yearly", nil];		
			NSUInteger pid = [ruleTypes indexOfObject:type];
			CalRecurrenceRule *rule;	
			NSArray *days;
			NSArray *months;

			switch (pid){
				case 0://Daily
					if(date){
						rule = [[CalRecurrenceRule alloc]initDailyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
					}else{				
						if([dateString length]){
							rule = [[CalRecurrenceRule alloc]initDailyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];
						}else{
							rule = [[CalRecurrenceRule alloc]initDailyRecurrenceWithInterval:interval end:nil];						
						}
					}
					event.recurrenceRule = rule;
					success = [[CalCalendarStore defaultCalendarStore]saveEvent:event span:CalSpanAllEvents error:&error];			
					[rule release];
					break;
				case 1://Weekly					
					days = [param1 componentsSeparatedByString:@","];
					if([days count]){
						if(date){
							rule = [[CalRecurrenceRule alloc]initWeeklyRecurrenceWithInterval:interval forDaysOfTheWeek:days end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
						}else{
							if([dateString length]){
								rule = [[CalRecurrenceRule alloc]initWeeklyRecurrenceWithInterval:interval forDaysOfTheWeek:days end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
							}else{
								rule = [[CalRecurrenceRule alloc]initWeeklyRecurrenceWithInterval:interval forDaysOfTheWeek:days end:nil];					
							}							
						}					
					}else{
						if(date){
							rule = [[CalRecurrenceRule alloc]initWeeklyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
						}else{
							if([dateString length]){
								rule = [[CalRecurrenceRule alloc]initWeeklyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
							}else{
								rule = [[CalRecurrenceRule alloc]initWeeklyRecurrenceWithInterval:interval end:nil];					
							}							
						}					
					}				
					event.recurrenceRule = rule;
					success = [[CalCalendarStore defaultCalendarStore]saveEvent:event span:CalSpanAllEvents error:&error];			
					[rule release];
					break;
				case 2://Monthly
					days = [param1 componentsSeparatedByString:@","];	
					if([days count]){
						if(date){
							rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval forDaysOfTheMonth:days end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
						}else{
							if([dateString length]){
								rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval forDaysOfTheMonth:days end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
							}else{
								rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval forDaysOfTheMonth:days end:nil];					
							}							
						}					
					}else{
						
						if(([param1 length])&&([param2 length])){
							if(date){
								rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval forDayOfTheWeek:[param1 integerValue] forWeekOfTheMonth:[param2 integerValue] end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
							}else{
								if([dateString length]){
									rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval forDayOfTheWeek:[param1 integerValue] forWeekOfTheMonth:[param2 integerValue] end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
								}else{
									rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval forDayOfTheWeek:[param1 integerValue] forWeekOfTheMonth:[param2 integerValue] end:nil];					
								}							
							}
						}else{
							if(date){
								rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
							}else{
								if([dateString length]){
									rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
								}else{
									rule = [[CalRecurrenceRule alloc]initMonthlyRecurrenceWithInterval:interval end:nil];					
								}							
							}
						}											
					}				
					
				case 3://Yearly
					days = [param1 componentsSeparatedByString:@","];
					months = [param3 componentsSeparatedByString:@","];
					if([months count]){
						
						if(date){
							rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval forDayOfTheWeek:[param1 integerValue] forWeekOfTheMonth:[param2 integerValue] forMonthsOfTheYear:months end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
						}else{
							if([dateString length]){
								rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval forDayOfTheWeek:[param1 integerValue] forWeekOfTheMonth:[param2 integerValue] forMonthsOfTheYear:months end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
							}else{
								rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval forDayOfTheWeek:[param1 integerValue] forWeekOfTheMonth:[param2 integerValue] forMonthsOfTheYear:months end:nil];					
							}							
						}					
						
					}else{
						if([days count]){
							if(date){
								rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval forMonthsOfTheYear:days end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
							}else{
								if([dateString length]){
									rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval forMonthsOfTheYear:days end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
								}else{
									rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval forMonthsOfTheYear:days end:nil];					
								}							
							}					
						}else{
							if(date){
								rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithEndDate:date]];
							}else{
								if([dateString length]){
									rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval end:[CalRecurrenceEnd recurrenceEndWithOccurrenceCount:[dateString integerValue]]];		
								}else{
									rule = [[CalRecurrenceRule alloc]initYearlyRecurrenceWithInterval:interval end:nil];					
								}							
							}											
						}				
					}					
					
					event.recurrenceRule = rule;
					success = [[CalCalendarStore defaultCalendarStore]saveEvent:event span:CalSpanAllEvents error:&error];			
					[rule release];															
					break;
			}
			if(error){
				success = [error code];
				NSLog(@"can't update event: %@", [error localizedDescription]);
			}	
		}
	}
	
	[uid release];
	[type release];	
	[dateString release];
	[param1 release];
	[param2 release];
	[param3 release];
	
	returnValue.setIntValue(success);
	returnValue.setReturn(pResult);
}
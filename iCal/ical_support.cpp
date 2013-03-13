/*
 *  ical_support.cpp
 *  4D Plugin
 *
 *  Created by miyako on 11/07/09.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "ical_support.h"

NSString * appleScriptExecuteFunction(NSString *fileName, NSString *functionName, NSString *argument1, NSString *argument2, NSString *argument3)
{
	NSBundle *thisBundle = [NSBundle bundleWithIdentifier:THIS_BUNDLE_ID];
	NSString *returnString = nil;
	
	if(thisBundle){
		NSString *scriptPath = [thisBundle 
								pathForResource:fileName 
								ofType:@"scpt"
								inDirectory:@"scpt"];
		
		if(scriptPath){
			NSURL *scriptUrl = [[NSURL alloc]initFileURLWithPath:scriptPath];
			if(scriptUrl){
				
				NSDictionary *errInfo;
				NSAppleScript *scriptObject = [[NSAppleScript alloc]initWithContentsOfURL:scriptUrl error:&errInfo];
				BOOL scriptIsCompiled = NO;
				
				if(scriptObject){
					
					scriptIsCompiled = [scriptObject isCompiled];
					
					if(!scriptIsCompiled){
						scriptIsCompiled = [scriptObject compileAndReturnError:&errInfo]; 
					}
					
					if(scriptIsCompiled){
						
						
						if((!argument1) && (!argument2) && (!argument3)){
							
							NSAppleEventDescriptor *returnValue = [scriptObject executeAndReturnError:&errInfo];
							if(returnValue)
								returnString = [returnValue stringValue];							
							
						}else{
							
							NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
							
							if(argument1){
								NSAppleEventDescriptor *param1 = [NSAppleEventDescriptor descriptorWithString:argument1];
								[parameters insertDescriptor:param1 atIndex:1];//The list indices are one-based.
								if(argument2){
									NSAppleEventDescriptor *param2 = [NSAppleEventDescriptor descriptorWithString:argument2];
									[parameters insertDescriptor:param2 atIndex:2];//The list indices are one-based.
									if(argument3){
										NSAppleEventDescriptor *param3 = [NSAppleEventDescriptor descriptorWithString:argument3];
										[parameters insertDescriptor:param3 atIndex:3];//The list indices are one-based.
									}									
								}
							}
							
							ProcessSerialNumber psn = {0, kCurrentProcess};
							NSAppleEventDescriptor *target =
							[NSAppleEventDescriptor
							 descriptorWithDescriptorType:typeProcessSerialNumber
							 bytes:&psn
							 length:sizeof(ProcessSerialNumber)];
							
							NSAppleEventDescriptor *handler = [NSAppleEventDescriptor descriptorWithString:functionName];//the routine name must be in lower case.
							
							NSAppleEventDescriptor *event =
							[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
																	 eventID:kASSubroutineEvent
															targetDescriptor:target
																	returnID:kAutoGenerateReturnID
															   transactionID:kAnyTransactionID];									  
							
							[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
							[event setParamDescriptor:parameters forKeyword:keyDirectObject];
							
							NSAppleEventDescriptor *returnValue = [scriptObject executeAppleEvent:event error:&errInfo];
							if(returnValue)
								returnString = [returnValue stringValue];
							
						}
						
					}
					
					[scriptObject release];
				}
				[scriptUrl release];
			}
		}
	}
	
	return returnString;
}

CalAlarm *getAlarmFromString(NSString *dictionary)
{
	CalAlarm *alarm = nil;
	NSDate *d = nil;
	NSURL *u = nil;
	
	if(dictionary){
		
		CFPropertyListRef dictionaryPropertyList = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)[dictionary dataUsingEncoding:NSUTF8StringEncoding], kCFPropertyListImmutable, NULL);	
		
		if(dictionaryPropertyList){
			
			if(CFGetTypeID(dictionaryPropertyList) == CFDictionaryGetTypeID()){
				
				alarm = [CalAlarm alarm];
				NSDictionary *dictionary = (NSDictionary *)dictionaryPropertyList;
				
				if([dictionary objectForKey:@"action"])
					alarm.action = (NSString *)[dictionary objectForKey:@"action"];				
					
				if([dictionary objectForKey:@"absoluteTrigger"]){
					d = [NSDate dateWithString:(NSString *)[dictionary objectForKey:@"absoluteTrigger"]];
					if(d)alarm.absoluteTrigger = d;	
				}
			
				if([dictionary objectForKey:@"emailAddress"])					
					alarm.emailAddress = (NSString *)[dictionary objectForKey:@"emailAddress"];				

				if([dictionary objectForKey:@"relativeTrigger"])
					alarm.relativeTrigger = [[dictionary objectForKey:@"relativeTrigger"]doubleValue];				

				if([dictionary objectForKey:@"sound"])						
					alarm.sound = (NSString *)[dictionary objectForKey:@"sound"];				
				
				if([dictionary objectForKey:@"url"]){
					u = [NSURL URLWithString:(NSString *)[dictionary objectForKey:@"url"]];
					if(u)if([u isFileURL])alarm.url = u;	
				}
			}
			CFRelease(dictionaryPropertyList);
		}
	}
	
	return alarm;
	
}

NSString *copyAlarmString(CalAlarm *alarm)
{
	NSString *alarmData = nil; 
	
	if(alarm)
	{
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
		
		if(alarm.action)
		{
			[dictionary setObject:alarm.action forKey:@"action"];		
		}else{
			[dictionary setObject:@"" forKey:@"action"];		
		}			
		if(alarm.absoluteTrigger)
		{
			[dictionary setObject:[alarm.absoluteTrigger description] forKey:@"absoluteTrigger"];		
		}else{
			[dictionary setObject:@"" forKey:@"absoluteTrigger"];		
		}			
		if(alarm.emailAddress)
		{
			[dictionary setObject:alarm.emailAddress forKey:@"emailAddress"];		
		}else{
			[dictionary setObject:@"" forKey:@"emailAddress"];		
		}		
		if(alarm.relativeTrigger)
		{
			[dictionary setObject:[NSNumber numberWithDouble:alarm.relativeTrigger] forKey:@"relativeTrigger"];	
		}else{
			[dictionary setObject:@"" forKey:@"relativeTrigger"];		
		}
		if(alarm.sound)
		{
			[dictionary setObject:alarm.sound forKey:@"sound"];		
		}else{
			[dictionary setObject:@"" forKey:@"sound"];		
		}
		if(alarm.url)
		{
			[dictionary setObject:[alarm.url absoluteString] forKey:@"url"];		
		}else{
			[dictionary setObject:@"" forKey:@"url"];		
		}
		
		CFPropertyListRef dictionaryPropertyList = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)dictionary, kCFPropertyListImmutable);	
		NSData *dictionaryData = (NSData *)CFPropertyListCreateXMLData(kCFAllocatorDefault, dictionaryPropertyList);	
		
		alarmData = [[NSString alloc]initWithData:dictionaryData encoding:NSUTF8StringEncoding];
		
		[dictionaryData release];
		CFRelease(dictionaryPropertyList);	
		[dictionary release];
		
	}else{alarmData = @"";}
	
	return alarmData;	
	
}

NSColor *getColorIndex(int index)
{
	float redComponent;
	float greenComponent;
	float blueComponent;
	float alphaComponent = 1;
	
	switch(index)
	{
		case 1 :
			redComponent = 1;
			greenComponent = 1;
			blueComponent = 1;
			break;
		case 2 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 1;
			break;
		case 3 :
			redComponent = 0;
			greenComponent = 0.4;
			blueComponent = 1;
			break;
		case 4 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.9333333333333333481;
			break;
		case 5 :
			redComponent = 0.6;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 6 :
			redComponent = 0.6;
			greenComponent = 0;
			blueComponent = 0;
			break;
		case 7 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0;
			break;
		case 8 :
			redComponent = 1;
			greenComponent = 0.6;
			blueComponent = 0;
			break;
		case 9 :
			redComponent = 0;
			greenComponent = 0.7333333333333332815;
			blueComponent = 0;
			break;
		case 10 :
			redComponent = 0;
			greenComponent = 0.6;
			blueComponent = 0;
			break;
		case 11 :
			redComponent = 0;
			greenComponent = 0.2;
			blueComponent = 0.4;
			break;
		case 12 :
			redComponent = 0.266666666666666663;
			greenComponent = 0.266666666666666663;
			blueComponent = 0.266666666666666663;
			break;
		case 13 :
			redComponent = 0.8666666666666666963;
			greenComponent = 0.8666666666666666963;
			blueComponent = 0.8666666666666666963;
			break;
		case 14 :
			redComponent = 0;
			greenComponent = 0.4;
			blueComponent = 0.6;
			break;
		case 15 :
			redComponent = 0.6666666666666666297;
			greenComponent = 0.6666666666666666297;
			blueComponent = 0.6666666666666666297;
			break;
		case 16 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0;
			break;
		case 17 :
			redComponent = 0.3686274509804;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 18 :
			redComponent = 0.3372549019607843368;
			greenComponent = 0.01568627450980392135;
			blueComponent = 1;
			break;
		case 19 :
			redComponent = 0.2823529411764705843;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 20 :
			redComponent = 0.2941176470588235392;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 21 :
			redComponent = 0.1960784313725490169;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 22 :
			redComponent = 0.152941176470588247;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 23 :
			redComponent = 0.1098039215686274495;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 24 :
			redComponent = 0.06666666666666666574;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 25 :
			redComponent = 0.02352941176470588203;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 26 :
			redComponent = 0;
			greenComponent = 0.01568627450980392135;
			blueComponent = 1;
			break;
		case 27 :
			redComponent = 0;
			greenComponent = 0.05882352941176470507;
			blueComponent = 1;
			break;
		case 28 :
			redComponent = 0;
			greenComponent = 0.1019607843137254888;
			blueComponent = 1;
			break;
		case 29 :
			redComponent = 0;
			greenComponent = 0.1450980392156862864;
			blueComponent = 1;
			break;
		case 30 :
			redComponent = 0;
			greenComponent = 0.1882352941176470562;
			blueComponent = 1;
			break;
		case 31 :
			redComponent = 0;
			greenComponent = 0.2313725490196;
			blueComponent = 1;
			break;
		case 32 :
			redComponent = 0;
			greenComponent = 0.2745098039215686514;
			blueComponent = 1;
			break;
		case 33 :
			redComponent = 0;
			greenComponent = 0.3019607843137254721;
			blueComponent = 1;
			break;
		case 34 :
			redComponent = 0;
			greenComponent = 0.3294117647058823484;
			blueComponent = 1;
			break;
		case 35 :
			redComponent = 0;
			greenComponent = 0.3568627450980392246;
			blueComponent = 1;
			break;
		case 36 :
			redComponent = 0;
			greenComponent = 0.3843137254902;
			blueComponent = 1;
			break;
		case 37 :
			redComponent = 0;
			greenComponent = 0.4117647058823529216;
			blueComponent = 1;
			break;
		case 38 :
			redComponent = 0.01176470588235294101;
			greenComponent = 0.4470588235294117863;
			blueComponent = 1;
			break;
		case 39 :
			redComponent = 0.01568627450980392135;
			greenComponent = 0.4862745098039215619;
			blueComponent = 1;
			break;
		case 40 :
			redComponent = 0.007843137254902;
			greenComponent = 0.5098039215686274161;
			blueComponent = 1;
			break;
		case 41 :
			redComponent = 0.02352941176470588203;
			greenComponent = 0.5411764705882352589;
			blueComponent = 1;
			break;
		case 42 :
			redComponent = 0.01176470588235294101;
			greenComponent = 0.5725490196078431016;
			blueComponent = 1;
			break;
		case 43 :
			redComponent = 0.007843137254902;
			greenComponent = 0.6;
			blueComponent = 1;
			break;
		case 44 :
			redComponent = 0.01176470588235294101;
			greenComponent = 0.627450980392156854;
			blueComponent = 1;
			break;
		case 45 :
			redComponent = 0;
			greenComponent = 0.6235294117647;
			blueComponent = 1;
			break;
		case 46 :
			redComponent = 0.0627450980392156854;
			greenComponent = 0.6823529411764706065;
			blueComponent = 1;
			break;
		case 47 :
			redComponent = 0.02745098039215686236;
			greenComponent = 0.6941176470588235059;
			blueComponent = 1;
			break;
		case 48 :
			redComponent = 0.01568627450980392135;
			greenComponent = 0.7215686274509803821;
			blueComponent = 1;
			break;
		case 49 :
			redComponent = 0;
			greenComponent = 0.7529411764705882248;
			blueComponent = 1;
			break;
		case 50 :
			redComponent = 0.01568627450980392135;
			greenComponent = 0.7803921568627451011;
			blueComponent = 1;
			break;
		case 51 :
			redComponent = 0;
			greenComponent = 0.8078431372549;
			blueComponent = 1;
			break;
		case 52 :
			redComponent = 0;
			greenComponent = 0.8431372549019607865;
			blueComponent = 1;
			break;
		case 53 :
			redComponent = 0.01176470588235294101;
			greenComponent = 0.8745098039215686292;
			blueComponent = 1;
			break;
		case 54 :
			redComponent = 0.01960784313725490169;
			greenComponent = 0.9019607843137255054;
			blueComponent = 1;
			break;
		case 55 :
			redComponent = 0.03921568627451;
			greenComponent = 0.9372549019607843146;
			blueComponent = 1;
			break;
		case 56 :
			redComponent = 0.01568627450980392135;
			greenComponent = 0.9647058823529411908;
			blueComponent = 1;
			break;
		case 57 :
			redComponent = 0.02352941176470588203;
			greenComponent = 0.9921568627451;
			blueComponent = 1;
			break;
		case 58 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.9764705882353;
			break;
		case 59 :
			redComponent = 0.01568627450980392135;
			greenComponent = 1;
			blueComponent = 0.949019607843137214;
			break;
		case 60 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.9215686274509803377;
			break;
		case 61 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.8862745098039215286;
			break;
		case 62 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.8274509803921568096;
			break;
		case 63 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.7921568627451;
			break;
		case 64 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.7647058823529411242;
			break;
		case 65 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.737254901960784359;
			break;
		case 66 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.6509803921568627638;
			break;
		case 67 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.5647058823529411686;
			break;
		case 68 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.478431372549019629;
			break;
		case 69 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.3921568627451;
			break;
		case 70 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.3098039215686274606;
			break;
		case 71 :
			redComponent = 0.01176470588235294101;
			greenComponent = 1;
			blueComponent = 0.2352941176470588203;
			break;
		case 72 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.04705882352941176405;
			break;
		case 73 :
			redComponent = 0.04705882352941176405;
			greenComponent = 1;
			blueComponent = 0.01176470588235294101;
			break;
		case 74 :
			redComponent = 0.1372549019607843257;
			greenComponent = 1;
			blueComponent = 0.01568627450980392135;
			break;
		case 75 :
			redComponent = 0.2078431372549;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 76 :
			redComponent = 0.2941176470588235392;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 77 :
			redComponent = 0.3764705882353;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 78 :
			redComponent = 0.4627450980392157076;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 79 :
			redComponent = 0.5490196078431373028;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 80 :
			redComponent = 0.6549019607843137303;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 81 :
			redComponent = 0.6549019607843137303;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 82 :
			redComponent = 0.6941176470588235059;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 83 :
			redComponent = 0.7333333333333332815;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 84 :
			redComponent = 0.7725490196078431682;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 85 :
			redComponent = 0.8156862745098;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 86 :
			redComponent = 0.8549019607843136859;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 87 :
			redComponent = 0.8941176470588235725;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 88 :
			redComponent = 0.9333333333333333481;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 89 :
			redComponent = 0.9725490196078431238;
			greenComponent = 1;
			blueComponent = 0;
			break;
		case 90 :
			redComponent = 1;
			greenComponent = 0.9921568627451;
			blueComponent = 0;
			break;
		case 91 :
			redComponent = 1;
			greenComponent = 0.9529411764705881804;
			blueComponent = 0;
			break;
		case 92 :
			redComponent = 1;
			greenComponent = 0.9137254901960784048;
			blueComponent = 0;
			break;
		case 93 :
			redComponent = 1;
			greenComponent = 0.8784313725490195957;
			blueComponent = 0;
			break;
		case 94 :
			redComponent = 1;
			greenComponent = 0.8352941176470588536;
			blueComponent = 0;
			break;
		case 95 :
			redComponent = 1;
			greenComponent = 0.7960784313725489669;
			blueComponent = 0;
			break;
		case 96 :
			redComponent = 1;
			greenComponent = 0.7568627450980391913;
			blueComponent = 0;
			break;
		case 97 :
			redComponent = 1;
			greenComponent = 0.7058823529411765163;
			blueComponent = 0;
			break;
		case 98 :
			redComponent = 1;
			greenComponent = 0.6313725490196;
			blueComponent = 0;
			break;
		case 99 :
			redComponent = 1;
			greenComponent = 0.5568627450980392357;
			blueComponent = 0;
			break;
		case 100 :
			redComponent = 1;
			greenComponent = 0.4862745098039215619;
			blueComponent = 0;
			break;
		case 101 :
			redComponent = 1;
			greenComponent = 0.4117647058823529216;
			blueComponent = 0;
			break;
		case 102 :
			redComponent = 1;
			greenComponent = 0.3372549019607843368;
			blueComponent = 0;
			break;
		case 103 :
			redComponent = 1;
			greenComponent = 0.2627450980392156965;
			blueComponent = 0;
			break;
		case 104 :
			redComponent = 1;
			greenComponent = 0.1568627450980392135;
			blueComponent = 0.003921568627451;
			break;
		case 105 :
			redComponent = 1;
			greenComponent = 0.1176470588235294101;
			blueComponent = 0;
			break;
		case 106 :
			redComponent = 1;
			greenComponent = 0.04313725490196;
			blueComponent = 0;
			break;
		case 107 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.02745098039215686236;
			break;
		case 108 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.09803921568627450844;
			break;
		case 109 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.1725490196078431349;
			break;
		case 110 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.2470588235294117752;
			break;
		case 111 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.3215686274509804154;
			break;
		case 112 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.3960784313725490002;
			break;
		case 113 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.4705882352941176405;
			break;
		case 114 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.5450980392156862253;
			break;
		case 115 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.6196078431372549211;
			break;
		case 116 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.6941176470588235059;
			break;
		case 117 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.7686274509804;
			break;
		case 118 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.8431372549019607865;
			break;
		case 119 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.9176470588235293713;
			break;
		case 120 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 0.9921568627451;
			break;
		case 121 :
			redComponent = 0.9372549019607843146;
			greenComponent = 0.01176470588235294101;
			blueComponent = 1;
			break;
		case 122 :
			redComponent = 0.8627450980392157298;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 123 :
			redComponent = 0.788235294117647034;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 124 :
			redComponent = 0.7137254901960784492;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 125 :
			redComponent = 0.6392156862745;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 126 :
			redComponent = 0.5647058823529411686;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 127 :
			redComponent = 0.4901960784313725283;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 128 :
			redComponent = 0.4156862745098;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 129 :
			redComponent = 0.8784313725490195957;
			greenComponent = 0.8784313725490195957;
			blueComponent = 1;
			break;
		case 130 :
			redComponent = 0.7529411764705882248;
			greenComponent = 0.7529411764705882248;
			blueComponent = 1;
			break;
		case 131 :
			redComponent = 0.627450980392156854;
			greenComponent = 0.627450980392156854;
			blueComponent = 1;
			break;
		case 132 :
			redComponent = 0.4980392156862745168;
			greenComponent = 0.4980392156862745168;
			blueComponent = 1;
			break;
		case 133 :
			redComponent = 0.372549019607843146;
			greenComponent = 0.372549019607843146;
			blueComponent = 1;
			break;
		case 134 :
			redComponent = 0.2509803921568627416;
			greenComponent = 0.2509803921568627416;
			blueComponent = 1;
			break;
		case 135 :
			redComponent = 0.1254901960784313708;
			greenComponent = 0.1254901960784313708;
			blueComponent = 1;
			break;
		case 136 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 137 :
			redComponent = 0;
			greenComponent = 0.05882352941176470507;
			blueComponent = 0.9254901960784314152;
			break;
		case 138 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.847058823529411753;
			break;
		case 139 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.8117647058823529438;
			break;
		case 140 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.6901960784313725394;
			break;
		case 141 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.6117647058823529882;
			break;
		case 142 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.5333333333333333259;
			break;
		case 143 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.4549019607843137192;
			break;
		case 144 :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0.3764705882353;
			break;
		case 145 :
			redComponent = 0.8745098039215686292;
			greenComponent = 0.9411764705882352811;
			blueComponent = 1;
			break;
		case 146 :
			redComponent = 0.7529411764705882248;
			greenComponent = 0.8784313725490195957;
			blueComponent = 1;
			break;
		case 147 :
			redComponent = 0.627450980392156854;
			greenComponent = 0.8117647058823529438;
			blueComponent = 1;
			break;
		case 148 :
			redComponent = 0.4980392156862745168;
			greenComponent = 0.7450980392156862919;
			blueComponent = 1;
			break;
		case 149 :
			redComponent = 0.372549019607843146;
			greenComponent = 0.6901960784313725394;
			blueComponent = 1;
			break;
		case 150 :
			redComponent = 0.2509803921568627416;
			greenComponent = 0.6313725490196;
			blueComponent = 1;
			break;
		case 151 :
			redComponent = 0.1254901960784313708;
			greenComponent = 0.5686274509804;
			blueComponent = 1;
			break;
		case 152 :
			redComponent = 0;
			greenComponent = 0.5058823529411764497;
			blueComponent = 1;
			break;
		case 153 :
			redComponent = 0;
			greenComponent = 0.4666666666666666741;
			blueComponent = 0.9254901960784314152;
			break;
		case 154 :
			redComponent = 0;
			greenComponent = 0.4274509803921568429;
			blueComponent = 0.847058823529411753;
			break;
		case 155 :
			redComponent = 0;
			greenComponent = 0.3882352941176470673;
			blueComponent = 0.7686274509804;
			break;
		case 156 :
			redComponent = 0;
			greenComponent = 0.3490196078431372362;
			blueComponent = 0.6901960784313725394;
			break;
		case 157 :
			redComponent = 0;
			greenComponent = 0.3215686274509804154;
			blueComponent = 0.6117647058823529882;
			break;
		case 158 :
			redComponent = 0;
			greenComponent = 0.2705882352941176294;
			blueComponent = 0.5333333333333333259;
			break;
		case 159 :
			redComponent = 0;
			greenComponent = 0.2313725490196;
			blueComponent = 0.4549019607843137192;
			break;
		case 160 :
			redComponent = 0;
			greenComponent = 0.1882352941176470562;
			blueComponent = 0.3764705882353;
			break;
		case 161 :
			redComponent = 0.8745098039215686292;
			greenComponent = 1;
			blueComponent = 1;
			break;
		case 162 :
			redComponent = 0.7529411764705882248;
			greenComponent = 1;
			blueComponent = 1;
			break;
		case 163 :
			redComponent = 0.627450980392156854;
			greenComponent = 1;
			blueComponent = 1;
			break;
		case 164 :
			redComponent = 0.4980392156862745168;
			greenComponent = 1;
			blueComponent = 1;
			break;
		case 165 :
			redComponent = 0.372549019607843146;
			greenComponent = 1;
			blueComponent = 0.9960784313725490335;
			break;
		case 166 :
			redComponent = 0.2509803921568627416;
			greenComponent = 1;
			blueComponent = 0.9960784313725490335;
			break;
		case 167 :
			redComponent = 0.1254901960784313708;
			greenComponent = 1;
			blueComponent = 0.9960784313725490335;
			break;
		case 168 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.9960784313725490335;
			break;
		case 169 :
			redComponent = 0;
			greenComponent = 0.9254901960784314152;
			blueComponent = 0.9176470588235293713;
			break;
		case 170 :
			redComponent = 0;
			greenComponent = 0.8431372549019607865;
			blueComponent = 0.8392156862745;
			break;
		case 171 :
			redComponent = 0;
			greenComponent = 0.7647058823529411242;
			blueComponent = 0.7607843137255;
			break;
		case 172 :
			redComponent = 0;
			greenComponent = 0.686274509803921573;
			blueComponent = 0.6823529411764706065;
			break;
		case 173 :
			redComponent = 0;
			greenComponent = 0.6235294117647;
			blueComponent = 0.6196078431372549211;
			break;
		case 174 :
			redComponent = 0;
			greenComponent = 0.5333333333333333259;
			blueComponent = 0.5294117647058823595;
			break;
		case 175 :
			redComponent = 0;
			greenComponent = 0.4549019607843137192;
			blueComponent = 0.4509803921568627527;
			break;
		case 176 :
			redComponent = 0;
			greenComponent = 0.3764705882353;
			blueComponent = 0.372549019607843146;
			break;
		case 177 :
			redComponent = 0.8745098039215686292;
			greenComponent = 1;
			blueComponent = 0.8862745098039215286;
			break;
		case 178 :
			redComponent = 0.7529411764705882248;
			greenComponent = 1;
			blueComponent = 0.7725490196078431682;
			break;
		case 179 :
			redComponent = 0.627450980392156854;
			greenComponent = 1;
			blueComponent = 0.6549019607843137303;
			break;
		case 180 :
			redComponent = 0.4980392156862745168;
			greenComponent = 1;
			blueComponent = 0.5372549019607842924;
			break;
		case 181 :
			redComponent = 0.372549019607843146;
			greenComponent = 1;
			blueComponent = 0.4235294117647;
			break;
		case 182 :
			redComponent = 0.2509803921568627416;
			greenComponent = 1;
			blueComponent = 0.3098039215686274606;
			break;
		case 183 :
			redComponent = 0.1254901960784313708;
			greenComponent = 1;
			blueComponent = 0.1921568627451;
			break;
		case 184 :
			redComponent = 0;
			greenComponent = 1;
			blueComponent = 0.07450980392156862642;
			break;
		case 185 :
			redComponent = 0;
			greenComponent = 0.9254901960784314152;
			blueComponent = 0.07058823529411764608;
			break;
		case 186 :
			redComponent = 0;
			greenComponent = 0.847058823529411753;
			blueComponent = 0.0627450980392156854;
			break;
		case 187 :
			redComponent = 0;
			greenComponent = 0.7686274509804;
			blueComponent = 0.05882352941176470507;
			break;
		case 188 :
			redComponent = 0;
			greenComponent = 0.6901960784313725394;
			blueComponent = 0.05098039215686274439;
			break;
		case 189 :
			redComponent = 0;
			greenComponent = 0.6117647058823529882;
			blueComponent = 0.04705882352941176405;
			break;
		case 190 :
			redComponent = 0;
			greenComponent = 0.5333333333333333259;
			blueComponent = 0.03921568627451;
			break;
		case 191 :
			redComponent = 0;
			greenComponent = 0.4549019607843137192;
			blueComponent = 0.03529411764705882304;
			break;
		case 192 :
			redComponent = 0;
			greenComponent = 0.3764705882353;
			blueComponent = 0.02745098039215686236;
			break;
		case 193 :
			redComponent = 1;
			greenComponent = 1;
			blueComponent = 0.8745098039215686292;
			break;
		case 194 :
			redComponent = 1;
			greenComponent = 1;
			blueComponent = 0.7529411764705882248;
			break;
		case 195 :
			redComponent = 1;
			greenComponent = 1;
			blueComponent = 0.627450980392156854;
			break;
		case 196 :
			redComponent = 1;
			greenComponent = 0.9960784313725490335;
			blueComponent = 0.4980392156862745168;
			break;
		case 197 :
			redComponent = 1;
			greenComponent = 0.9960784313725490335;
			blueComponent = 0.372549019607843146;
			break;
		case 198 :
			redComponent = 1;
			greenComponent = 0.9960784313725490335;
			blueComponent = 0.2509803921568627416;
			break;
		case 199 :
			redComponent = 1;
			greenComponent = 0.9921568627451;
			blueComponent = 0.1254901960784313708;
			break;
		case 200 :
			redComponent = 1;
			greenComponent = 0.9921568627451;
			blueComponent = 0;
			break;
		case 201 :
			redComponent = 0.9254901960784314152;
			greenComponent = 0.9137254901960784048;
			blueComponent = 0;
			break;
		case 202 :
			redComponent = 0.847058823529411753;
			greenComponent = 0.8392156862745;
			blueComponent = 0;
			break;
		case 203 :
			redComponent = 0.7686274509804;
			greenComponent = 0.7607843137255;
			blueComponent = 0;
			break;
		case 204 :
			redComponent = 0.6901960784313725394;
			greenComponent = 0.6823529411764706065;
			blueComponent = 0;
			break;
		case 205 :
			redComponent = 0.6117647058823529882;
			greenComponent = 0.6078431372549;
			blueComponent = 0;
			break;
		case 206 :
			redComponent = 0.5333333333333333259;
			greenComponent = 0.5294117647058823595;
			blueComponent = 0;
			break;
		case 207 :
			redComponent = 0.4549019607843137192;
			greenComponent = 0.4509803921568627527;
			blueComponent = 0;
			break;
		case 208 :
			redComponent = 0.3764705882353;
			greenComponent = 0.372549019607843146;
			blueComponent = 0;
			break;
		case 209 :
			redComponent = 1;
			greenComponent = 0.8941176470588235725;
			blueComponent = 0.8745098039215686292;
			break;
		case 210 :
			redComponent = 1;
			greenComponent = 0.7921568627451;
			blueComponent = 0.7529411764705882248;
			break;
		case 211 :
			redComponent = 1;
			greenComponent = 0.686274509803921573;
			blueComponent = 0.627450980392156854;
			break;
		case 212 :
			redComponent = 1;
			greenComponent = 0.5764705882353;
			blueComponent = 0.4980392156862745168;
			break;
		case 213 :
			redComponent = 1;
			greenComponent = 0.4705882352941176405;
			blueComponent = 0.372549019607843146;
			break;
		case 214 :
			redComponent = 1;
			greenComponent = 0.3686274509804;
			blueComponent = 0.2509803921568627416;
			break;
		case 215 :
			redComponent = 1;
			greenComponent = 0.25882352941176473;
			blueComponent = 0.1254901960784313708;
			break;
		case 216 :
			redComponent = 1;
			greenComponent = 0.152941176470588247;
			blueComponent = 0;
			break;
		case 217 :
			redComponent = 0.9254901960784314152;
			greenComponent = 0.1411764705882352922;
			blueComponent = 0;
			break;
		case 218 :
			redComponent = 0.847058823529411753;
			greenComponent = 0.129411764705882365;
			blueComponent = 0;
			break;
		case 219 :
			redComponent = 0.8117647058823529438;
			greenComponent = 0.1254901960784313708;
			blueComponent = 0;
			break;
		case 220 :
			redComponent = 0.6901960784313725394;
			greenComponent = 0.1058823529411764691;
			blueComponent = 0;
			break;
		case 221 :
			redComponent = 0.6117647058823529882;
			greenComponent = 0.09411764705882352811;
			blueComponent = 0;
			break;
		case 222 :
			redComponent = 0.5333333333333333259;
			greenComponent = 0.08235294117647;
			blueComponent = 0;
			break;
		case 223 :
			redComponent = 0.4549019607843137192;
			greenComponent = 0.07058823529411764608;
			blueComponent = 0;
			break;
		case 224 :
			redComponent = 0.3764705882353;
			greenComponent = 0.05490196078431372473;
			blueComponent = 0;
			break;
		case 225 :
			redComponent = 1;
			greenComponent = 0.8745098039215686292;
			blueComponent = 1;
			break;
		case 226 :
			redComponent = 1;
			greenComponent = 0.7529411764705882248;
			blueComponent = 1;
			break;
		case 227 :
			redComponent = 1;
			greenComponent = 0.627450980392156854;
			blueComponent = 1;
			break;
		case 228 :
			redComponent = 1;
			greenComponent = 0.4980392156862745168;
			blueComponent = 1;
			break;
		case 229 :
			redComponent = 1;
			greenComponent = 0.372549019607843146;
			blueComponent = 1;
			break;
		case 230 :
			redComponent = 1;
			greenComponent = 0.2509803921568627416;
			blueComponent = 1;
			break;
		case 231 :
			redComponent = 1;
			greenComponent = 0.1254901960784313708;
			blueComponent = 1;
			break;
		case 232 :
			redComponent = 1;
			greenComponent = 0;
			blueComponent = 1;
			break;
		case 233 :
			redComponent = 0.9254901960784314152;
			greenComponent = 0;
			blueComponent = 0.9215686274509803377;
			break;
		case 234 :
			redComponent = 0.847058823529411753;
			greenComponent = 0;
			blueComponent = 0.8431372549019607865;
			break;
		case 235 :
			redComponent = 0.8117647058823529438;
			greenComponent = 0;
			blueComponent = 0.8117647058823529438;
			break;
		case 236 :
			redComponent = 0.6901960784313725394;
			greenComponent = 0;
			blueComponent = 0.6901960784313725394;
			break;
		case 237 :
			redComponent = 0.6117647058823529882;
			greenComponent = 0;
			blueComponent = 0.6117647058823529882;
			break;
		case 238 :
			redComponent = 0.5333333333333333259;
			greenComponent = 0;
			blueComponent = 0.5333333333333333259;
			break;
		case 239 :
			redComponent = 0.4549019607843137192;
			greenComponent = 0;
			blueComponent = 0.4549019607843137192;
			break;
		case 240 :
			redComponent = 0.3764705882353;
			greenComponent = 0;
			blueComponent = 0.3764705882353;
			break;
		case 241 :
			redComponent = 1;
			greenComponent = 1;
			blueComponent = 1;
			break;
		case 242 :
			redComponent = 0.9333333333333333481;
			greenComponent = 0.9333333333333333481;
			blueComponent = 0.9333333333333333481;
			break;
		case 243 :
			redComponent = 0.8666666666666666963;
			greenComponent = 0.8666666666666666963;
			blueComponent = 0.8666666666666666963;
			break;
		case 244 :
			redComponent = 0.8;
			greenComponent = 0.8;
			blueComponent = 0.8;
			break;
		case 245 :
			redComponent = 0.7529411764705882248;
			greenComponent = 0.7529411764705882248;
			blueComponent = 0.7529411764705882248;
			break;
		case 246 :
			redComponent = 0.6666666666666666297;
			greenComponent = 0.6666666666666666297;
			blueComponent = 0.6666666666666666297;
			break;
		case 247 :
			redComponent = 0.6;
			greenComponent = 0.6;
			blueComponent = 0.6;
			break;
		case 248 :
			redComponent = 0.5333333333333333259;
			greenComponent = 0.5333333333333333259;
			blueComponent = 0.5333333333333333259;
			break;
		case 249 :
			redComponent = 0.4666666666666666741;
			greenComponent = 0.4666666666666666741;
			blueComponent = 0.4666666666666666741;
			break;
		case 250 :
			redComponent = 0.4;
			greenComponent = 0.4;
			blueComponent = 0.4;
			break;
		case 251 :
			redComponent = 0.3333333333333333148;
			greenComponent = 0.3333333333333333148;
			blueComponent = 0.3333333333333333148;
			break;
		case 252 :
			redComponent = 0.2509803921568627416;
			greenComponent = 0.2509803921568627416;
			blueComponent = 0.2509803921568627416;
			break;
		case 253 :
			redComponent = 0.2;
			greenComponent = 0.2;
			blueComponent = 0.2;
			break;
		case 254 :
			redComponent = 0.1333333333333333315;
			greenComponent = 0.1333333333333333315;
			blueComponent = 0.1333333333333333315;
			break;
		case 255 :
			redComponent = 0.06666666666666666574;
			greenComponent = 0.06666666666666666574;
			blueComponent = 0.06666666666666666574;
			break;
		default :
			redComponent = 0;
			greenComponent = 0;
			blueComponent = 0;
			break;
	}	
	
	//RGB -> BGR
	return [NSColor colorWithDeviceRed:blueComponent green:greenComponent blue:redComponent alpha:alphaComponent];
}

NSColor *getColorFromString(NSString *dictionary)
{
	NSColor *color = NULL; 
	if(dictionary)
	{
		CFPropertyListRef dictionaryPropertyList = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)[dictionary dataUsingEncoding:NSUTF8StringEncoding], kCFPropertyListImmutable, NULL);	
		
		if(dictionaryPropertyList)
		{		
			if(CFGetTypeID(dictionaryPropertyList) == CFDictionaryGetTypeID())
			{
				NSDictionary *dictionary = (NSDictionary *)dictionaryPropertyList;
				
				float redComponent = [[dictionary objectForKey:@"redComponent"]floatValue];
				float greenComponent = [[dictionary objectForKey:@"greenComponent"]floatValue];
				float blueComponent = [[dictionary objectForKey:@"blueComponent"]floatValue];
				float alphaComponent = [[dictionary objectForKey:@"alphaComponent"]floatValue];
							
				color = [NSColor colorWithDeviceRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];	
			}
			CFRelease(dictionaryPropertyList);
		}
	}
	
	return color;
	
}

NSString *copyColorString(NSColor *color)
{
	NSString *colorData = NULL; 
	
	if(color)
	{
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
		
		[dictionary setObject:[NSNumber numberWithFloat:[color redComponent]] forKey:@"redComponent"];
		[dictionary setObject:[NSNumber numberWithFloat:[color greenComponent]] forKey:@"greenComponent"];
		[dictionary setObject:[NSNumber numberWithFloat:[color blueComponent]] forKey:@"blueComponent"];
		[dictionary setObject:[NSNumber numberWithFloat:[color alphaComponent]] forKey:@"alphaComponent"];
		
		CFPropertyListRef dictionaryPropertyList = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)dictionary, kCFPropertyListImmutable);	
		NSData *dictionaryData = (NSData *)CFPropertyListCreateXMLData(kCFAllocatorDefault, dictionaryPropertyList);	
		
		colorData = [[NSString alloc]initWithData:dictionaryData encoding:NSUTF8StringEncoding];
		
		[dictionaryData release];
		CFRelease(dictionaryPropertyList);	
		[dictionary release];
	}else{colorData = @"";}
	
	return colorData;
	
}

NSString *copyAttendeesDictionary(NSArray *attendees)
{
	NSString *attendeesData = nil; 
	
	if(attendees)
	{
		CalAttendee *attendee = nil;
		
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
		NSMutableArray *array = [[NSMutableArray alloc]init];
		
		unsigned int i;
		
		for (i = 0; i < [attendees count]; i++) 
		{
			if([[attendees objectAtIndex:i]isMemberOfClass:[CalAttendee class]])
			{
				attendee = [attendees objectAtIndex:i];
				
				NSString *addressString = nil;
				if(attendee.address)
				{
					addressString = [attendee.address absoluteString];
				}else{
					addressString = @"";				
				}
				
				NSString *statusString = nil;
				if(attendee.status)
				{
					statusString = attendee.status;
				}else{
					statusString = @"";				
				}
				
				NSString *commonNameString = nil;
				if(attendee.commonName)
				{
					commonNameString = attendee.commonName;
				}else{
					commonNameString = @"";				
				}				
				
				NSDictionary *item = [NSDictionary 
									  dictionaryWithObjects:[NSArray arrayWithObjects:statusString, commonNameString, addressString, nil]
									  forKeys:[NSArray arrayWithObjects:@"status", @"commonName", @"address", nil]];
				
				[array addObject:item];							
				
			}
			
		}
		
		[dictionary setObject:array forKey:@"attendees"];
		
		CFPropertyListRef dictionaryPropertyList = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)dictionary, kCFPropertyListImmutable);	
		NSData *dictionaryData = (NSData *)CFPropertyListCreateXMLData(kCFAllocatorDefault, dictionaryPropertyList);
		
		attendeesData = [[NSString alloc]initWithData:dictionaryData encoding:NSUTF8StringEncoding];
		
		[dictionaryData release];
		CFRelease(dictionaryPropertyList);	
		
		[array release];
		[dictionary release];
		
	}else{attendeesData = @"";}
	
	return attendeesData;
}

NSString *copyDateTimeZoneString(PA_Date *date, int time, NSString *name)
{
	NSString *description = NULL;
	
	if(name)
	{
		NSTimeZone *zone = [NSTimeZone timeZoneWithName:name];
		if(!zone) zone = [NSTimeZone localTimeZone];
		
		CFGregorianDate gregDate;
		gregDate.year = date->fYear;
		gregDate.month = date->fMonth;
		gregDate.day = date->fDay;
		gregDate.hour = 0;
		gregDate.minute = 0;
		gregDate.second = 0;
		
		CFGregorianUnits offset;
		offset.years = 0;
		offset.months = 0;
		offset.days = 0;	
		offset.minutes = 0;
		offset.hours = 0;
		offset.seconds = time;
		
		if( CFGregorianDateIsValid( gregDate, kCFGregorianUnitsYears+kCFGregorianUnitsMonths+kCFGregorianUnitsDays))
		{
			CFAbsoluteTime at = CFGregorianDateGetAbsoluteTime(gregDate, (CFTimeZoneRef)zone);
			CFAbsoluteTime seconds = CFAbsoluteTimeAddGregorianUnits(at, (CFTimeZoneRef)zone, offset);		
			NSDate *nsd = (NSDate *)CFDateCreate(kCFAllocatorDefault, seconds);
			description = [[NSString alloc]initWithString:[nsd description]];		
			[nsd release];
		}
		
	}
	
	if(description) 
	{
		return description;
	}else{
		return @"";	
	}
	
}

void getDateTimeOffsetFromString(NSString *dateString, PA_Date *date, int *time, int *offset)
{		
	if(dateString)
	{
		NSDate *nsd = [NSDate dateWithString:dateString];
		if(nsd)
		{
			NSString *description = [nsd description];
			
			if([description length] == 25)
			{
				date->fYear = [[description substringWithRange:NSMakeRange(0,4)]integerValue];
				date->fMonth = [[description substringWithRange:NSMakeRange(5,2)]integerValue];
				date->fDay = [[description substringWithRange:NSMakeRange(8,2)]integerValue];		
				int hour = [[description substringWithRange:NSMakeRange(11,2)]integerValue]; 		
				int minute = [[description substringWithRange:NSMakeRange(14,2)]integerValue]; 
				int second = [[description substringWithRange:NSMakeRange(17,2)]integerValue]; 		
				*time = second + (minute * 60) + (hour * 3600);	
				NSTimeZone *zone = [NSTimeZone timeZoneWithName:[@"GMT" stringByAppendingString:[dateString substringWithRange:NSMakeRange(20,5)]]];
				if(zone) *offset = [zone secondsFromGMTForDate:nsd];
			}
		}
	}	
}
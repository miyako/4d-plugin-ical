#import "listener.h"

@implementation iCalListener

@synthesize insertedRecordsString;
@synthesize updatedRecordsString;
@synthesize deletedRecordsString;

- (void)setNotificationInfo:(NSNotification *)notification
{
	NSArray *insertedRecords	= [[notification userInfo]objectForKey:CalInsertedRecordsKey];
	NSArray *updatedRecords		= [[notification userInfo]objectForKey:CalUpdatedRecordsKey];
	NSArray *deletedRecords		= [[notification userInfo]objectForKey:CalDeletedRecordsKey];	
			
	unsigned int i;
	
	NSMutableString *_insertedRecords = [[NSMutableString alloc]init];
	NSMutableString *_updatedRecords= [[NSMutableString alloc]init];
	NSMutableString *_deletedRecords = [[NSMutableString alloc]init];
	
	if(insertedRecords){
		for(i = 0; i < [insertedRecords count]; i ++){			
			if(!i){
				[_insertedRecords setString:[insertedRecords objectAtIndex:i]];				
				 }else{
					 [_insertedRecords appendFormat:@"\r%@", [insertedRecords objectAtIndex:i]];
				 }			
		}
	}

	if(updatedRecords){
		for(i = 0; i < [updatedRecords count]; i ++){
			if(!i){
				[_updatedRecords setString:[updatedRecords objectAtIndex:i]];				
			}else{
				[_updatedRecords appendFormat:@"\r%@", [updatedRecords objectAtIndex:i]];
			}	
		}
	}
	
	if(deletedRecords){
		for(i = 0; i < [deletedRecords count]; i ++){
			if(!i){
				[_deletedRecords setString:[deletedRecords objectAtIndex:i]];				
			 }else{
				 [_deletedRecords appendFormat:@"\r%@", [deletedRecords objectAtIndex:i]];
			 }				
		}
	}
	
	self.insertedRecordsString = _insertedRecords;
	self.updatedRecordsString = _updatedRecords;
	self.deletedRecordsString = _deletedRecords;
	
	[_insertedRecords release];
	[_updatedRecords release];
	[_deletedRecords release];	
}

- (void)calendarsChanged:(NSNotification *)notification 
{
	[self setNotificationInfo:notification];
	self.notificationType = @"Calendar Notification";
	PA_UnfreezeProcess([self.listenerProcessNumber intValue]);	
}

- (void)eventsChanged:(NSNotification *)notification
{	
	[self setNotificationInfo:notification];	
	self.notificationType = @"Event Notification";
	PA_UnfreezeProcess([self.listenerProcessNumber intValue]);	
}

- (void)tasksChanged:(NSNotification *)notification
{
	[self setNotificationInfo:notification];	
	self.notificationType = @"Task Notification";
	PA_UnfreezeProcess([self.listenerProcessNumber intValue]);
}

@end
#import <Cocoa/Cocoa.h>
#import "PAListener.h"
#import <CalendarStore/CalendarStore.h>

@interface CalendarListener : PAListener
{
	NSString *insertedRecordsString;
	NSString *updatedRecordsString;
	NSString *deletedRecordsString;
}

- (void)setNotificationInfo:(NSNotification *)notification;
- (void)calendarsChanged:(NSNotification *)notification; 
- (void)eventsChanged:(NSNotification *)notification;
- (void)tasksChanged:(NSNotification *)notification; 

@property (nonatomic, retain) NSString *insertedRecordsString;
@property (nonatomic, retain) NSString *updatedRecordsString;
@property (nonatomic, retain) NSString *deletedRecordsString;

@end
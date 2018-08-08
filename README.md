4d-plugin-ical
==============

4D plugin to access Calendar.app data.

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|||

### Version

<img src="https://cloud.githubusercontent.com/assets/1725068/18940649/21945000-8645-11e6-86ed-4a0f800e5a73.png" width="32" height="32" /> <img src="https://cloud.githubusercontent.com/assets/1725068/18940648/2192ddba-8645-11e6-864d-6d5692d55717.png" width="32" height="32" /> <img src="https://user-images.githubusercontent.com/1725068/41266195-ddf767b2-6e30-11e8-9d6b-2adf6a9f57a5.png" width="32" height="32" />

### About v2 branch 

This branch  includes updates for 4D v15R5 and v16 (64 bits), as well as workarounds for El Capitan.

**Changes**:

* The minimum OS is now 10.7 for 32 bits, 10.8 for 64 bits. 

  Why? The code uses ``NSRegularExpression``, which is not in the 10.6 SDK, to find sqllite3 folders.

* The callback method signature has been changed.

  Why? Since OS 10.11 El Capitan, the ``CalendarStore``'s ``NSNotificationCenter`` notifications no longer returns the event ID. It simply tells what had happened (create, delete, modify), but not where. Note that this was always the case with the newer ``EventKit`` API. To preserve old behaviour, the plugin now uses ``FSEventStream`` to monitor changes to the backend ``sqllite3`` folders.

* The callback method is no longer called for task change events.

  Why?  management of tasks has been detached from the Calendar.app, and the notification no longer contains the task ID, which makes it pretty useless.

Previously:

| param | type | description |
|:------:|:-----:|:---------:|
| inserted | TEXT | event IDs separated by ``\r`` |
| updated | TEXT | event IDs separated by ``\r`` |
| deleted | TEXT | event IDs separated by ``\r`` |
| type | TEXT | ``Task Notification`` for task events, empty for calendar events |

Now:

| param | type | description |
|:------:|:-----:|:---------:|
| event | TEXT | event ID |
| type | LONGINT | ``0``:created, ``1``:updated, ``2``:deleted |

### Syntax

```
success:=iCal Set notification method (method)
success:=iCal Get notification method (method)
```

Parameter|Type|Description
------------|------------|----
method|TEXT|Callback method name
success|LONGINT|``1`` on success

```
success:=iCal Set event recurrence (event;kind;interval;endDate;daysOfWeek;weeksOfMonth;monthOfYear)
```

Parameter|Type|Description
------------|------------|----
event|TEXT|
kind|TEXT|``Daily``, ``Weekly``, ``Monthly``, ``Yearly``
interval|LONGINT|``1`` = every, ``2`` = every other, etc
endDate|TEXT|``""`` = no end
daysOfWeek|TEXT|csv
weeksOfMonth|TEXT|csv
monthOfYear|TEXT|csv

``iCal Set event property`` + ``Event recurrence`` does nothing; use dedicated command instead


```
success:=iCal Set event property (event;property;value)
success:=iCal Get event property (event;property;value)
```

Parameter|Type|Description
------------|------------|----
event|TEXT|
property|TEXT|
property|TEXT|

when ``Event recurrence`` is passed to ``iCal Get event property``, value is returned in JSON.

```
{
recurrenceInterval:number,
firstDayOfTheWeek:"" or "Monday" or "Tuesday" or...,
recurrenceType:"" or "Daily" or "Weekly" or "Monthly" or "Yearly",
recurrenceEnd:{occurrenceCount:number, endDate:"" or GMT},
daysOfTheWeek:[array or numbers],
daysOfTheMonth:[array or numbers],
nthWeekDaysOfTheMonth:[array or numbers],
monthsOfTheYear:[array or numbers]
}
```
 
## Commands

```
// --- Type Cast
iCal Make date
iCal GET DATE
iCal Make color
iCal GET COLOR
iCal Make color from index

// --- Timezone
iCal TIMEZONE LIST
iCal Get timezone info
iCal Get timezone for offset
iCal Get system timezone

// --- Task
iCal Create task
iCal Set task property
iCal Get task property
iCal Remove task
iCal Count task alarms
iCal Get task alarm
iCal Remove task alarm
iCal Set task alarm

// --- Event
iCal Create event
iCal Set event property
iCal Get event property
iCal Remove event
iCal Get event alarm
iCal Count event alarms
iCal Remove event alarm
iCal Set event alarm
iCal Set event properties

// --- Recurrence Rule
iCal Remove event recurrence
iCal Set event recurrence

// --- Calendar Store
iCal QUERY EVENT
iCal GET CALENDAR LIST
iCal QUERY TASK

// --- Calendar
iCal Create calendar
iCal Set calendar property
iCal Get calendar property
iCal Remove calendar

// --- Application
iCal TERMINATE
iCal LAUNCH

// --- iCal Direct
iCal SHOW EVENT(PA PluginParameters params);
iCal SHOW TASK(PA PluginParameters params);
iCal SET VIEW(PA PluginParameters params);
iCal SHOW DATE(PA PluginParameters params);

// --- Alarm
iCal Make alarm
iCal Get alarm property
iCal Set alarm property
iCal Add alarm to event
iCal Add alarm to task
```

### Remarks

This command internally use ``SBApplication``

``iCal SET VIEW``

These commands internally use ``NSAppleScript`` 

``iCal SHOW TASK``
``iCal SHOW DATE``
``iCal SHOW EVENT``

This commands internally use ``NSRunningApplication``

``iCal TERMINATE``

This commands internally use ``NSWorkspace``

``iCal LAUNCH``

These commands are deprecated; they do nothing

``iCal app Get task property``
``iCal app Get event property``

These commands internally start a new process; this is because the ``CalendarStore`` framework seems to return old values when a getter is called from the same thread that called its corresponding setter.

``iCal Get task property``
``iCal Count task alarms``
``iCal Get task alarm``
``iCal Get event property``
``iCal Get event alarm``
``iCal Count event alarms``
``iCal Get calendar property``
``iCal Get alarm property``

4d-plugin-ical
==============

4D plugin to access Calendar.app data.

##Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|🆗|🆗|🚫|🚫|

###Version

<img src="https://cloud.githubusercontent.com/assets/1725068/18940649/21945000-8645-11e6-86ed-4a0f800e5a73.png" width="32" height="32" /> <img src="https://cloud.githubusercontent.com/assets/1725068/18940648/2192ddba-8645-11e6-864d-6d5692d55717.png" width="32" height="32" />

###About v2 branch 

This branch  includes updates for 4D v15R5 and v16 (64 bits), as well as workarounds for El Capitan.

**Changes**:

The minimum OS is now 10.7 for 32 bits, 10.8 for 64 bits. 

The callback method signature has been changed.

Previously:

| param | type | description |
|:------:|:-----:|:---------:|
| inserted | TEXT | event IDs separated by ``\n`` |
| updated | TEXT | event IDs separated by ``\n`` |
| deleted | TEXT | event IDs separated by ``\n`` |
| notificationType | TEXT | not used |

Now:

| param | type | description |
|:------:|:-----:|:---------:|
| event | TEXT | event ID |
| notificationType | INT32 | ``0``:created, ``1``:updated, ``2``:deleted |

Commands
---

```c
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
iCal app Get task property
iCal app Get event property

// --- Alarm
iCal Make alarm
iCal Get alarm property
iCal Set alarm property
iCal Add alarm to event
iCal Add alarm to task
```

4d-plugin-ical
==============

4D plugin to access Calendar.app data.

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|||

### Version

<img src="https://cloud.githubusercontent.com/assets/1725068/18940649/21945000-8645-11e6-86ed-4a0f800e5a73.png" width="32" height="32" /> <img src="https://cloud.githubusercontent.com/assets/1725068/18940648/2192ddba-8645-11e6-864d-6d5692d55717.png" width="32" height="32" /> <img src="https://user-images.githubusercontent.com/1725068/41266195-ddf767b2-6e30-11e8-9d6b-2adf6a9f57a5.png" width="32" height="32" />

**Important**

Does not work since macOS Mojave!

### New syntax

```
calendars:=iCal Get calendars
```

Parameter|Type|Description
------------|------------|----
calendars|TEXT|JSON ``Is collection``. each item represents a calendar

```
timezones:=iCal Get timezones 
```

Parameter|Type|Description
------------|------------|----
timezones|TEXT|JSON ``Is collection``. each item represents a timezone

```
error:=iCal Add event(event)
```

Parameter|Type|Description
------------|------------|----
event|TEXT|JSON ``Is object``. ``startDate`` and ``endDate`` and ``calendar`` are mandatory
uid|TEXT|

```
error:=iCal Modify event(event{;date})
```

Parameter|Type|Description
------------|------------|----
event|TEXT|JSON ``Is object``. ``uid`` is mandatory
date|TEXT|speficy a single occurance of a recurring event
error|LONGINT|``0`` on success

```
event:=iCal Find event(event{;date})
```

Parameter|Type|Description
------------|------------|----
event|TEXT|JSON ``Is object``. ``uid`` is mandatory
date|TEXT|speficy a single occurance of a recurring event
event|TEXT|JSON ``Is object`` 

### Changed syntax

```
iCal SET NOTIFICATION METHOD (method)
method:=iCal Get notification method 
```

Parameter|Type|Description
------------|------------|----
method|TEXT|   

**Warning**: __Old syntax will crash instantly!__

* callback signature

| param | type | description |
|:------:|:-----:|:---------:|
| event | TEXT | event ID |
| type | LONGINT | ``0``:created, ``1``:updated, ``2``:deleted |

---

### Deprecated commands

#### Not thread safe => thread safe

* iCal Get event property => iCal Find event
* iCal Get task property => **deprecated**
* iCal Get calendar property => iCal Get calendars
* iCal Get alarm property => iCal Find event
* iCal Count event alarms => iCal Find event
* iCal Count task alarms => **deprecated**
* iCal Get task alarm => **deprecated**
* iCal Get event alarm => iCal Find event  

* iCal QUERY EVENT
* iCal QUERY TASK => **deprecated**  

* iCal TIMEZONE LIST => iCal Get timezones
* iCal GET CALENDAR LIST => iCal Get calendars
* iCal Create event => iCal Add event
* iCal Set event properties => iCal Modify event

* iCal app Get task property => **deprecated** 
* iCal app Get event property => iCal Find event

---

### TODO

support recurrence with 

* ~~iCal Find event~~ done
* iCal Modify event
* iCal Add event

create replacement for deprecated

* iCal QUERY EVENT

---

### Recurrence (deprecated)

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
 
---

### App control (updated)

These commands internally use ~~``NSAppleScript``~~ ``NSTask``

``iCal SHOW TASK``
``iCal SHOW EVENT``

These commands internally use ~~``NSAppleScript``~~ ``SBApplication``

``iCal SET VIEW``
``iCal SHOW DATE``

This command internally uses ``NSRunningApplication``

``iCal TERMINATE``

This command internally uses ``NSWorkspace``

``iCal LAUNCH``

Function get-Unixdate ($UnixDate) {
    [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate)) 
}

(get-Unixdate 1238025606).ToShortDateString() 













function record_flag(sd action,sd value)
    data flag#1
    if action==(value_set)
        set flag value
    else
        return flag
    endelse
endfunction

function record_event(sd action,sd value)
    data event#1
    if action==(value_set)
        set event value
    else
        return event
    endelse
endfunction


function record_file(sd action,sd value)
    data file#1
    if action==(value_set)
        set file value
    else
        return file
    endelse
endfunction

function record_hwavein(sd action,sd value)
    data hwavein#1
    if action==(value_set)
        set hwavein value
    else
        return hwavein
    endelse
endfunction


function record_buffers(sd action,sd value)
    data buffers#1
    if action==(value_set)
        set buffers value
    else
        return buffers
    endelse
endfunction

function channels_value(sd action,sd value)
    data channels=1
    if action==(value_set)
        set channels value
    else
        return channels
    endelse
endfunction
function rate_value(sd action,sd value)
    data rate=22050
    if action==(value_set)
        set rate value
    else
        return rate
    endelse
endfunction
function bps_value(sd action,sd value)
    data bps=16
    if action==(value_set)
        set bps value
    else
        return bps
    endelse
endfunction

function blockalign_value()
    sd value
    setcall value channels_value((value_get))
    multcall value bps_value((value_get))
    div value 8
    return value
endfunction
function avgbytespersec_value()
    sd value
    setcall value blockalign_value()
    multcall value rate_value((value_get))
    return value
endfunction

function BufferLength_value()
    sd value
    setcall value avgbytespersec_value()
    mult value 2
    return value
endfunction

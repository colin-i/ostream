



function errors(ss string)
    import "_printf" printf
    call printf(string)
    return 0
endfunction

#bool
function file_write(sd buffer,sd size,sd file)
    if size==0
        return 1
    endif
    sd sizewrote
    import "_fwrite" fwrite
    setcall sizewrote fwrite(buffer,1,size,file)
    if sizewrote!=0
        return 1
    endif
    str er="File write error."
    call errors(er)
    return 0
endfunction

#0/buffer
function alloc(sd size)
    import "_malloc" malloc
    sd buffer
    setcall buffer malloc(size)
    if buffer==0
        str er="Memory alloc error"
        call errors(er)
        return buffer
    endif
    return buffer
endfunction

#bool
import "_waveInPrepareHeader@12" waveInPrepareHeader
function wavein_prepare(sd hwavein,sd wavehdr)
    sd mm
    setcall mm waveInPrepareHeader(hwavein,wavehdr,(WAVEHDR_size))
    if mm!=(MMSYSERR_NOERROR)
        str er="WaveIn prepare header error"
        call errors(er)
        return 0
    endif
    return 1
endfunction

#bool
import "_waveInAddBuffer@12" waveInAddBuffer
function wavein_add(sd hwavein,sd wavehdr)
    sd mm
    setcall mm waveInAddBuffer(hwavein,wavehdr,(WAVEHDR_size))
    if mm!=(MMSYSERR_NOERROR)
        str er="WaveIn add buffer error"
        call errors(er)
        return 0
    endif
    return 1
endfunction

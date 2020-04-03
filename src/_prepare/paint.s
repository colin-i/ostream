



format elfobj

include "../_include/include.h"

function stage_redraw()
    import "drawwidget" drawwidget
    sd draw
    setcall draw drawwidget()
    import "widget_redraw" widget_redraw
    call widget_redraw(draw)
endfunction

#TRUE to stop other handlers from being invoked for the event. FALSE to propagate the event further.
function stage_paint_event(sd widget,sd *event,sd *data)
    import "get_playbool" get_playbool
    sd bool
    setcall bool get_playbool()
    #on gst play don't combine with stage
    if bool==(TRUE)
        return (FALSE)
    endif

    import "stage_get_sel_pixbuf_nowarning" stage_get_sel_pixbuf_nowarning
    sd px
    sd p_px^px
    sd err
    setcall err stage_get_sel_pixbuf_nowarning(p_px)
    if err==(noerror)
        import "widget_draw_pixbuf" widget_draw_pixbuf
        call widget_draw_pixbuf(widget,px)
    endif
    return (FALSE)
endfunction





format elfobj

include "../_include/include.h"

importx "_soup_session_sync_new" soup_session_sync_new
importx "_soup_message_new" soup_message_new
importx "_soup_session_send_message" soup_session_send_message


function getSessionMessageBody(sv sessionMsg,sv ptrmsgmem,sv ptrmsgsize,sd async)
#    GObject             parent
#All the fields in the GObject structure are private to the GObject implementation and should never be accessed directly.
#    const char         *method;

#    guint               status_code;
#    char               *reason_phrase;

#    SoupMessageBody    *request_body;
#    SoupMessageHeaders *request_headers;

#    SoupMessageBody    *response_body;
#    SoupMessageHeaders *response_headers;

	add sessionMsg (3+:)
	if async==(TRUE)
		sd statuscod
		set statuscod sessionMsg#d^
		if statuscod!=(HTTP_STATUS_OK)
			call uri_err(statuscod)
			return (error)
		endif
	endif
	add sessionMsg (3*:+DWORD)

	sd response_body#1
	set response_body sessionMsg#

#        const char *data;
#        goffset     length;  (gint64)
	set ptrmsgmem# response_body#
	data valuesize=4
	data greatest=8
	add response_body valuesize
	import "system_variables_alignment_pad" system_variables_alignment_pad
	addcall response_body system_variables_alignment_pad(valuesize,greatest)
	set ptrmsgsize# response_body#
	return (noerror)
endfunction

importx "_g_object_unref" g_object_unref
importx "_soup_session_queue_message" soup_session_queue_message

function uri_queue_content(ss uri,sd callback)
	sd session#1
	setcall session soup_session_sync_new()
	sd msg
	setcall msg soup_message_new("GET",uri)
	call soup_session_queue_message(session,msg,callback) #,(NULL)
	call g_object_unref(msg)
	call g_object_unref(session)
endfunction

function uri_err(sd status)
	vstr urierr="Error status code: "
	import "strvaluedisp" strvaluedisp
	data su=stringUinteger
	call strvaluedisp(urierr,status,su)
endfunction

#err
function uri_get_content(str uri,data ptrmsg,data ptrmsgmem,data ptrmsgsize)
    data session#1
    setcall session soup_session_sync_new()

    str get="GET"
    setcall ptrmsg# soup_message_new(get,uri)

    data ok=HTTP_STATUS_OK
    data status#1
    setcall status soup_session_send_message(session,ptrmsg#)
    if status!=ok
	call uri_err(status)
	return (error)
    endif

    call g_object_unref(session)

    call getSessionMessageBody(ptrmsg#,ptrmsgmem,ptrmsgsize,(FALSE))

    data noerr=noerror
    return noerr
endfunction


#v/e
function uri_get_content_forward_data(ss uri,sd forward,sd data)
#                        forward body and size
    data err#1
    data noerr=noerror
    sd msg
    sd body
    sd size
    sd ptrmsg^msg
    sd ptrbody^body
    sd ptrsize^size
    setcall err uri_get_content(uri,ptrmsg,ptrbody,ptrsize)
    if err!=noerr
        return err
    endif
    call forward(body,size,data)
    call g_object_unref(msg)
endfunction

#function uri_get_content_forward(ss uri,sd forward)
#    data null=0
#    call uri_get_content_forward_data(uri,forward,null)
#endfunction

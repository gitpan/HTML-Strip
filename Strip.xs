#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include "strip_html.h"

MODULE = HTML::Strip		PACKAGE = HTML::Strip		

PROTOTYPES: ENABLE

HTMLStripper *
create();
    CODE:
        RETVAL = new HTMLStripper();
    OUTPUT:
        RETVAL

void
HTMLStripper::DESTROY()

char *
HTMLStripper::strip_html( raw )
    INPUT:
        char *  raw

void
HTMLStripper::reset()

void
HTMLStripper::set_striptags(striptags)
    INPUT:
        SV * striptags
    INIT:
        I32 numstriptags = 0;
        int n;

        if( (!SvROK(striptags)) ||
            (SvTYPE(SvRV(striptags)) != SVt_PVAV) ||
            ((numstriptags = av_len((AV *)SvRV(striptags))) < 0) ) {
                XSRETURN_UNDEF;
        }
    CODE:
        THIS->clear_striptags();
        for (n = 0; n <= numstriptags; n++) {
            STRLEN l;
            char * striptag = SvPV(*av_fetch((AV *)SvRV(striptags), n, 0), l);
            THIS->add_striptag( striptag );
        }

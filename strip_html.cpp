
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "strip_html.h"

char *
HTMLStripper::strip_html( const char * raw ) {
  const char * p_raw = raw;
  const char * raw_end = raw + strlen(raw);
  char * output = new char[ strlen(raw) + 1 ];
  char * p_output = output;
    
  /* printf( "this->tagname = %s, this->striptag = %s, this->f_in_tag = %i, this->f_in_quote= %i, this->f_closing = %i, raw = %s\n", this->tagname, this->striptag, this->f_in_tag, this->f_in_quote, this->f_closing, raw ); */

  while( p_raw < raw_end ) {
    if( this->f_in_tag ) {
      /* inside a tag */
      /* check if we know either the tagname, or that we're in a declaration */
      if( !this->f_full_tagname && !this->f_in_decl ) {
        /* if this is the first character, check if it's a '!'; if so, we're in a declaration */
        if( this->p_tagname == this->tagname && *p_raw == '!' ) {
          this->f_in_decl = 1;
        }
        /* then check if the first character is a '/', in which case, this is a closing tag */
        else if( this->p_tagname == this->tagname && *p_raw == '/' ) {
          this->f_closing = 1;
        } else {
          /* if we don't have the full tag name yet, add current character unless it's whitespace, a '/', or a '>';
             otherwise null pad the string and set the full tagname flag, and check the tagname against stripped ones.
             also sanity check we haven't reached the array bounds, and truncate the tagname here if we have */
          if( (!isspace( *p_raw ) && *p_raw != '/' && *p_raw != '>') &&
              !( (this->p_tagname - this->tagname) == MAX_TAGNAMELENGTH ) ) {
            *this->p_tagname++ = *p_raw;
          } else {
            *this->p_tagname = 0;
            this->f_full_tagname = 1;
            /* if we're in a stripped tag block, and this is a closing tag, check to see if it ends the stripped block */
            if( this->f_in_striptag && this->f_closing ) {
              if( strcmp( this->tagname, this->striptag ) == 0 ) {
                this->f_in_striptag = 0;
              }
              /* if we're outside a stripped tag block, check tagname against stripped tag list */
            } else if( !this->f_in_striptag && !this->f_closing ) {
              int i;
              for( i = 0; i <= this->numstriptags; i++ ) {
                if( strcmp( this->tagname, this->striptags[i] ) == 0 ) {
                  this->f_in_striptag = 1;
                  strcpy( this->striptag, this->tagname );
                }
              }
            }
            check_end( *p_raw );
          }
        }
      } else {
        if( this->f_in_quote ) {
          /* inside a quote */
          /* end of quote if current character is the right quote character, and not preceeded by an odd number of escapes ('\') */
          if( *p_raw == this->quote && (this->quote_escapes & 1) != 1 ) {
            this->quote = 0;
            this->f_in_quote = 0;
          }
          /* check for escape characters */
          if( *p_raw == '\\' ) {
            this->quote_escapes++;
          } else {
            this->quote_escapes = 0;
          }
        } else {
          /* not in a quote */
          /* check for quote characters */
          if( *p_raw == '\'' || *p_raw == '\"' ) {
            this->f_in_quote = 1;
            this->quote = *p_raw;
            /* reset lastchar_* flags in case we have something perverse like '-"' or '/"' */
            this->f_lastchar_minus = 0;
            this->f_lastchar_slash = 0;
          } else {
            if( this->f_in_decl ) {
              /* inside a declaration */
              if( this->f_lastchar_minus ) {
                /* last character was a minus, so if current one is, then we're either entering or leaving a comment */
                if( *p_raw == '-' ) {
                  this->f_in_comment = !this->f_in_comment;
                }
                this->f_lastchar_minus = 0;
              } else {
                /* if current character is a minus, we might be starting a comment marker */
                if( *p_raw == '-' ) {
                  this->f_lastchar_minus = 1;
                }
              }
              if( !this->f_in_comment ) {
                check_end( *p_raw );
              }
            } else {
              check_end( *p_raw );
            }
          } /* quote character check */
        } /* in quote check */
      } /* full tagname check */
    }
    else {
      /* not in a tag */
      /* check for tag opening, and reset parameters if one has */
      if( *p_raw == '<' ) {
        this->f_in_tag = 1;
        this->tagname[0] = 0;
        this->p_tagname = this->tagname;
        this->f_full_tagname = 0;
        this->f_closing = 0;
        /* output a space in place of tags, and set a flag so we only do this once for every group of tags */
        if( !this->f_outputted_space ) {
          *p_output++ = ' ';
          this->f_outputted_space = 1;
        }
      } else {
        /* copy to stripped provided we're not in a stripped block */
        if( !this->f_in_striptag ) {
          *p_output++ = *p_raw;
          /* reset whitespace tag now we've outputted some text */
          this->f_outputted_space = 0;
        }
      }
    } /* in tag check */
    p_raw++;
  } /* while loop */

  *p_output = 0;
  return output;
  delete( output );
}

void
HTMLStripper::reset() {
  this->f_in_tag = 0;
  this->f_closing = 0;
  this->f_lastchar_slash = 0;
  this->f_full_tagname = 0;
  this->f_outputted_space = 1;
    
  this->f_in_quote = 0;
    
  this->f_in_decl = 0;
  this->f_in_comment = 0;
  this->f_lastchar_minus = 0;
    
  this->f_in_striptag = 0;
}

void
HTMLStripper::clear_striptags() {
  strcpy(this->striptags[0], "");
  this->numstriptags = 0;
}

void
HTMLStripper::add_striptag( char * striptag ) {
  if( numstriptags < MAX_STRIPTAGS-1 ) {
    strcpy(this->striptags[this->numstriptags++], striptag);
  } else {
    fprintf( stderr, "Cannot have more than %i strip tags", MAX_STRIPTAGS );
  }
}

void
HTMLStripper::check_end( char end ) {
  /* if current character is a slash, may be a closed tag */
  if( end == '/' ) {
    this->f_lastchar_slash = 1;
  } else {
    /* if the current character is a '>', then the tag has ended */
    if( end == '>' ) {
      this->f_in_quote = 0;
      this->f_in_comment = 0;
      this->f_in_decl = 0;
      this->f_in_tag = 0;
      /* we're not in a stripped tag block if the tag is a closed one, e.g. '<script src="foo" />' */
      if( this->f_lastchar_slash ) {
        this->f_in_striptag = 0;
      }
    }
    this->f_lastchar_slash = 0;
  }
}

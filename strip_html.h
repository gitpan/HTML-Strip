
#define MAX_TAGNAMELENGTH 20
#define MAX_STRIPTAGS 20

class HTMLStripper {

 public:

  HTMLStripper() {
    this->reset();
  };

  ~HTMLStripper() {};

  char *
    strip_html( const char * raw );
  
  void
    reset();
  
  void
    clear_striptags();

  void
    add_striptag( char * );

 private:

  int f_in_tag;
  int f_closing;
  int f_lastchar_slash;
  char tagname[MAX_TAGNAMELENGTH];
  char * p_tagname;
  char f_full_tagname;

  int f_outputted_space;

  int f_in_quote;
  char quote;
  int quote_escapes;

  int f_in_decl;
  int f_in_comment;
  int f_lastchar_minus;

  int f_in_striptag;
  char striptag[MAX_TAGNAMELENGTH];
  char striptags[MAX_STRIPTAGS][MAX_TAGNAMELENGTH];
  int numstriptags;

  void
    check_end( char end );
};

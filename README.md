# NAME

WWW::Pastebin::PastebinCom::API - implementation of pastebin.com API

# SYNOPSIS

    use WWW::Pastebin::PastebinCom::API;


    ##### Simple paste with all optional args at default values

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    print $bin->paste('Stuff to paste') || die "$bin";


    ##### Private paste with all optional args set

    $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    $bin->paste(
        'Stuff to paste',

        title => 'Title for your paste',
        private => 1,       # set paste as a private paste
        format => 'perl',   # Perl syntax highlighting
        expiry => 'awhile', # expire the paste after 1 week
    ) or die "$bin";

    print "$bin\n";


    ##### Retrieve the content of an existing paste

    $bin = WWW::Pastebin::PastebinCom::API->new;
    print $bin->get_paste('http://pastebin.com/YpTmWJG6')
        || die "$bin";


    ##### Delete one of user's private pastes

    $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    $bin->delete_paste('http://pastebin.com/YpTmWJG6')
        or die "$bin";


    ##### List trending pastes

    $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    my $trends = $bin->list_trends
        or die "$bin";

    use Data::Dumper;
    print Dumper $trends;


    ##### List user's private pastes

    $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    my $pastes = $bin->list_user_pastes
        or die "$bin";

    use Data::Dumper;
    print Dumper $pastes;


    ##### List user's info

    $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    my $info = $bin->get_user_info
        or die "$bin";

    use Data::Dumper;
    print Dumper $info;

# DESCRIPTION

This module is an implementation of the pastebin.com API
([http://pastebin.com/api](http://pastebin.com/api)). The API allows creation of public,
unlisted, and private pastes; deletion of private pastes;
listing of trending pastes and private pastes; and retrieval
of a paste's raw content (the last one is not part of the API, but
is nevertheless implemented in this module).

__NOTE ON GETTING PASTES:__ Despite tons of patently useless stuff
the API provides, it doesn't offer anything but the raw contents
of the paste (not even that, if we're to get technical). If your
main aim is to __retrieve__ pastes and/or retrieve info about
pastes (e.g. expiry date, highlight, etc), then this module will not
help you. See [WWW::Pastebin::PastebinCom::Retrieve](https://metacpan.org/pod/WWW::Pastebin::PastebinCom::Retrieve) for that task.

# API KEY NEEDED

The only method that doesn't require an API key is
`->get_paste()`. To use any other features of this module
you will need to obtain an
API key from pastebin.com. Simply create an account on pastebin.com,
login, then visit ([http://pastebin.com/api](http://pastebin.com/api)) and
the key will be listed somewhere in the second section on the page.
The key will look something like this:
`a3767061e0e64fef6c266126f7e588f4`.

# METHODS

## `new`

    # no API key
    my $bin = WWW::Pastebin::PastebinCom::API->new;

    # API key and setting timeout
    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key =>  'a3767061e0e64fef6c266126f7e588f4',
        user_key => '4fd751dc94f0b62c489b2c7720e0d240',
        timeout => 60,
    );

    # no API key and setting scustom UA
    my $bin = WWW::Pastebin::PastebinCom::API->new(
        ua => LWP::UserAgent->new(
            timeout => $args{timeout},
            agent   => 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:21.0)'
                        . ' Gecko/20100101 Firefox/21.0',
        )
    );

Creates and returns a new `WWW::Pastebin::PastebinCom::API` object.
All arguments are optional and are described below.

### `api_key`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key =>  'a3767061e0e64fef6c266126f7e588f4',
    );

__Optional__.
Takes pastebin.com's API key as a string.
By default is not specified.

You don't have to specify the key here and can use the
`->api_key()` accessor method instead, to set the key prior
to calling module methods.

The only method that doesn't require an API key is
`->get_paste()`. To use any other features of this module
you will need to obtain an
API key from pastebin.com. Simply create an account on pastebin.com,
login, then visit ([http://pastebin.com/api](http://pastebin.com/api)) and
the key will be listed somewhere in the second section on the page.
The key will look something like this:
`a3767061e0e64fef6c266126f7e588f4`.

### `user_key`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        user_key => '4fd751dc94f0b62c489b2c7720e0d240',
    );

__Optional__. Takes a user key string as a value. By default
is not specified.

To create, delete, or list private pastes, you will need a user key.
To obtain one, see `->get_user_key()` method. Pastebin.com's API
says these keys don't expire, so I would expect that you can
print one user key from `->get_user_key()`, then simply
reuse the same user key for your `WWW::Pastebin::PastebinCom::API`
scripts, just as you do with `api_key`. This would save making a
request to pastebin.com every time you need a user key.

### `timeout`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        timeout => 60,
    );

__Optional__. Takes a number that represents seconds.
__Default:__ 30.

Specifies the request timeout whenever making requests to
pastebin.com.

### `ua`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        ua => LWP::UserAgent->new(
            timeout => 30,
            agent   => 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:21.0)'
                        . ' Gecko/20100101 Firefox/21.0',
        )
    );

__Optional__. Takes an [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)-compatible object. That
object must implement `->post()` and `->get()` methods
that return the same stuff [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) returns.
__By default__ uses [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) with `timeout` set by
`timeout` constructor argument (see above) and `agent` set
to Firefox on Linux.

## `get_paste`

    my $bin = WWW::Pastebin::PastebinCom::API->new;
    print $bin->get_paste('http://pastebin.com/YpTmWJG6')
        || die "$bin";

    print $bin->get_paste('YpTmWJG6')
        || die "$bin";

    #### Get a private paste:
    print $bin->get_paste('YpTmWJG6', $USER, $PASS)
        || die "$bin";

Retrieves raw content of an existing paste.
__Takes__ one mandatory and two optional arguments.

The mandatory argument is a string that is either
a URL to the paste you want to retrieve or just the paste ID
(e.g. paste ID in "http://pastebin.com/YpTmWJG6" is "YpTmWJG6").
The two optional arguments must be provided together and they
are the login and the password to the pastebin.com account.
They must be provided when getting private pastes for that
account.

__On success returns__ the raw content of the paste.
__On failure returns__ either `undef` or an empty list, depending
on the context, and `->error()` method will contain
human-readable description of the error.

The use of this method doesn't require
you to have an API key with pastebin.com.

## `get_user_key`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

Obtains a user key from pastebin.com. This user key is required for
creating, deleting, and listing private user pastes. The API spec
says this key does not expire, so you should be able to reuse
one key for all your needs (see `user_key` argument for the
constructor). __Takes__ two mandatory arguments as
strings: first
one is your pastebin.com login, second one is your pastebin.com
password. __On success__ sets `->user_key()` accessor and
returns a user key (e.g. `4fd751dc94f0b62c489b2c7720e0d240`).
__On failure returns__ either `undef` or an empty list, depending
on the context, and `->error()` method will contain
human-readable description of the error. Note that
if `->get_user_key()` fails, then
`->user_key()` will be undefined, even if it was set
to something prior to the call of `->get_user_key()`

## `paste`

    ##### Simple paste with all optional args at default values

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    print $bin->paste('Stuff to paste') || die "$bin";


    ##### Make an unlisted paste

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    print $bin->paste( 'Stuff to paste', unlisted => 1, )
        || die "$bin";


    ##### Private paste with all optional args set

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    $bin->paste(
        'Stuff to paste',

        title => 'Title for your paste',
        private => 1,       # set paste as a private paste
        format => 'perl',   # Perl syntax highlighting
        expiry => 'awhile', # expire the paste after 1 week
    ) or die "$bin";

    print "$bin\n";

Creates a new paste on pastebin.com.
__On success__ sets `->paste_url()` accessor method
and returns a URL pointing to the newly-created paste.
__On failure returns__ either `undef` or an empty list, depending
on the context, and `->error()` method will contain
human-readable description of the error. Note that on failure,
`->paste_url()` will be undefined, even if it was set prior
to executing `->paste()`. __Takes__ one
mandatory argument as a string (paste content) and several optional
arguments as key/value pairs. Possible arguments are as follows:

### First argument

    print $bin->paste('Stuff to paste') || die "$bin";

__Mandatory__. Specifies the content of the paste.

### `title`

    $bin->paste(
        'Stuff to paste',
        title => 'Title for your paste',
    ) or die "$bin";

__Optional__. Specifies the title of the paste. __By default__ is
not specified and the paste will end up being called "Untitled."

### `expiry`

    $bin->paste(
        'Stuff to paste',
        expiry => 'asap',
    ) or die "$bin";

__Optional__. Specifies when the paste should expire.
__By default__ is not specified, so the paste will never expire.
__Takes__ a string as an argument. Case-insensitive. Along with
values specified by the API, several other aliases exist. Possible
values are as follows:

#### Expire in 10 Minutes

    10m
    m10
    asap

#### Expire in 1 Hour

    h
    1h

#### Expire in 1 Day

    d
    1d
    soon

#### Expire in 1 Week

    w
    1w
    awhile

#### Expire in 2 Weeks

    2w
    w2

#### Expire in 1 Month

    1m
    m1
    eventually

#### Never expire

    n
    never

### `format`

    $bin->paste(
        'Stuff to paste',
        format => 'perl',
    ) or die "$bin";

__Optional.__ Specifies syntax highlighting language. __Takes__
a string as a value, which specifies the language to use. Possible
values are (on the left is the value you'd use for `format`
and on the right is the explanation of what language it is):

                 4cs   # 4CS
            6502acme   # 6502 ACME Cross Assembler
         6502kickass   # 6502 Kick Assembler
            6502tasm   # 6502 TASM/64TASS
         68000devpac   # Motorola 68000 HiSoft Dev
                abap   # ABAP
        actionscript   # ActionScript
       actionscript3   # ActionScript 3
                 ada   # Ada
             algol68   # ALGOL 68
              apache   # Apache Log
         applescript   # AppleScript
         apt_sources   # APT Sources
                 arm   # ARM
                 asm   # ASM (NASM)
                 asp   # ASP
           asymptote   # Asymptote
            autoconf   # autoconf
          autohotkey   # Autohotkey
              autoit   # AutoIt
            avisynth   # Avisynth
                 awk   # Awk
           bascomavr   # BASCOM AVR
                bash   # Bash
            basic4gl   # Basic4GL
                  bf   # BrainFuck
              bibtex   # BibTeX
          blitzbasic   # Blitz Basic
                 bnf   # BNF
                 boo   # BOO
                   c   # C
        c_loadrunner   # C: Loadrunner
               c_mac   # C for Macs
              caddcl   # CAD DCL
             cadlisp   # CAD Lisp
                cfdg   # CFDG
                 cfm   # ColdFusion
          chaiscript   # ChaiScript
                 cil   # C Intermediate Language
             clojure   # Clojure
               cmake   # CMake
               cobol   # COBOL
        coffeescript   # CoffeeScript
                 cpp   # C++
              cpp-qt   # C++ (with QT extensions)
              csharp   # C#
                 css   # CSS
            cuesheet   # Cuesheet
                   d   # D
                 dcl   # DCL
              dcpu16   # DCPU-16
                 dcs   # DCS
              delphi   # Delphi
                diff   # Diff
                 div   # DIV
                 dos   # DOS
                 dot   # DOT
                   e   # E
          ecmascript   # ECMAScript
              eiffel   # Eiffel
               email   # Email
                 epc   # EPC
              erlang   # Erlang
                  f1   # Formula One
              falcon   # Falcon
                  fo   # FO Language
             fortran   # Fortran
           freebasic   # FreeBasic
          freeswitch   # FreeSWITCH
              fsharp   # F#
              gambas   # GAMBAS
                 gdb   # GDB
              genero   # Genero
               genie   # Genie
             gettext   # GetText
                glsl   # OpenGL Shading
                 gml   # Game Maker
             gnuplot   # Ruby Gnuplot
                  go   # Go
              groovy   # Groovy
             gwbasic   # GwBasic
             haskell   # Haskell
                haxe   # Haxe
              hicest   # HicEst
             hq9plus   # HQ9 Plus
         html4strict   # HTML
               html5   # HTML 5
                icon   # Icon
                 idl   # IDL
                 ini   # INI file
                inno   # Inno Script
            intercal   # INTERCAL
                  io   # IO
                   j   # J
                java   # Java
               java5   # Java 5
          javascript   # JavaScript
              jquery   # jQuery
             kixtart   # KiXtart
              klonec   # Clone C
            klonecpp   # Clone C++
               latex   # Latex
                  lb   # Liberty BASIC
                ldif   # LDIF
                lisp   # Lisp
                llvm   # LLVM
           locobasic   # Loco Basic
             logtalk   # Logtalk
             lolcode   # LOL Code
       lotusformulas   # Lotus Formulas
         lotusscript   # Lotus Script
             lscript   # LScript
                lsl2   # Linden Scripting
                 lua   # Lua
                m68k   # M68000 Assembler
             magiksf   # MagikSF
                make   # Make
            mapbasic   # MapBasic
              matlab   # MatLab
                mirc   # mIRC
                mmix   # MIX Assembler
             modula2   # Modula 2
             modula3   # Modula 3
               mpasm   # MPASM
                mxml   # MXML
               mysql   # MySQL
              nagios   # Nagios
             newlisp   # newLISP
                nsis   # NullSoft Installer
             oberon2   # Oberon 2
                objc   # Objective C
              objeck   # Objeck Programming Langua
               ocaml   # OCaml
         ocaml-brief   # OCalm Brief
              octave   # Octave
               oobas   # Openoffice BASIC
            oracle11   # Oracle 11
             oracle8   # Oracle 8
             oxygene   # Delphi Prism (Oxygene)
                  oz   # Oz
            parasail   # ParaSail
              parigp   # PARI/GP
              pascal   # Pascal
                pawn   # PAWN
                pcre   # PCRE
                 per   # Per
                perl   # Perl
               perl6   # Perl 6
                  pf   # OpenBSD PACKET FILTER
                 php   # PHP
           php-brief   # PHP Brief
               pic16   # Pic 16
                pike   # Pike
         pixelbender   # Pixel Bender
               plsql   # PL/SQL
          postgresql   # PostgreSQL
              povray   # POV-Ray
        powerbuilder   # PowerBuilder
          powershell   # Power Shell
             proftpd   # ProFTPd
            progress   # Progress
              prolog   # Prolog
          properties   # Properties
            providex   # ProvideX
           purebasic   # PureBasic
               pycon   # PyCon
               pys60   # Python for S60
              python   # Python
                   q   # q/kdb+
              qbasic   # QBasic
               rails   # Rails
               rebol   # REBOL
                 reg   # REG
                rexx   # Rexx
              robots   # Robots
             rpmspec   # RPM Spec
              rsplus   # R
                ruby   # Ruby
                 sas   # SAS
               scala   # Scala
              scheme   # Scheme
              scilab   # Scilab
            sdlbasic   # SdlBasic
           smalltalk   # Smalltalk
              smarty   # Smarty
               spark   # SPARK
              sparql   # SPARQL
                 sql   # SQL
         stonescript   # StoneScript
       systemverilog   # SystemVerilog
                 tcl   # TCL
            teraterm   # Tera Term
                text   # None
           thinbasic   # thinBasic
                tsql   # T-SQL
          typoscript   # TypoScript
              unicon   # Unicon
                 ups   # UPC
                urbi   # Urbi
             uscript   # UnrealScript
                vala   # Vala
                  vb   # VisualBasic
               vbnet   # VB.NET
               vedit   # Vedit
             verilog   # VeriLog
                vhdl   # VHDL
                 vim   # VIM
        visualfoxpro   # VisualFoxPro
        visualprolog   # Visual Pro Log
          whitespace   # WhiteSpace
               whois   # WHOIS
            winbatch   # Winbatch
              xbasic   # XBasic
                 xml   # XML
           xorg_conf   # Xorg Config
                 xpp   # XPP
                yaml   # YAML
                 z80   # Z80 Assembler
             zxbasic   # ZXBasic

### `unlisted`

    print $bin->paste( 'Stuff to paste', unlisted => 1, )
        || die "$bin";

__Optional.__ __Takes__ a true or false value. __When set to__
a true value, will cause the paste to be unlisted.
When used in conjunction with `private` option (see below)
the behaviour is undefined. __By default__ neither
`unlisted` nor `private` are specified and the created
paste is public and listed.

### `private`

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    print $bin->paste( 'Stuff to paste', private => 1, )
        || die "$bin";

__Optional.__ __Takes__ a true or false value.
__When set to__
a true value, will cause the paste to be private (viewable only
when the user is logged in).
When used in conjunction with `unlisted` option (see above)
the behaviour is undefined. __By default__ neither
`unlisted` nor `private` are specified and the created
paste is public and listed.

When creating a private
paste, `->user_key()`
accessor method must contain a user key for the user who will own
this paste. You can either set it directly using `->user_key()`,
set it in the constructor using `user_key` argument, or set it
indirectly by calling `->get_user_key()` method.

## `delete_paste`

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    $bin->delete_paste('http://pastebin.com/YpTmWJG6')
        or die "$bin";

    #### or
    $bin->delete_paste('YpTmWJG6')
        or die "$bin";

Deletes user's private paste (see `private` argument
to `->paste()`). __Takes__ one mandatory argument as a string
containing either the full URL to the paste to be deleted
or just the paste ID (e.g. `YpTmWJG6` is paste ID for
`http://pastebin.com/YpTmWJG6`).

The `->user_key()`
accessor method must contain a user key for the user who owns
this paste. You can either set it directly using `->user_key()`,
set it in the constructor using `user_key` argument, or set it
indirectly by calling `->get_user_key()` method.

## `list_user_pastes`

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    my $pastes = $bin->list_user_pastes(10) # get at most 10 pastes
        or die "$bin";

    use Data::Dumper;
    print Dumper $pastes;

Lists user's private pastes. Prior to calling `->list_user_pastes()`
`->user_key()` must be set, either
by calling `->get_user_key()`, using `->user_key()`
accessor method, or `user_key` constructor argument.
__Takes__ one optional argument as a
positive integer between 1 and 1000, which specifies the
maximum number of pastes to retrieve. __By default__ will get
at most 50 pastes. __On failure__ returns either
`undef` or an empty list, depending on the context, and the
`->error()` accessor method will contain human-readable
error message. __On success__ returns a — possibly empty — arrayref
or a list (depending on context) of hashrefs, where each hashref
represents information about a single paste. The format
of the hashref is this:

    {
        'key'           => 'zrke2Q9R',
        'url'           => 'http://pastebin.com/zrke2Q9R',
        'title'         => 'Title for your paste'
        'date'          => '1382901396',
        'expire_date'   => '1383506196',
        'format_short'  => 'perl',
        'format_long'   => 'Perl',
        'private'       => 1,
        'size'          => '14',
        'hits'          => '0',
    }

The API is not descriptive on what values these keys might have,
so what you have below is only my interpretation:

### `key`

        'key' => 'zrke2Q9R',

String of text. The paste ID of the paste. You can pass it to
`->delete_paste()` method to delete the paste.

### `url`

        'url' => 'http://pastebin.com/zrke2Q9R',

String of text. The URL of the paste.

### `title`

        'title' => 'Title for your paste'

String of text. The title of the paste.

### `date`

        'date' => '1382901396',

Unix time format. The date when the paste was created.

### `expire_date`

        'expire_date' => '1383506196',

Unix time format. The date when the paste will expire.

### `format_short`

        'format_short' => 'perl',

Syntax highlighting for the paste. See the left column in the
`format` argument for the `->paste()` method.

### `format_long`

        'format_long' => 'Perl',

Explanation of the code for the syntax highlighting for the paste.
See the right column in the `format` argument for
the `->paste()` method.

### `private`

        'private' => 1,

True value, if exists. An indication that it's a private paste.

### `unlisted`

        'unlisted' => 1,

True value, if exists. An indication that it's an unlisted paste.

### `size`

        'size' => '14',

Positive integer. The size of the paste, presumably the number
of characters.

### `hits`

        'hits' => '0',

Positive integer or zero. The number of times the paste was viewed.

## `list_trends`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    my $trends = $bin->list_trends
        or die "$bin";

    use Data::Dumper;
    print Dumper $trends;

Lists 18 trending pastes. __Takes__ no arguments.
__On failure__ returns either
`undef` or an empty list, depending on the context, and the
`->error()` accessor method will contain human-readable
error message. __On success__ returns an arrayref
or a list (depending on context) of hashrefs, where each hashref
represents information about a single paste. The format
of the hashref is the same as for hashrefs returned by the
`->list_user_pastes()` method (see above), except that
that `private`, `format_short`, and `format_long` keys
will not be there.

## `get_user_info`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    my $info = $bin->get_user_info
        or die "$bin";

    use Data::Dumper;
    print Dumper $info;

List user's account info. Prior to calling `->get_user_info()`
`->user_key()` must be set, either
by calling `->get_user_key()`, using `->user_key()`
accessor method, or `user_key` constructor argument. __Takes__
no arguments. __On failure__ returns either
`undef` or an empty list, depending on the context, and the
`->error()` accessor method will contain human-readable
error message. __On success__ either a hashref or a key/value list,
depending on the context. The format of the hashref is this:

    {
        'name' => 'zoffixisawesome',
        'website' => 'http://zoffix.com',
        'location' => 'Toronto',
        'format_short' => 'perl',
        'avatar_url' => 'http://pastebin.com/i/guest.gif',
        'private' => '1',  # also possible for this to be unlisted => 1 instead
        'email' => 'cpan@zoffix.com',
        'expiration' => 'N',
        'account_type' => '0'
    }

The API is not too descriptive about
the values of the user info, so what follows is my interpretation:

### `name`

    'name' => 'zoffixisawesome',

A string of text. User's login.

### `email`

    'email' => 'cpan@zoffix.com',

A string of text. User's email address.

### `website`

    'website' => 'http://zoffix.com',

A string of text. The website the user specified in their profile.

### `location`

    'location' => 'Toronto',

A string of text. User's location (specified by the user manually
by them in their profile).

### `format_short`

    'format_short' => 'perl',

This is the code for user's default syntax highlighting. See the left
column in the `format` argument to `->paste()` method.

### `avatar_url`

    'avatar_url' => 'http://pastebin.com/i/guest.gif',

A string of text. The URL to the user's avatar picture.

### `private` or `unlisted`

    'private' => '1',

    'unlisted' => '1',

True value, if exist. If `private` key is present, user's default
paste setting is to make the paste private. If `unlisted` key is
present, user's default paste setting is to make the paste unlisted.

### `expiration`

    'expiration' => 'N',

User's default expiry setting for their pastes. The values
you can possibly get here are these:

    N = Never
    10M = 10 Minutes
    1H = 1 Hour
    1D = 1 Day
    1W = 1 Week
    2W = 2 Weeks
    1M = 1 Month

### `account_type`

    'account_type' => '0',

0 or 1 as a value. Indicates user's account type. 0 means it's a normal;
1 means PRO.

# ACCESSOR METHODS

## `error`

    $bin->paste('Stuff') or die $bin->error;

    ### or

    $bin->paste('Stuff') or die "$bin";

__Takes__ no arguments. Returns the human-readable error message if
the last method failed.
This method is overloaded so you can call it by interpolating
the object in a string. The only difference is when interpolating,
the error message will be preceded with the word `Error:`. Note
that `->paste_url()` is also overloaded and the module will
interpolate the value of instead
`->paste_url()` if no error is set.

## `paste_url`

    $bin->paste('Stuff') or die "$bin";
    print $bin->paste_url;

    ### or

    $bin->paste('Stuff') or die "$bin";
    print "$bin"

__Takes__ no arguments. Returns the URL of the newly-created paste after
a successful call to `->paste()` method.
This method is overloaded so you can call it by interpolating
the object in a string. Note
that `->error()` is also overloaded and the module will
interpolate the value of `->error()` instead, if an error is set.

## `api_key`

    my $bin = WWW::Pastebin::PastebinCom::API->new;

    $bin->api_key('a3767061e0e64fef6c266126f7e588f4');
    printf "Current API key is %s\n", $bin->api_key;

__Takes__ one optional argument as a string, which is a pastebin.com's
API key to be used by the module. __Returns__ the currently used
API key, as a string.

## `user_key`

    my $bin = WWW::Pastebin::PastebinCom::API->new(
        api_key => 'a3767061e0e64fef6c266126f7e588f4',
    );

    $bin->get_user_key(qw/
        your_pastebin.com_login
        your_pastebin.com_password
    /) or die "$bin";

    printf "Current user key is %s\n", $bin->user_key;

__Takes__ one optional argument as a string, which is a
user key to be used by the module. __Returns__ the currently used
user key, as a string. See `->get_user_key()` for details
on what a user key is.

# OVERLOADS

    $bin->paste('Stuff') or die "$bin";
    print "$bin";

The `->error()` and `->paste_url()` methods are overloaded
so you can call them by interpolating the object in a string.
If `->error()` contains an error message it will be called
when the object is interpolated, otherwise `->paste_url()` will
be called. There's a slight difference between calling
`->error()` directly or through interpolation: when interpolated,
word `Error: ` is added to the error message.

# EXAMPLES

The `examples/` directory of this distribution contains two example
scripts: one for pasting a file and another for retrieving a paste.

# AUTHOR

Zoffix Znet, `<cpan at zoffix.com>`

# BUGS

Please report any bugs or feature requests to `bug-www-pastebin-pastebincom-api at rt.cpan.org`, or through
the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Pastebin-PastebinCom-API](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Pastebin-PastebinCom-API).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Pastebin::PastebinCom::API

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Pastebin-PastebinCom-API](http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Pastebin-PastebinCom-API)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/WWW-Pastebin-PastebinCom-API](http://annocpan.org/dist/WWW-Pastebin-PastebinCom-API)

- CPAN Ratings

    [http://cpanratings.perl.org/d/WWW-Pastebin-PastebinCom-API](http://cpanratings.perl.org/d/WWW-Pastebin-PastebinCom-API)

- Search CPAN

    [http://search.cpan.org/dist/WWW-Pastebin-PastebinCom-API/](http://search.cpan.org/dist/WWW-Pastebin-PastebinCom-API/)

# LICENSE AND COPYRIGHT

Copyright 2013 Zoffix Znet.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

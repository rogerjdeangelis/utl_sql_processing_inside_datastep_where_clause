# utl_sql_processing_inside_datastep_where_clause
Sql processing inside datastep where clause.  Keywords: sas sql join merge big data analytics macros oracle teradata mysql sas communities stackoverflow statistics artificial inteligence AI Python R Java Javascript WPS Matlab SPSS Scala Perl C C# Excel MS Access JSON graphics maps NLP natural language processing machine learning igraph DOSUBL DOW loop stackoverflow SAS community.
    SQL processing inside datastep where clause
    
    see recently added solution by Quentin McMullen via listserv.uga.edu

    see the nice recently added SQL solution by 
    Bartosz Jabłoński
    yabwon@gmail.com

    github
    https://github.com/rogerjdeangelis/utl_sql_processing_inside_datastep_where_clause


    PROBLEM
    =======

    Why can't I do the following

    data want;
      set sashelp.class
         (where = ( age < (select median(age) from sashelp.classfit) ) );
    run;quit;


    SOLUTION
    ========

    (Not sure I would put this in production until we get
     SAS to provide more documentation on DOSUBL)

    data want;

       set sashelp.class( where= ( age le
          %let rc= %sysfunc(dosubl(%nrstr(
           proc sql noprint;
             select
               median(age) into :mdlAge trimmed
             from
               sashelp.classfit
          )));
          &mdlAge
       ))

    ;run;quit;

    SUBSET DATASET
    ==============

    /*
    Up to 40 obs WORK.WANT total obs=10

    Obs    NAME       SEX    AGE    HEIGHT    WEIGHT

      1    Alice       F      13     56.5       84.0
      2    Barbara     F      13     65.3       98.0
      3    James       M      12     57.3       83.0
      4    Jane        F      12     59.8       84.5
      5    Jeffrey     M      13     62.5       84.0
      6    John        M      12     59.0       99.5
      7    Joyce       F      11     51.3       50.5
      8    Louise      F      12     56.3       77.0
      9    Robert      M      12     64.8      128.0
     10    Thomas      M      11     57.5       85.0
    */
  
  
  
  Bartosz Jabłoński
Bartosz Jabłoński's profile photo
yabwon@gmail.com
    
    
    Hi Roger,

I know it looks like I'm singing "the same old song", but I can't resist, sorry. :-) 

Why not to use: "Example 2: using an sql select statement as input to a data step" 
(end of page 5/ beginning of page 6) from "Use the Full Power of SAS in Your Function-Style Macros" by Mike Rhoads: https://support.sas.com/resources/papers/proceedings12/004-2012.pdf

all the best 
Bart

/*
%MACRO GetSQL() / PARMBUFF; 
 %let SYSPBUFF = %superq(SYSPBUFF); 
 %let SYSPBUFF = %substr(&SYSPBUFF,2,%LENGTH(&SYSPBUFF) - 2);
 %let SYSPBUFF = %superq(SYSPBUFF); 
 %let SYSPBUFF = %sysfunc(quote(&SYSPBUFF)); 

 %local UNIQUE_INDEX; 
   %let UNIQUE_INDEX = &SYSINDEX;
 %sysfunc(GetSQL(&UNIQUE_INDEX,&SYSPBUFF))
%MEND GetSQL;

options cmplib = _null_;
proc fcmp outlib=work.fun.test;
  function GetSQL(unique_index_2, query $) $ 41;

    length query query_arg $ 32000 viewname $ 41;
    query_arg = dequote(query);
    rc = RUN_MACRO('GetSQL_Inner', unique_index_2, query_arg, viewname);
    if rc = 0 then return(trim(viewname));
              else do;
                   return(" ");
                   put 'ERROR:[GetSQL] Problem with the function';
                   end;
  endsub;
run;

%MACRO GetSQL_Inner();
 %local query;
  %let query = %superq(query_arg); 
  %let query = %sysfunc(dequote(&query));
  %let viewname = GetSQL_tmpview_&UNIQUE_INDEX_2;
   proc sql;
    create view &viewname as &query;
   quit;
%MEND GetSQL_Inner; 



options cmplib = work.fun;

data example;
set 
%GetSQL(
select c.* from sashelp.class as c where c.age < (select median(age) from sashelp.class)
)
;
run; 
*/



Quentin McMullen via listserv.uga.edu
6:09 PM (15 hours ago)
to SAS-L
Hi Bart et al.,

Mike's Macro Function Sandwich paper is amazing, and it blew my mind when I read it
the first time.  But remember that when he came up with that nifty approach, there
was no DOSUBL. My vague memory is that when I emailed Mike a year or so after he
wrote it, to praise his paper and ask some follow-up questions, by then Rick Langston
had already given us an early DOSUBL, and Mike kin
dly pointed me in that direction since it makes life much easier.  See last example
from Rick's paper (https://www.lexjansen.com/nesug/nesug13/139_Final_Paper.pdf),
where he gives a DOSUBL approach to %ExpandVarList and compare that to Mike's MFS %ExpandVarList.

That said, the general approach Mike used in the MFS %GetSQL  is "function-style
macro that takes query as parameter, invokes a side-session to create a view of
that query, and returns the name of the view created."  It works fine with DOSUBL,
and much less code than the MFS approach:

%macro DoSublGetSQL(query);
  %local rc myview;
  %let myview=GetSQL_tmpview_&sysindex;

  %let rc=%sysfunc(dosubl(%nrstr(
     proc sql;
      create view &myview as &query;
     quit;
  )));

  &myview /*return the name of the view*/
%mend ;

Use like:

541  data example;
542    set %DoSublGetSql(select c.* from sashelp.class as c
543    where c.age < (select median(age) from sashelp.class));
MPRINT(DOSUBLGETSQL):   GetSQL_tmpview_55
543  run;


Kind Regards,
--Q.


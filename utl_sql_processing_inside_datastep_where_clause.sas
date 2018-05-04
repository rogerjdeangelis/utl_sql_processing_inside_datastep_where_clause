Sql processing inside datastep where clause

github
https://github.com/rogerjdeangelis/utl_sql_processing_inside_datastep_where_clause


see the nice recently added SQL solution by 
Bartosz Jabłoński
yabwon@gmail.com


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


Hi Roger,

I know it looks like I'm singing "the same old song", but I can't resist, sorry. :-) 

Why not to use: "Example 2: using an sql select statement as input to a data step" (end of page 5/ beginning of page 6) from "Use the Full Power of SAS in Your Function-Style Macros" by Mike Rhoads: https://support.sas.com/resources/papers/proceedings12/004-2012.pdf

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


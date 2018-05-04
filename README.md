# utl_sql_processing_inside_datastep_where_clause
Sql processing inside datastep where clause.  Keywords: sas sql join merge big data analytics macros oracle teradata mysql sas communities stackoverflow statistics artificial inteligence AI Python R Java Javascript WPS Matlab SPSS Scala Perl C C# Excel MS Access JSON graphics maps NLP natural language processing machine learning igraph DOSUBL DOW loop stackoverflow SAS community.
    SQL processing inside datastep where clause

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

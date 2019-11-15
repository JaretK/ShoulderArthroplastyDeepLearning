%let output_file_year=%scan(&sysparm,1);

*Func for adjusting for inflation by converting to 2014 USD;
proc fcmp outlib=sasuser.userfuncs.inflation;
    function adjust_for_inflation(year, usd);
        if year='2003' then return(usd*1.47);
        if year='2004' then return(usd*1.40);
        if year='2005' then return(usd*1.35);
        if year='2006' then return(usd*1.29);
        if year='2007' then return(usd*1.24);
        if year='2008' then return(usd*1.20);
        if year='2009' then return(usd*1.16);
        if year='2010' then return(usd*1.12);
        if year='2011' then return(usd*1.09);
        if year='2012' then return(usd*1.05);
        if year='2013' then return(usd*1.02);
        if year='2014' then return(usd*1.00);
    endsub;

/* filter by dx codes
 dx columns: dx1..dx30 (some years do not have all the dx codes) */
options cmplib=sasuser.userfuncs;
DATA jmknis;
    SET in.nis&output_file_year.;
    array d dx1-dx30; /*diagnosis codes, not used*/
    array p pr1-pr15; /*procedure codes*/
    array _c{3} $ 8 _temporary_ ('8181', '8180', '8188'); /*TSA proc codes*/

    * get procedure codes, 14 total;
    proc_partial_total_shoulder=0;
    proc_other_tsa=0;
    proc_reverse_tsa=0;

    if whichc('8181', of p(*)) > 0 then do;
        proc_partial_total_shoulder = 1;
    end;
    if whichc('8180', of p(*)) > 0 then do;
        proc_other_tsa = 1;
    end;
    if whichc('8188', of p(*)) > 0 then do;
        proc_reverse_tsa = 1;
    end;

    * adjust for inflation;
    totchg_2014_normalized = adjust_for_inflation(year,totchg);

    * record sum of procedures;
    _PROC_SUM = proc_partial_total_shoulder + proc_other_tsa + proc_reverse_tsa;

    * keep only rows with row sum;

    if _PROC_SUM > 0 then do;
        output;
    end;
run;

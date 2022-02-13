del ProceduresDDL.sql
del BaseTables.sql
del Tables.sql
del Functions.sql
del ViewsDDL.sql
del Views.sql
del Procedures.sql
del Triggers.sql
del Data.sql
del Reports.sql
del Terminology.sql

REM 07/26/2017 Paul.  Use binary flag to prevent EOF char. 
copy /b ProceduresDDL\*.0.sql      + ProceduresDDL\*.1.sql      + ProceduresDDL\*.2.sql    + ProceduresDDL\*.3.sql    + ProceduresDDL\*.4.sql    + ProceduresDDL\*.5.sql    + ProceduresDDL\*.6.sql    + ProceduresDDL\*.7.sql    + ProceduresDDL\*.8.sql    + ProceduresDDL\*.9.sql    ProceduresDDL.sql
copy /b BaseTables\*.0.sql         + BaseTables\*.1.sql         + BaseTables\*.2.sql       + BaseTables\*.3.sql       + BaseTables\*.4.sql       + BaseTables\*.5.sql       + BaseTables\*.6.sql       + BaseTables\*.7.sql       + BaseTables\*.8.sql       + BaseTables\*.9.sql       BaseTables.sql
copy /b Tables\*.0.sql             + Tables\*.1.sql             + Tables\*.2.sql           + Tables\*.3.sql           + Tables\*.4.sql           + Tables\*.5.sql           + Tables\*.6.sql           + Tables\*.7.sql           + Tables\*.8.sql           + Tables\*.9.sql           Tables.sql
copy /b Functions\*.0.sql          + Functions\*.1.sql          + Functions\*.2.sql        + Functions\*.3.sql        + Functions\*.4.sql        + Functions\*.5.sql        + Functions\*.6.sql        + Functions\*.7.sql        + Functions\*.8.sql        + Functions\*.9.sql        Functions.sql
copy /b ViewsDDL\*.0.sql           + ViewsDDL\*.1.sql           + ViewsDDL\*.2.sql         + ViewsDDL\*.3.sql         + ViewsDDL\*.4.sql         + ViewsDDL\*.5.sql         + ViewsDDL\*.6.sql         + ViewsDDL\*.7.sql         + ViewsDDL\*.8.sql         + ViewsDDL\*.9.sql         ViewsDDL.sql
copy /b Views\*.0.sql              + Views\*.1.sql              + Views\*.2.sql            + Views\*.3.sql            + Views\*.4.sql            + Views\*.5.sql            + Views\*.6.sql            + Views\*.7.sql            + Views\*.8.sql            + Views\*.9.sql            Views.sql
copy /b Procedures\*.0.sql         + Procedures\*.1.sql         + Procedures\*.2.sql       + Procedures\*.3.sql       + Procedures\*.4.sql       + Procedures\*.5.sql       + Procedures\*.6.sql       + Procedures\*.7.sql       + Procedures\*.8.sql       + Procedures\*.9.sql       Procedures.sql
copy /b Triggers\*.0.sql           + Triggers\*.1.sql           + Triggers\*.2.sql         + Triggers\*.3.sql         + Triggers\*.4.sql         + Triggers\*.5.sql         + Triggers\*.6.sql         + Triggers\*.7.sql         + Triggers\*.8.sql         + Triggers\*.9.sql         Triggers.sql
copy /b Data\*.0.sql               + Data\*.1.sql               + Data\*.2.sql             + Data\*.3.sql             + Data\*.4.sql             + Data\*.5.sql             + Data\*.6.sql             + Data\*.7.sql             + Data\*.8.sql             + Data\*.9.sql             Data.sql
copy /b Reports\*.0.sql            + Reports\*.1.sql            + Reports\*.2.sql          + Reports\*.3.sql          + Reports\*.4.sql          + Reports\*.5.sql          + Reports\*.6.sql          + Reports\*.7.sql          + Reports\*.8.sql          + Reports\*.9.sql          Reports.sql
copy /b Terminology\*.0.sql        + Terminology\*.1.sql        + Terminology\*.2.sql      + Terminology\*.3.sql      + Terminology\*.4.sql      + Terminology\*.5.sql      + Terminology\*.6.sql      + Terminology\*.7.sql      + Terminology\*.8.sql      + Terminology\*.9.sql      Terminology.sql

copy /b ProceduresDDL.sql + BaseTables.sql + Tables.sql + Functions.sql + ViewsDDL.sql + Views.sql + Procedures.sql + Triggers.sql + Data.sql + Reports.sql + Terminology.sql Build.sql

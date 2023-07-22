# SplendidCRM Community Edition
## Get Started

The quickest way to get started is to request our installer. The installer will do practically everything you need to get a Splendid App Builder site up and running, with the exception of installing SQL Server Express. Or, you can download the latest from GitHub and build the app yourself.

[Download Community Edition](http://www.splendidcrm.com/OpenSource/DownloadCommunityEdition.aspx "Download Community Edition")

## Minimum Requirements
1. Windows 10 or higher, Windows Server 2012 or higher.
2. ASP.NET Framework 4.8. Download [ASP.NET 4.8 Runtime](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48 "ASP.NET 4.8 Runtime")
3. Visual Studio 2017 or higher. Download [Visual Studio 2019](https://visualstudio.microsoft.com/downloads/ "Visual Studio 2019")
4. SQL Server Express 2008 or higher. Download [SQL Server Express 2019](https://www.microsoft.com/en-us/download/details.aspx?id=101064 "SQL Server Express 2019")
5. SQL Server Management Studio. Download [SQL Server Management Studio 18.10](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15 "SQL Server Management Studio 18.10")
6. Node version 16.20 for Windows 64-bit. Download [Node 16.20](https://nodejs.org/en/download/ "Node 16.20")
7. Yarn version 1.22. Download using npm: "npm install --global yarn"

## Using the Installer
The goal of the installer is to do everything necessary to get the system running on whatever version of windows you are running. We typically include SQL Server Express with the installer to save you that step, but if you already have SQL Server installed on your network, you can use the smaller Upgrade download. The app will do the following:
1. Install all files for the app. This action is performed by the typical InstallShield app.
2. Run SplendidCRM Configuration Wizard to configure Windows. This is where the real work is done.
3. Install IIS if not already installed.
4. Add IIS features that are required for the app.
5. Add SplendidApp application to IIS.
6. Connect to the database. SQL Server can be remote or local, all that is important is that you can connect. The installer includes an initialized database, which will be attached if an existing CRM database is not detected.
7. Create or update all tables, functions, views, procedures and/or data to run the app.
![InstallShield installer](https://www.splendidcrm.com/portals/0/SplendidCRM/Installation_InstallShield.gif "InstallShield installer")
![SplendidCRM Configuration Wizard](https://www.splendidcrm.com/portals/0/SplendidCRM/Installation_Wizard.gif "Splendid App Builder Configuration Wizard")

## Building Yourself
When building yourself, please note that we prefer to build the ASP.NET code separately from the React code. We do this so that Visual Studio does not take too long to debug as it will attempt to build both every time something small changes. So, we have marked the React files as content and excluded them from the build in the Visual Studio project file.  With this in mind, we have included two csproject files, one with the React files exluded from the project (_VS2013), and the other with the React included but as content (_VS2017).  This allows use to separate build from development.

### ASP.NET Web Site Build
Building should be as simple as loading the SplendidCRM7_VS2017.csproj project file into Visual Studio 2017 or higher. SplendidCRM uses very specific builds of certain external libraries so as to minimize version dependencies across libraries, we do not use package manager.  Instead, we have included a BackupBin2012 folder with those libraries.
1. AjaxControlToolkit.dll
2. Antlr3.Runtime.dll
3. BouncyCastle.Crypto.dll
4. CKEditor.NET.dll
5. Common.Logging.dll
6. DocumentFormat.OpenXml.dll
7. ICSharpCode.SharpZLib.dll
8. MailKit.dll
9. Microsoft.AspNet.SignalR.Core.dll
10. Microsoft.AspNet.SignalR.SystemWeb.dll
11. Microsoft.Owin.dll
12. Microsoft.Owin.Host.SystemWeb.dll
13. Microsoft.Owin.Security.dll
14. Microsoft.Web.Infrastructure.dll
15. MimeKit.dll
16. Newtonsoft.Json.dll
17. Owin.dll
18. RestSharp.dll
19. Spring.Rest.dll
20. Spring.Social.Core.dll
21. System.Web.Optimization.dll
22. TweetinCore.dll
23. Twilio.Api.dll
24. WebGrease.dll

### React Build
We recommend that you use yarn to bulid the React files. We are currently using version 1.22, npm version 6.14 adn node 16.20. These versions can be important as newer versions can have build failures. The first time you build, you will need to have yarn install all packages.

> yarn install

Then you can build the app.

> yarn build

The result will be the file React\dist\js\SteviaCRM.js

### SQL Build
The SQL Scripts folder contains all the code to create or update a database to the current level. The Build.bat file is designed to create a single Build.sql file that combines all the SQL code into a single Build.sql file. If this is the first time you are building the database, you will need to create the SQL database yourself and define a SQL user that has ownership access.
We have designed the SQL scripts to be run to upgrade any existing database to the current level. In addition, we designed the SQL scripts to be run over and over again, without any errors. We encourage you to continue this design. It includes data modifications that are designed to only be applied once. The basic logic is to check if the operation needs to occur before performing the acction.

> if ( condition to test ) begin -- then
>	operation to perform
> end -- if;

If you are wondering why we use "begin -- then" and "end -- if;" instead of simply "begin" and "end", it is so that we can more easily convert the code to support the Oracle PL/SQL format.

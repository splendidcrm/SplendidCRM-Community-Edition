# SplendidCRM Community Core
## Get Started

The quickest way to get started is to request our installer. The installer will do practically everything you need to get a SplendidCRM Community Core site up and running, with the exception of installing SQL Server Express. Or, you can download the latest from GitHub and build the app yourself.

You can also use Docker to get started.  We have provided a composer file that will create an instance of SQL Server 2022 to get you going quickly.

## Minimum Requirements
1. Windows 10 or higher, Windows Server 2016 or higher.
2. ASP.NET Core 5.0 Hosting Bundle. Download [ASP.NET Core 5.0](https://dotnet.microsoft.com/en-us/download/dotnet/5.0 "ASP.NET Core 5.0")
3. Visual Studio 2019 Community or higher. Download [Visual Studio 2019](https://visualstudio.microsoft.com/downloads/ "Visual Studio 2019")
4. SQL Server Express 2008 or higher. Download [SQL Server Express 2019](https://www.microsoft.com/en-us/download/details.aspx?id=101064 "SQL Server Express 2019")
5. SQL Server Management Studio. Download [SQL Server Management Studio 18.10](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15 "SQL Server Management Studio 18.10")
6. Node version 16.20 for Windows 64-bit. Download [Node 16.20](https://nodejs.org/en/download/ "Node 16.20")
7. Yarn version 1.22. Download using npm: "npm install --global yarn"

## Using Docker
We have added this core build to Docker Hub at [SplendidCRM Community on Docker](https://hub.docker.com/r/splendidcrm/community "SplendidCRM Community on Docker").

## Using the Installer
This is the same installer that we have been using for the last 15 years with our other SplendidCRM products. The goal of the installer is to do everything necessary to get the system running on whatever version of windows you are running. We typically include SQL Server Express with the installer to save you that step, but we have decided not to do that with this product. The app will do the following:
1. Install all files for the app. This action is performed by the typical InstallShield app.
2. Run SplendidCRM Configuration Wizard to configure Windows. This is where the real work is done.
3. Install IIS if not already installed.
4. Add IIS features that are required for the app.
5. Install ASP.NET 5.0 Hosting Bundle.
6. Add SplendidCRM application to IIS.
7. Connect to the database. SQL Server can be remote or local, all that is important is that you can connect. You are responsible for creating the database and providing a SQL user with sufficient ownership access to create SQL objects.
8. Create or update all tables, functions, views, procedures and/or data to run the app.
![InstallShield installer](https://www.splendidcrm.com/portals/0/SplendidAppBuilder/Installation_InstallShield.gif "InstallShield installer")
![Splendid App Builder Configuration Wizard](https://www.splendidcrm.com/portals/0/SplendidAppBuilder/Installation_Wizard.gif "Splendid App Builder Configuration Wizard")

## Building Yourself
When building yourself, please note that we prefer to build the ASP.NET code separately from the React code. We do this so that Visual Studio does not take too long to debug as it will attempt to build both every time something small changes. So, we have marked the React files as content and excluded them from the build in the Visual Studio project file.

### ASP.NET Web Site Build
Building should be as simple as loading the SplendidApp.csproj project file into Visual Studio 2019 or higher. If this is the first time you are building the app, then you will need to use the NuGet package manager to download all required packages. We don't use a lot of packages, the following is the current list:
1. Microsoft.AspNetCore.Authentication.Negotiate
2. Microsoft.AspNetCore.Authentication.OpenIdConnect
3. Microsoft.AspNetCore.SpaServices.Extensions
4. Microsoft.Identity.Web
5. System.Data.SqlClient
6. MailKit
7. SharpZipLib
8. DocumentFormat.OpenXml

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

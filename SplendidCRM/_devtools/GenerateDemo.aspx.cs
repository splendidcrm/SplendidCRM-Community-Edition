/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
using System;
using System.IO;
using System.Xml;
using System.Collections;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM._devtools
{
	/// <summary>
	/// Summary description for GenerateDemo.
	/// </summary>
	public class GenerateDemo : SplendidPage
	{
		protected Label lblError;
		#region Data
		private Random    ran                = new Random(9987);
		private int[]     arrDurationHours   = new int[] { 0, 1, 2, 3 };
		private int[]     arrDurationMinutes = new int[] { 0, 15, 30, 45 };
		private float[]   arrProbabilities   = new float[] { 10.0f, 70.0f, 40.0f, 60.0f };
		private decimal[] arrAmounts         = new decimal[] { 10000m, 25000m, 50000m, 75000m };
		private string[]  arrTopLevelDomains = new string[] { ".com", ".net", ".org", ".edu", ".info", ".us" };
		private string[]  arrEmailNames      = new string[] { "qa", "dev", "info", "support", "sales" };
		#region Case Names
		private string[] arrCaseNames       = new string[]
			{ "Having Trouble Plugging It In"
			, "System is Performing Too Fast"
			, "Need assistance with large customization"
			, "Need to Purchase Additional Licenses"
			, "Warning message when using the wrong browser"
			};
		#endregion
		#region Note Names
		private string[][] arrNoteNames     = new string[][]
			{ new string[] { "More Account Information", "This could turn into a 3,000 user opportunity" }
			, new string[] { "Call Information"        , "We had a call.  The call went well." }
			, new string[] { "Birthday Information"    , "The Owner was born in October" }
			, new string[] { "Holliday Gift"           , "The holliday gift was appreciated.  Put them on the list for next year as well." }
			};
		#endregion
		#region Call Names
		private string[] arrCallNames       = new string[]
			{ "Get More information on the proposed deal"
			, "Left a message"
			, "Bad time, will call back"
			, "Discuss Review Process"
			};
		#endregion
		#region Meeting Names
		private string[] arrMeetingNames    = new string[]
			{ "Follow-up on proposal"
			, "Initial discussion"
			, "Review needs"
			, "Discuss pricing"
			, "Demo"
			, "Introduce all players"
			};
		#endregion
		#region Task Names
		private string[] arrTaskNames       = new string[]
			{ "Assemble catalogs"
			, "Make travel arrangements"
			, "Send a letter"
			, "Send contract"
			, "Send fax"
			, "Send a follow-up letter"
			, "Send literature"
			, "Send proposal"
			, "Send quote"
			, "Call to schedule meeting"
			, "Setup evaluation"
			, "Get demo feedback"
			, "Arrange introduction"
			, "Escalate support request"
			, "Close out support request"
			, "Ship product"
			, "Arrange reference call"
			, "Schedule training"
			, "Send local user group information"
			, "Add to mailing list"
			};
		#endregion
		#region Email Subjects
		private string[] arrEmailSubjects   = new string[]
			{ "Follow-up on proposal"
			, "Initial discussion"
			, "Review needs"
			, "Discuss pricing"
			, "Demo"
			, "Introduce all players"
			};
		#endregion
		#region Bug Names
		private string[] arrBugNames        = new string[]
			{ "Error occurs while running count query"
			, "Warning is displayed in file after exporting"
			, "Fatal error during installation"
			, "Broken image appears in home page"
			, "Syntax error appears when running old reports"
			};
		#endregion
		#region Titles
		private string[] arrTitles          = new string[]
			{ "President"
			, "VP Operations"
			, "VP Sales"
			, "Director Operations"
			, "Director Sales"
			, "Mgr Operations"
			, "IT Developer"
			, "Senior Product Manager"
			};
		#endregion
		#region Account Names (FastGrowth)
		private string[] arrAccountNames    = new string[]
			{ "Abbott Laboratories"
			, "Aetna"
			, "Albertson's"
			, "Alcoa"
			, "Allstate"
			, "Altria Group"
			, "Amerada Hess"
			, "American Express"
			, "American Intl. Group"
			, "AmerisourceBergen"
			, "Archer Daniels Midland"
			, "AT&T"
			, "Bank of America Corp."
			, "Berkshire Hathaway"
			, "Best Buy"
			, "Boeing"
			, "Cardinal Health"
			, "Caremark Rx"
			, "Caterpillar"
			, "Chevron Corporation"
			, "Cisco Systems"
			, "Citigroup"
			, "Coca-Cola"
			, "Comcast"
			, "ConocoPhillips"
			, "Costco Wholesale"
			, "CVS"
			, "Deere"
			, "Dell"
			, "Delphi"
			, "Dow Chemical"
			, "DuPont"
			, "ExxonMobil Corporation"
			, "Federated Dept. Stores"
			, "FedEx"
			, "Ford Motor Company"
			, "General Dynamics"
			, "General Electric"
			, "General Motors Corporation"
			, "Goldman Sachs Group"
			, "Hartford Financial Services"
			, "HCA"
			, "Hewlett-Packard"
			, "Home Depot"
			, "Honeywell Intl."
			, "Ingram Micro"
			, "Intel"
			, "International Paper"
			, "Intl. Business Machines"
			, "J.P. Morgan Chase & Co."
			, "Johnson & Johnson"
			, "Johnson Controls"
			, "Kroger"
			, "Lehman Brothers"
			, "Lockheed Martin"
			, "Lowe's"
			, "Marathon Oil"
			, "Mass. Mutual Life Ins."
			, "McKesson"
			, "Medco Health Solutions"
			, "Merck"
			, "Merrill Lynch"
			, "MetLife"
			, "Microsoft"
			, "Morgan Stanley"
			, "Motorola"
			, "Nationwide"
			, "New York Life Insurance"
			, "News Corp."
			, "Northrop Grumman"
			, "PepsiCo"
			, "Pfizer"
			, "Plains All Amer. Pipeline"
			, "Procter & Gamble"
			, "Prudential Financial"
			, "Raytheon"
			, "Safeway"
			, "Sears Holdings"
			, "Sprint Nextel"
			, "St. Paul Travelers Cos."
			, "State Farm Insurance Cos"
			, "Sunoco"
			, "Sysco"
			, "Target"
			, "TIAA-CREF"
			, "Time Warner"
			, "Tyson Foods"
			, "United Parcel Service"
			, "United Technologies"
			, "UnitedHealth Group"
			, "Valero Energy"
			, "Verizon Communications"
			, "Wachovia Corp."
			, "Walgreen"
			, "Wal-Mart Stores, Inc."
			, "Walt Disney"
			, "Washington Mutual"
			, "Wellpoint"
			, "Wells Fargo"
			, "Weyerhaeuser"
			};
		#endregion
		#region Street Names (top 100)
		private string[] arrStreetNames = new string[]
			{ "1st Avenue"
			, "1st Street"
			, "2nd Avenue"
			, "2nd Street"
			, "3rd Avenue"
			, "3rd Street"
			, "4th Avenue"
			, "4th Street"
			, "5th Avenue"
			, "5th Street"
			, "11th Street"
			, "12th Street"
			, "13th Street"
			, "Academy Street"
			, "Adams Street"
			, "Andover Court"
			, "Arch Street"
			, "Ashley Court"
			, "Aspen Court"
			, "Beech Street"
			, "Belmont Avenue"
			, "Bridge Street"
			, "Bridle Lane"
			, "Broad Street"
			, "Brook Lane"
			, "Buckingham Drive"
			, "Buttonwood Drive"
			, "Cambridge Court"
			, "Cambridge Road"
			, "Canal Street"
			, "Canterbury Court"
			, "Cedar Avenue"
			, "Cedar Lane"
			, "Cedar Street"
			, "Center Street"
			, "Central Avenue"
			, "Cherry Lane"
			, "Cherry Street"
			, "Chestnut Street"
			, "Church Road"
			, "Church Street"
			, "Clinton Street"
			, "Cobblestone Court"
			, "College Avenue"
			, "Colonial Drive"
			, "Cottage Street"
			, "Court Street"
			, "Creek Road"
			, "Delaware Avenue"
			, "Devon Road"
			, "Devonshire Drive"
			, "Division Street"
			, "Dogwood Drive"
			, "Dogwood Lane"
			, "Durham Court"
			, "Durham Road"
			, "Eagle Road"
			, "East Street"
			, "Elizabeth Street"
			, "Elm Avenue"
			, "Elm Street"
			, "Elmwood Avenue"
			, "Essex Court"
			, "Fairview Avenue"
			, "Fairway Drive"
			, "Fawn Lane"
			, "Forest Drive"
			, "Franklin Avenue"
			, "Franklin Court"
			, "Franklin Street"
			, "Front Street"
			, "Front Street North"
			, "Garden Street"
			, "Garfield Avenue"
			, "George Street"
			, "Green Street"
			, "Grove Avenue"
			, "Grove Street"
			, "Hamilton Street"
			, "Heather Lane"
			, "Henry Street"
			, "Heritage Drive"
			, "Hickory Lane"
			, "High Street"
			, "Highland Avenue"
			, "Hillside Avenue"
			, "Hillside Drive"
			, "Holly Drive"
			, "Jackson Street"
			, "Jefferson Avenue"
			, "Jefferson Court"
			, "Jefferson Street"
			, "John Street"
			, "Lafayette Avenue"
			, "Lake Avenue"
			, "Lake Street"
			, "Lantern Lane"
			, "Laurel Drive"
			, "Laurel Lane"
			, "Liberty Street"
			, "Lilac Lane"
			, "Lincoln Avenue"
			, "Lincoln Street"
			, "Locust Lane"
			, "Locust Street"
			, "Madison Avenue"
			, "Madison Street"
			, "Magnolia Court"
			, "Main Street"
			, "Main Street East"
			, "Main Street North"
			, "Main Street South"
			, "Main Street West"
			, "Maple Avenue"
			, "Maple Street"
			, "Market Street"
			, "Meadow Lane"
			, "Mill Road"
			, "Mill Street"
			, "Mulberry Court"
			, "New Street"
			, "North Street"
			, "Oak Avenue"
			, "Oak Lane"
			, "Oak Street"
			, "Old York Road"
			, "Orchard Avenue"
			, "Oxford Court"
			, "Park Avenue"
			, "Park Place"
			, "Park Street"
			, "Pearl Street"
			, "Penn Street"
			, "Pennsylvania Avenue"
			, "Pheasant Run"
			, "Pin Oak Drive"
			, "Pine Street"
			, "Pleasant Street"
			, "Prospect Avenue"
			, "Prospect Street"
			, "Railroad Avenue"
			, "Railroad Street"
			, "Ridge Avenue"
			, "Ridge Road"
			, "River Road"
			, "River Street"
			, "Rosewood Drive"
			, "School Street"
			, "Sheffield Drive"
			, "Sherwood Drive"
			, "South Street"
			, "Spring Street"
			, "Spruce Street"
			, "State Street"
			, "Street Road"
			, "Summit Avenue"
			, "Sunset Drive"
			, "Surrey Lane"
			, "Tanglewood Drive"
			, "Union Street"
			, "Valley Road"
			, "Valley View Drive"
			, "Victoria Court"
			, "Vine Street"
			, "Walnut Avenue"
			, "Walnut Street"
			, "Washington Avenue"
			, "Washington Street"
			, "Water Street"
			, "West Street"
			, "Winding Way"
			, "Windsor Court"
			, "Windsor Drive"
			, "Woodland Avenue"
			, "Woodland Drive"
			, "Woodland Road"
			, "York Road"
			};
		#endregion
		#region City Names (US capitals)
		private string[] arrCityNames = new string[]
			{ "Albany"
			, "Annapolis"
			, "Atlanta"
			, "Augusta"
			, "Austin"
			, "Baton Rouge"
			, "Bismarck"
			, "Boise"
			, "Boston"
			, "Carson City"
			, "Charleston"
			, "Cheyenne"
			, "Columbia"
			, "Columbus"
			, "Concord"
			, "Denver"
			, "Des Moines"
			, "Dover"
			, "Frankfort"
			, "Harrisburg"
			, "Hartford"
			, "Helena"
			, "Honolulu"
			, "Indianapolis"
			, "Jackson"
			, "Jefferson City"
			, "Juneau"
			, "Lansing"
			, "Lincoln"
			, "Little Rock"
			, "Madison"
			, "Montgomery"
			, "Montpelier"
			, "Nashville"
			, "Oklahoma City"
			, "Olympia"
			, "Phoenix"
			, "Pierre"
			, "Providence"
			, "Raleigh"
			, "Richmond"
			, "Sacramento"
			, "Saint Paul"
			, "Salem"
			, "Salt Lake City"
			, "Santa Fe"
			, "Springfield"
			, "Tallahassee"
			, "Topeka"
			, "Trenton"
			};
		#endregion
		#region State Names (US)
		private string[] arrStateNames = new string[]
			{ "Alabama"
			, "Alaska"
			, "Arizona"
			, "Arkansas"
			, "California"
			, "Colorado"
			, "Connecticut"
			, "Delaware"
			, "Florida"
			, "Georgia"
			, "Hawaii"
			, "Idaho"
			, "Illinois"
			, "Indiana"
			, "Iowa"
			, "Kansas"
			, "Kentucky"
			, "Louisiana"
			, "Maine"
			, "Maryland"
			, "Massachusetts"
			, "Michigan"
			, "Minnesota"
			, "Mississippi"
			, "Missouri"
			, "Montana"
			, "Nebraska"
			, "Nevada"
			, "New Hampshire"
			, "New Jersey"
			, "New Mexico"
			, "New York"
			, "North Carolina"
			, "North Dakota"
			, "Ohio"
			, "Oklahoma"
			, "Oregon"
			, "Pennsylvania"
			, "Rhode Island"
			, "South Carolina"
			, "South Dakota"
			, "Tennessee"
			, "Texas"
			, "Utah"
			, "Vermont"
			, "Virginia"
			, "Washington"
			, "West Virginia"
			, "Wisconsin"
			, "Wyoming"
			, "American Samoa"
			, "District of Columbia"
			, "Federated States of Micronesia"
			, "Guam"
			, "Marshall Islands"
			, "Northern Mariana Islands"
			, "Palau"
			, "Puerto Rico"
			, "Virgin Islands"
			};
		private string[] arrStateAbbreviations = new string[]
			{ "AL"
			, "AK"
			, "AZ"
			, "AR"
			, "CA"
			, "CO"
			, "CT"
			, "DE"
			, "FL"
			, "GA"
			, "HI"
			, "ID"
			, "IL"
			, "IN"
			, "IA"
			, "KS"
			, "KY"
			, "LA"
			, "ME"
			, "MD"
			, "MA"
			, "MI"
			, "MN"
			, "MS"
			, "MO"
			, "MT"
			, "NE"
			, "NV"
			, "NH"
			, "NJ"
			, "NM"
			, "NY"
			, "NC"
			, "ND"
			, "OH"
			, "OK"
			, "OR"
			, "PA"
			, "RI"
			, "SC"
			, "SD"
			, "TN"
			, "TX"
			, "UT"
			, "VT"
			, "VA"
			, "WA"
			, "WV"
			, "WI"
			, "WY"
			, "AS"
			, "DC"
			, "FM"
			, "GU"
			, "MH"
			, "MP"
			, "PW"
			, "PR"
			, "VI"
			};

		#endregion
		#region First Names (top 100)
		private string[] arrFirstNames = new string[]
			{ "Adam"
			, "Ahmed"
			, "Alex"
			, "Ali"
			, "Amanda"
			, "Amy"
			, "Andrea"
			, "Andrew"
			, "Andy"
			, "Angela"
			, "Anna"
			, "Anne"
			, "Anthony"
			, "Antonio"
			, "Ashley"
			, "Barbara"
			, "Ben"
			, "Bill"
			, "Bob"
			, "Brian"
			, "Carlos"
			, "Carol"
			, "Chris"
			, "Christian"
			, "Christine"
			, "Cindy"
			, "Claudia"
			, "Dan"
			, "Daniel"
			, "Dave"
			, "David"
			, "Debbie"
			, "Elizabeth"
			, "Eric"
			, "Gary"
			, "George"
			, "Heather"
			, "Jack"
			, "James"
			, "Jason"
			, "Jean"
			, "Jeff"
			, "Jennifer"
			, "Jessica"
			, "Jim"
			, "Joe"
			, "John"
			, "Jonathan"
			, "Jose"
			, "Juan"
			, "Julie"
			, "Karen"
			, "Kelly"
			, "Kevin"
			, "Kim"
			, "Laura"
			, "Linda"
			, "Lisa"
			, "Luis"
			, "Marco"
			, "Maria"
			, "Marie"
			, "Mark"
			, "Martin"
			, "Mary"
			, "Matt"
			, "Matthew"
			, "Melissa"
			, "Michael"
			, "Michelle"
			, "Mike"
			, "Mohamed"
			, "Monica"
			, "Nancy"
			, "Nick"
			, "Nicole"
			, "Patricia"
			, "Patrick"
			, "Paul"
			, "Peter"
			, "Rachel"
			, "Richard"
			, "Robert"
			, "Ryan"
			, "Sam"
			, "Sandra"
			, "Sara"
			, "Sarah"
			, "Scott"
			, "Sharon"
			, "Stephanie"
			, "Stephen"
			, "Steve"
			, "Steven"
			, "Susan"
			, "Thomas"
			, "Tim"
			, "Tom"
			, "Tony"
			, "William"
			};
		#endregion
		#region Last Names (top 100)
		private string[] arrLastNames = new string[]
			{ "Adams"
			, "Alexander"
			, "Allen"
			, "Anderson"
			, "Bailey"
			, "Baker"
			, "Barnes"
			, "Bell"
			, "Bennett"
			, "Brooks"
			, "Brown"
			, "Bryant"
			, "Butler"
			, "Campbell"
			, "Carter"
			, "Clark"
			, "Coleman"
			, "Collins"
			, "Cook"
			, "Cooper"
			, "Cox"
			, "Davis"
			, "Diaz"
			, "Edwards"
			, "Evans"
			, "Flores"
			, "Foster"
			, "Garcia"
			, "Gonzales"
			, "Gonzalez"
			, "Gray"
			, "Green"
			, "Griffin"
			, "Hall"
			, "Harris"
			, "Hayes"
			, "Henderson"
			, "Hernandez"
			, "Hill"
			, "Howard"
			, "Hughes"
			, "Jackson"
			, "James"
			, "Jenkins"
			, "Johnson"
			, "Jones"
			, "Kelly"
			, "King"
			, "Lee"
			, "Lewis"
			, "Long"
			, "Lopez"
			, "Martin"
			, "Martinez"
			, "Miller"
			, "Mitchell"
			, "Moore"
			, "Morgan"
			, "Morris"
			, "Murphy"
			, "Nelson"
			, "Parker"
			, "Patterson"
			, "Perez"
			, "Perry"
			, "Peterson"
			, "Phillips"
			, "Powell"
			, "Price"
			, "Ramirez"
			, "Reed"
			, "Richardson"
			, "Rivera"
			, "Roberts"
			, "Robinson"
			, "Rodriguez"
			, "Rogers"
			, "Ross"
			, "Russell"
			, "Sanchez"
			, "Sanders"
			, "Scott"
			, "Simmons"
			, "Smith"
			, "Stewart"
			, "Taylor"
			, "Thomas"
			, "Thompson"
			, "Torres"
			, "Turner"
			, "Walker"
			, "Ward"
			, "Washington"
			, "Watson"
			, "White"
			, "Williams"
			, "Wilson"
			, "Wood"
			, "Wright"
			, "Young"
			};
		#endregion
		private string[] arrAccountIndustry;
		private string[] arrCasePriority   ;
		private string[] arrCaseStatus     ;
		private string[] arrBugPriority    ;
		private string[] arrBugStatus      ;
		private string[] arrLeadSource     ;
		private string[] arrLeadStatus     ;
		private string[] arrSalesStage     ;
		private string[] arrOpportunityType;
		private string[] arrTaskPriority   ;
		private string[] arrTaskStatus     ;
		private string[] arrMeetingStatus  ;
		#endregion

		#region Next methods
		class Account
		{
			public Guid   ID                     ;
			public Guid   ASSIGNED_USER_ID       ;
			public string NAME                   ;
			public string BILLING_ADDRESS_STATE  ;
			public Guid   OPPORTUNITY_ID         ;

			public Account(Guid ID, Guid ASSIGNED_USER_ID, string NAME, string BILLING_ADDRESS_STATE, Guid OPPORTUNITY_ID)
			{
				this.ID                    = ID                   ;
				this.ASSIGNED_USER_ID      = ASSIGNED_USER_ID     ;
				this.NAME                  = NAME                 ;
				this.BILLING_ADDRESS_STATE = BILLING_ADDRESS_STATE;
				this.OPPORTUNITY_ID        = OPPORTUNITY_ID       ;
			}
		};

		private string[] GetListArray(string sListName)
		{
			DataTable dt = SplendidCache.List(sListName);
			string[] arr = new string[dt.Rows.Count];
			for ( int i = 0; i < dt.Rows.Count; i++ )
				arr[i] = Sql.ToString(dt.Rows[i]["NAME"]);
			return arr;
		}

		protected int NextDurationHours()
		{
			return arrDurationHours[ran.Next(arrDurationHours.Length)];
		}

		protected int NextDurationMinutes()
		{
			return arrDurationMinutes[ran.Next(arrDurationMinutes.Length)];
		}

		protected string NextAccountName()
		{
			return arrAccountNames[ran.Next(arrAccountNames.Length)];
		}

		protected string NextStreetName()
		{
			return ran.Next(100, 1000).ToString() + " " + arrStreetNames[ran.Next(arrStreetNames.Length)];
		}

		protected string NextCityName()
		{
			return arrCityNames[ran.Next(arrCityNames.Length)];
		}

		protected string NextStateName()
		{
			return arrStateAbbreviations[ran.Next(arrStateAbbreviations.Length)];
		}

		protected string NextPostalCode()
		{
			return ran.Next(10000, 99999).ToString();
		}

		protected string NextFirstName()
		{
			return arrFirstNames[ran.Next(arrFirstNames.Length)];
		}

		protected string NextLastName()
		{
			return arrLastNames[ran.Next(arrLastNames.Length)];
		}

		protected string NextAccountIndustry()
		{
			if ( arrAccountIndustry == null )
			{
				arrAccountIndustry = GetListArray("industry_dom");
			}
			if ( arrAccountIndustry.Length > 0 )
				return arrAccountIndustry[ran.Next(arrAccountIndustry.Length)];
			return String.Empty;
		}

		protected string NextCaseName()
		{
			return arrCaseNames[ran.Next(arrCaseNames.Length)];
		}

		protected string NextCasePriority()
		{
			if ( arrCasePriority == null )
			{
				arrCasePriority = GetListArray("case_priority_dom");
			}
			if ( arrCasePriority.Length > 0 )
				return arrCasePriority[ran.Next(arrCasePriority.Length)];
			return String.Empty;
		}

		protected string NextCaseStatus()
		{
			if ( arrCaseStatus == null )
			{
				arrCaseStatus = GetListArray("case_status_dom");
			}
			if ( arrCaseStatus.Length > 0 )
				return arrCaseStatus[ran.Next(arrCaseStatus.Length)];
			return String.Empty;
		}

		protected string NextBugName()
		{
			return arrBugNames[ran.Next(arrBugNames.Length)];
		}

		protected string NextBugPriority()
		{
			if ( arrBugPriority == null )
			{
				arrBugPriority = GetListArray("bug_priority_dom");
			}
			if ( arrBugPriority.Length > 0 )
				return arrBugPriority[ran.Next(arrBugPriority.Length)];
			return String.Empty;
		}

		protected string NextBugStatus()
		{
			if ( arrBugStatus == null )
			{
				arrBugStatus = GetListArray("bug_status_dom");
			}
			if ( arrBugStatus.Length > 0 )
				return arrBugStatus[ran.Next(arrBugStatus.Length)];
			return String.Empty;
		}

		protected string NextLeadSource()
		{
			if ( arrLeadSource == null )
			{
				arrLeadSource = GetListArray("lead_source_dom");
			}
			if ( arrLeadSource.Length > 0 )
				return arrLeadSource[ran.Next(arrLeadSource.Length)];
			return String.Empty;
		}

		protected string NextLeadStatus()
		{
			if ( arrLeadStatus == null )
			{
				arrLeadStatus = GetListArray("lead_status_dom");
			}
			if ( arrLeadStatus.Length > 0 )
				return arrLeadStatus[ran.Next(arrLeadStatus.Length)];
			return String.Empty;
		}

		protected string NextSalesStage()
		{
			if ( arrSalesStage == null )
			{
				arrSalesStage = GetListArray("sales_stage_dom");
			}
			if ( arrSalesStage.Length > 0 )
				return arrSalesStage[ran.Next(arrSalesStage.Length)];
			return String.Empty;
		}

		protected string NextOpportunityType()
		{
			if ( arrOpportunityType == null )
			{
				arrOpportunityType = GetListArray("opportunity_type_dom");
			}
			if ( arrOpportunityType.Length > 0 )
				return arrOpportunityType[ran.Next(arrOpportunityType.Length)];
			return String.Empty;
		}

		protected string NextTaskName()
		{
			return arrTaskNames[ran.Next(arrTaskNames.Length)];
		}

		protected string NextTaskPriority()
		{
			if ( arrTaskPriority == null )
			{
				arrTaskPriority = GetListArray("task_priority_dom");
			}
			if ( arrTaskPriority.Length > 0 )
				return arrTaskPriority[ran.Next(arrTaskPriority.Length)];
			return String.Empty;
		}

		protected string NextTaskStatus()
		{
			if ( arrTaskStatus == null )
			{
				arrTaskStatus = GetListArray("task_status_dom");
			}
			if ( arrTaskStatus.Length > 0 )
				return arrTaskStatus[ran.Next(arrTaskStatus.Length)];
			return String.Empty;
		}

		protected string NextMeetingName()
		{
			return arrMeetingNames[ran.Next(arrMeetingNames.Length)];
		}

		protected string NextMeetingStatus()
		{
			if ( arrMeetingStatus == null )
			{
				arrMeetingStatus = GetListArray("meeting_status_dom");
			}
			if ( arrMeetingStatus.Length > 0 )
				return arrMeetingStatus[ran.Next(arrMeetingStatus.Length)];
			return String.Empty;
		}

		protected string NextCallName()
		{
			return arrCallNames[ran.Next(arrCallNames.Length)];
		}

		protected string NextEmailSubject()
		{
			return arrEmailSubjects[ran.Next(arrEmailSubjects.Length)];
		}

		protected string[] NextNoteName()
		{
			return arrNoteNames[ran.Next(arrNoteNames.Length)];
		}

		protected float NextProbability()
		{
			return arrProbabilities[ran.Next(arrProbabilities.Length)];
		}

		protected decimal NextAmount()
		{
			return arrAmounts[ran.Next(arrAmounts.Length)];
		}

		protected string NextTitle()
		{
			return arrTitles[ran.Next(arrTitles.Length)];
		}

		protected string NextPhoneNumber()
		{
			StringBuilder sb = new StringBuilder();
			sb.Append("(");
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(")");
			sb.Append(" ");
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append("-");
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(ran.Next(0, 9).ToString());
			sb.Append(ran.Next(0, 9).ToString());
			return sb.ToString();
		}

		protected DateTime NextDate()
		{
			DateTime dt = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
			dt = dt.AddDays   (ran.Next(0, 365));
			dt = dt.AddHours  (ran.Next(6,  19));
			dt = dt.AddMinutes(ran.Next(0,   3) * 15);
			return dt;
		}

		protected DateTime PastDate()
		{
			DateTime dt = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
			dt = dt.AddDays   (ran.Next(-365, -1));
			return dt;
		}

		protected string NextWebAddress()
		{
			return "www." + arrEmailNames[ran.Next(arrEmailNames.Length)] + arrEmailNames[ran.Next(arrEmailNames.Length)] + arrTopLevelDomains[ran.Next(arrTopLevelDomains.Length)];
		}

		protected string NextEmailAddress()
		{
			string sEmail = arrEmailNames[ran.Next(arrEmailNames.Length)] + ran.Next(10, 99).ToString();
			sEmail += "@example" + arrTopLevelDomains[ran.Next(arrTopLevelDomains.Length)];
			return sEmail;
		}

		protected string GetUserEmailAddress(Guid gUSER_ID)
		{
			string sEmail = String.Empty;
			switch ( gUSER_ID.ToString() )
			{
				case "00000000-0000-0000-0011-000000000000":  sEmail = "jim@example.com"  ;  break;
				case "00000000-0000-0000-0012-000000000000":  sEmail = "sarah@example.com";  break;
				case "00000000-0000-0000-0013-000000000000":  sEmail = "sally@example.com";  break;
				case "00000000-0000-0000-0014-000000000000":  sEmail = "tom@example.com"  ;  break;
				case "00000000-0000-0000-0015-000000000000":  sEmail = "will@example.com" ;  break;
				case "00000000-0000-0000-0016-000000000000":  sEmail = "chris@example.com";  break;
			}
			return sEmail;
		}

		protected string GetUserName(Guid gUSER_ID)
		{
			string sName = String.Empty;
			switch ( gUSER_ID.ToString() )
			{
				case "00000000-0000-0000-0011-000000000000":  sName = "Jim Brennan"  ;  break;
				case "00000000-0000-0000-0012-000000000000":  sName = "Sarah Smith"  ;  break;
				case "00000000-0000-0000-0013-000000000000":  sName = "Sally Bronsen";  break;
				case "00000000-0000-0000-0014-000000000000":  sName = "Max Jensen"   ;  break;
				case "00000000-0000-0000-0015-000000000000":  sName = "Will Westin"  ;  break;
				case "00000000-0000-0000-0016-000000000000":  sName = "Chris Olliver";  break;
			}
			return sName;
		}
		#endregion

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !SplendidCRM.Security.IS_ADMIN || Request.ServerVariables["SERVER_NAME"] != "localhost" )
			{
				lblError.Text = L10n.Term("ACL.LBL_NO_ACCESS");
				return;
			}
			
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					// 09/21/2010 Paul.  Save the previous authenticated user so that we can switch to the demo user for data creation. 
					Guid gLAST_USER_ID = Security.USER_ID;
					try
					{
						// 04/04/2017 Paul.  Assign demo data to a team. 
						Guid gDEMO_TEAM_ID  = new Guid("00000000-0000-0000-0003-000000000003");
						//Guid gJIM_ID        = new Guid("00000000-0000-0000-0001-000000000000");
						//Guid gMAX_ID        = new Guid("00000000-0000-0000-0002-000000000000");
						//Guid gWILL_ID       = new Guid("00000000-0000-0000-0003-000000000000");
						//Guid gCHRIS_ID      = new Guid("00000000-0000-0000-0004-000000000000");
						//Guid gSALLY_ID      = new Guid("00000000-0000-0000-0005-000000000000");
						//Guid gSARAH_ID      = new Guid("00000000-0000-0000-0006-000000000000");
						Guid gDEMO_ID       = new Guid("00000000-0000-0000-0000-000000000003");  // 00000000-0000-0000-0000-000000000002 is will on our demo site. 
						Guid gADMIN_ID      = new Guid("00000000-0000-0000-0000-000000000001");
						Guid gSEED_JIM_ID   = new Guid("00000000-0000-0000-0011-000000000000");
						Guid gSEED_MAX_ID   = new Guid("00000000-0000-0000-0012-000000000000");
						Guid gSEED_WILL_ID  = new Guid("00000000-0000-0000-0013-000000000000");
						Guid gSEED_CHRIS_ID = new Guid("00000000-0000-0000-0014-000000000000");
						Guid gSEED_SALLY_ID = new Guid("00000000-0000-0000-0015-000000000000");
						Guid gSEED_SARAH_ID = new Guid("00000000-0000-0000-0016-000000000000");
						
						// 09/21/2010 Paul.  All demo records should be created by the demo user. 
						Security.USER_ID = gDEMO_ID;
						XmlDocument xmlUSER_PREFERENCES = SplendidInit.InitUserPreferences("<xml></xml>");
						string sUSER_PREFERENCES = xmlUSER_PREFERENCES.OuterXml;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.Transaction = trn;
							// 05/11/2014 Paul.  Must use view as a tight security database may not provide access to base tables. 
							cmd.CommandText = "select count(*) from vwUSERS where ID = @ID";
							IDbDataParameter parID = Sql.AddParameter(cmd, "@ID", gADMIN_ID);
							// 09/21/2010 Paul.  Only update if the user does not exist.  This will prevent the password from getting overwritten. 
							// 03/25/2011 Paul.  Add support for Google Apps. 
							// 12/13/2011 Paul.  Add support for Apple iCloud. 
							parID.Value = gDEMO_ID;

							// 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
							string sDEFAULT_THEME       = Sql.ToString(Application["CONFIG.default_theme"      ]);
							string sDEFAULT_DATE_FORMAT = Sql.ToString(Application["CONFIG.default_date_format"]);
							string sDEFAULT_TIME_FORMAT = Sql.ToString(Application["CONFIG.default_time_format"]);
							string sDEFAULT_LANGUAGE    = Sql.ToString(Application["CONFIG.default_language"   ]);
							Guid   gDEFAULT_CURRENCY    = Sql.ToGuid  (Application["CONFIG.default_currency"   ]);
							Guid   gDEFAULT_TIMEZONE    = Sql.ToGuid  (Application["CONFIG.default_timezone"   ]);
							bool   bSAVE_QUERY          = true;
							bool   bGROUP_TABS          = false;
							bool   bSUBPANEL_TABS       = false;
							// 09/20/2013 Paul.  Move EXTENSION to the main table. 
							string sEXTENSION           = String.Empty;
							// 09/27/2013 Paul.  SMS messages need to be opt-in. 
							string   sSMS_OPT_IN        = String.Empty;
							// 11/21/2014 Paul.  Add User Picture. 
							// 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
							string   sPICTURE           = String.Empty;
							string   sMAIL_SMTPSERVER   = String.Empty;
							int      nMAIL_SMTPPORT     = 0;
							bool     bMAIL_SMTPAUTH_REQ = false;
							int      nMAIL_SMTPSSL      = 0;
							// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
							string   sMAIL_SENDTYPE     = String.Empty;
							if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
							{
								SqlProcs.spUSERS_Update(ref gDEMO_ID      , "demo" , ""     , "Demo"   , Guid.Empty    , false, false, String.Empty, String.Empty        , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty       , String.Empty, "Inactive", String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, sUSER_PREFERENCES, false, "Active", String.Empty, String.Empty, String.Empty, Guid.Empty, false, Guid.Empty, false, String.Empty, String.Empty, false, false, false, String.Empty, String.Empty, String.Empty, false, false, String.Empty, String.Empty, sDEFAULT_THEME, sDEFAULT_DATE_FORMAT, sDEFAULT_TIME_FORMAT, sDEFAULT_LANGUAGE, gDEFAULT_CURRENCY, gDEFAULT_TIMEZONE, bSAVE_QUERY, bGROUP_TABS, bSUBPANEL_TABS, sEXTENSION, sSMS_OPT_IN, sPICTURE, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, nMAIL_SMTPSSL, sMAIL_SENDTYPE, trn);
								SqlProcs.spUSERS_PasswordUpdate(gDEMO_ID      , Security.HashPassword("demo" ), trn);
							}
							parID.Value = gSEED_JIM_ID;
							if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
							{
								SqlProcs.spUSERS_Update(ref gSEED_JIM_ID  , "jim"  , "Jim"  , "Brennan", Guid.Empty    , false, false, String.Empty, "VP Sales"          , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, "jim@example.com"  , String.Empty, "Active"  , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, sUSER_PREFERENCES, false, "Active", String.Empty, String.Empty, String.Empty, Guid.Empty, false, Guid.Empty, false, String.Empty, String.Empty, false, false, false, String.Empty, String.Empty, String.Empty, false, false, String.Empty, String.Empty, sDEFAULT_THEME, sDEFAULT_DATE_FORMAT, sDEFAULT_TIME_FORMAT, sDEFAULT_LANGUAGE, gDEFAULT_CURRENCY, gDEFAULT_TIMEZONE, bSAVE_QUERY, bGROUP_TABS, bSUBPANEL_TABS, sEXTENSION, sSMS_OPT_IN, sPICTURE, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, nMAIL_SMTPSSL, sMAIL_SENDTYPE, trn);
								SqlProcs.spUSERS_PasswordUpdate(gSEED_JIM_ID  , Security.HashPassword("jim"  ), trn);
							}
							parID.Value = gSEED_SARAH_ID;
							if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
							{
								SqlProcs.spUSERS_Update(ref gSEED_SARAH_ID, "sarah", "Sarah", "Smith"  , gSEED_JIM_ID  , false, false, String.Empty, "Sales Manager West", String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, "sarah@example.com", String.Empty, "Active"  , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, sUSER_PREFERENCES, false, "Active", String.Empty, String.Empty, String.Empty, Guid.Empty, false, Guid.Empty, false, String.Empty, String.Empty, false, false, false, String.Empty, String.Empty, String.Empty, false, false, String.Empty, String.Empty, sDEFAULT_THEME, sDEFAULT_DATE_FORMAT, sDEFAULT_TIME_FORMAT, sDEFAULT_LANGUAGE, gDEFAULT_CURRENCY, gDEFAULT_TIMEZONE, bSAVE_QUERY, bGROUP_TABS, bSUBPANEL_TABS, sEXTENSION, sSMS_OPT_IN, sPICTURE, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, nMAIL_SMTPSSL, sMAIL_SENDTYPE, trn);
								SqlProcs.spUSERS_PasswordUpdate(gSEED_SARAH_ID, Security.HashPassword("sarah"), trn);
							}
							parID.Value = gSEED_SALLY_ID;
							if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
							{
								SqlProcs.spUSERS_Update(ref gSEED_SALLY_ID, "sally", "Sally", "Bronsen", gSEED_SARAH_ID, false, false, String.Empty, "Senior Account Rep", String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, "sally@example.com", String.Empty, "Active"  , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, sUSER_PREFERENCES, false, "Active", String.Empty, String.Empty, String.Empty, Guid.Empty, false, Guid.Empty, false, String.Empty, String.Empty, false, false, false, String.Empty, String.Empty, String.Empty, false, false, String.Empty, String.Empty, sDEFAULT_THEME, sDEFAULT_DATE_FORMAT, sDEFAULT_TIME_FORMAT, sDEFAULT_LANGUAGE, gDEFAULT_CURRENCY, gDEFAULT_TIMEZONE, bSAVE_QUERY, bGROUP_TABS, bSUBPANEL_TABS, sEXTENSION, sSMS_OPT_IN, sPICTURE, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, nMAIL_SMTPSSL, sMAIL_SENDTYPE, trn);
								SqlProcs.spUSERS_PasswordUpdate(gSEED_SALLY_ID, Security.HashPassword("sally"), trn);
							}
							parID.Value = gSEED_MAX_ID;
							if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
							{
								SqlProcs.spUSERS_Update(ref gSEED_MAX_ID  , "max"  , "Max"  , "Jensen" , gSEED_SARAH_ID, false, false, String.Empty, "Account Rep"       , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, "tom@example.com"  , String.Empty, "Active"  , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, sUSER_PREFERENCES, false, "Active", String.Empty, String.Empty, String.Empty, Guid.Empty, false, Guid.Empty, false, String.Empty, String.Empty, false, false, false, String.Empty, String.Empty, String.Empty, false, false, String.Empty, String.Empty, sDEFAULT_THEME, sDEFAULT_DATE_FORMAT, sDEFAULT_TIME_FORMAT, sDEFAULT_LANGUAGE, gDEFAULT_CURRENCY, gDEFAULT_TIMEZONE, bSAVE_QUERY, bGROUP_TABS, bSUBPANEL_TABS, sEXTENSION, sSMS_OPT_IN, sPICTURE, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, nMAIL_SMTPSSL, sMAIL_SENDTYPE, trn);
								SqlProcs.spUSERS_PasswordUpdate(gSEED_MAX_ID  , Security.HashPassword("max"  ), trn);
							}
							parID.Value = gSEED_WILL_ID;
							if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
							{
								SqlProcs.spUSERS_Update(ref gSEED_WILL_ID , "will" , "Will" , "Westin" , gSEED_JIM_ID  , false, false, String.Empty, "Sales Manager East", String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, "will@example.com" , String.Empty, "Active"  , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, sUSER_PREFERENCES, false, "Active", String.Empty, String.Empty, String.Empty, Guid.Empty, false, Guid.Empty, false, String.Empty, String.Empty, false, false, false, String.Empty, String.Empty, String.Empty, false, false, String.Empty, String.Empty, sDEFAULT_THEME, sDEFAULT_DATE_FORMAT, sDEFAULT_TIME_FORMAT, sDEFAULT_LANGUAGE, gDEFAULT_CURRENCY, gDEFAULT_TIMEZONE, bSAVE_QUERY, bGROUP_TABS, bSUBPANEL_TABS, sEXTENSION, sSMS_OPT_IN, sPICTURE, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, nMAIL_SMTPSSL, sMAIL_SENDTYPE, trn);
								SqlProcs.spUSERS_PasswordUpdate(gSEED_WILL_ID , Security.HashPassword("will" ), trn);
							}
							parID.Value = gSEED_CHRIS_ID;
							if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
							{
								SqlProcs.spUSERS_Update(ref gSEED_CHRIS_ID, "chris", "Chris", "Olliver", gSEED_WILL_ID , false, false, String.Empty, "Senior Account Rep", String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, "chris@example.com", String.Empty, "Active"  , String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, sUSER_PREFERENCES, false, "Active", String.Empty, String.Empty, String.Empty, Guid.Empty, false, Guid.Empty, false, String.Empty, String.Empty, false, false, false, String.Empty, String.Empty, String.Empty, false, false, String.Empty, String.Empty, sDEFAULT_THEME, sDEFAULT_DATE_FORMAT, sDEFAULT_TIME_FORMAT, sDEFAULT_LANGUAGE, gDEFAULT_CURRENCY, gDEFAULT_TIMEZONE, bSAVE_QUERY, bGROUP_TABS, bSUBPANEL_TABS, sEXTENSION, sSMS_OPT_IN, sPICTURE, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, nMAIL_SMTPSSL, sMAIL_SENDTYPE, trn);
								SqlProcs.spUSERS_PasswordUpdate(gSEED_CHRIS_ID, Security.HashPassword("chris"), trn);
							}
						}
						// 04/04/2017 Paul.  Assign demo data to a team. 
						try
						{
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.Transaction = trn;
								// 05/11/2014 Paul.  Must use view as a tight security database may not provide access to base tables. 
								cmd.CommandText = "select count(*) from vwTEAMS where ID = @ID";
								IDbDataParameter parID = Sql.AddParameter(cmd, "@ID", gDEMO_TEAM_ID);
								if ( Sql.ToInteger(cmd.ExecuteScalar()) == 0 )
								{
									SqlProcs.spTEAMS_InsertOnly(gDEMO_TEAM_ID, "Demo Team", String.Empty, trn);
									cmd.Parameters.Clear();
									cmd.CommandText = "update TEAMS"                     + ControlChars.CrLf
									                + "   set PARENT_ID = @DEMO_TEAM_ID" + ControlChars.CrLf
									                + " where ID in (select TEAM_ID from vwUSERS_Login where ID in " + ControlChars.CrLf
									                + "                ( @DEMO_ID      " + ControlChars.CrLf
									                + "                , @SEED_JIM_ID  " + ControlChars.CrLf
									                + "                , @SEED_MAX_ID  " + ControlChars.CrLf
									                + "                , @SEED_WILL_ID " + ControlChars.CrLf
									                + "                , @SEED_CHRIS_ID" + ControlChars.CrLf
									                + "                , @SEED_SALLY_ID" + ControlChars.CrLf
									                + "                , @SEED_SARAH_ID" + ControlChars.CrLf
									                + "                )"                + ControlChars.CrLf
									                + "             )"                   + ControlChars.CrLf;
									Sql.AddParameter(cmd, "@DEMO_TEAM_ID" , gDEMO_TEAM_ID );
									Sql.AddParameter(cmd, "@DEMO_ID"      , gDEMO_ID      );
									Sql.AddParameter(cmd, "@SEED_JIM_ID"  , gSEED_JIM_ID  );
									Sql.AddParameter(cmd, "@SEED_MAX_ID"  , gSEED_MAX_ID  );
									Sql.AddParameter(cmd, "@SEED_WILL_ID" , gSEED_WILL_ID );
									Sql.AddParameter(cmd, "@SEED_CHRIS_ID", gSEED_CHRIS_ID);
									Sql.AddParameter(cmd, "@SEED_SALLY_ID", gSEED_SALLY_ID);
									Sql.AddParameter(cmd, "@SEED_SARAH_ID", gSEED_SARAH_ID);
									cmd.ExecuteNonQuery();
								}
							}
						}
						catch
						{
						}

						// 04/30/2016 Paul.  Require the Application so that we can get the base currency. 
						Currency C10n = new Currency(Application);
						
						int nMaxAccounts =  50;
						int nMaxContacts = 200;
						int nMaxLeads    = 200;
#if DEBUG
						// 07/24/2011 Paul.  The tablet version will have less sample data. 
						if ( Request.ApplicationPath == "/EffiProz" )
						{
							nMaxAccounts = 25;
							nMaxContacts = 25;
							nMaxLeads    = 25;
						}
#endif
						Account[] arrAccounts = new Account[nMaxAccounts];
						for ( int i = 0; i < nMaxAccounts; i++ )
						{
							Guid gASSIGNED_USER_ID = gDEMO_ID;
							if ( i % 3 == 1 )
							{
								switch ( ran.Next(9, 10) )
								{
									case  9:  gASSIGNED_USER_ID = gSEED_WILL_ID ;  break;
									case 10:  gASSIGNED_USER_ID = gSEED_CHRIS_ID;  break;
								}
							}
							else
							{
								switch ( ran.Next(6, 8) )
								{
									case  6:  gASSIGNED_USER_ID = gSEED_SARAH_ID;  break;
									case  7:  gASSIGNED_USER_ID = gSEED_SALLY_ID;  break;
									case  8:  gASSIGNED_USER_ID = gSEED_MAX_ID  ;  break;
								}
							}
							Guid   gACCOUNT_ID                   = Guid.Empty;
							string sACCOUNT_NAME                 = NextAccountName();
							string sACCOUNT_TYPE                 = "Customer";
							Guid   gPARENT_ID                    = Guid.Empty;
							string sINDUSTRY                     = NextAccountIndustry();
							string sANNUAL_REVENUE               = String.Empty;
							string sPHONE_FAX                    = String.Empty;
							string sBILLING_ADDRESS_STREET       = NextStreetName();
							string sBILLING_ADDRESS_CITY         = NextCityName();
							string sBILLING_ADDRESS_STATE        = NextStateName();
							string sBILLING_ADDRESS_POSTALCODE   = NextPostalCode();
							string sBILLING_ADDRESS_COUNTRY      = "USA";
							string sDESCRIPTION                  = String.Empty;
							string sRATING                       = String.Empty;
							string sPHONE_OFFICE                 = NextPhoneNumber();
							string sPHONE_ALTERNATE              = String.Empty;
							string sEMAIL1                       = NextEmailAddress();
							string sEMAIL2                       = String.Empty;
							string sWEBSITE                      = NextWebAddress();
							string sOWNERSHIP                    = String.Empty;
							string sEMPLOYEES                    = String.Empty;
							string sSIC_CODE                     = String.Empty;
							string sTICKER_SYMBOL                = String.Empty;
							string sSHIPPING_ADDRESS_STREET      = sBILLING_ADDRESS_STREET    ;
							string sSHIPPING_ADDRESS_CITY        = sBILLING_ADDRESS_CITY      ;
							string sSHIPPING_ADDRESS_STATE       = sBILLING_ADDRESS_STATE     ;
							string sSHIPPING_ADDRESS_POSTALCODE  = sBILLING_ADDRESS_POSTALCODE;
							string sSHIPPING_ADDRESS_COUNTRY     = sBILLING_ADDRESS_COUNTRY   ;
							string sACCOUNT_NUMBER               = String.Empty;
							// 04/04/2017 Paul.  Assign demo data to a team. 
							Guid   gTEAM_ID                      = gDEMO_TEAM_ID;
							string sTEAM_SET_LIST                = String.Empty;
							bool   bEXCHANGE_FOLDER              = false;
							string sTYPE                         = String.Empty;
							string sWORK_LOG                     = String.Empty;
							SqlProcs.spACCOUNTS_Update
								( ref gACCOUNT_ID              
								, gASSIGNED_USER_ID            
								, sACCOUNT_NAME                
								, sACCOUNT_TYPE                
								, gPARENT_ID                   
								, sINDUSTRY                    
								, sANNUAL_REVENUE              
								, sPHONE_FAX                   
								, sBILLING_ADDRESS_STREET      
								, sBILLING_ADDRESS_CITY        
								, sBILLING_ADDRESS_STATE       
								, sBILLING_ADDRESS_POSTALCODE  
								, sBILLING_ADDRESS_COUNTRY     
								, sDESCRIPTION                 
								, sRATING                      
								, sPHONE_OFFICE                
								, sPHONE_ALTERNATE             
								, sEMAIL1                      
								, sEMAIL2                      
								, sWEBSITE                     
								, sOWNERSHIP                   
								, sEMPLOYEES                   
								, sSIC_CODE                    
								, sTICKER_SYMBOL               
								, sSHIPPING_ADDRESS_STREET     
								, sSHIPPING_ADDRESS_CITY       
								, sSHIPPING_ADDRESS_STATE      
								, sSHIPPING_ADDRESS_POSTALCODE 
								, sSHIPPING_ADDRESS_COUNTRY    
								, sACCOUNT_NUMBER              
								, gTEAM_ID                     
								, sTEAM_SET_LIST               
								, bEXCHANGE_FOLDER             
								// 08/07/2015 Paul.  Add picture. 
								, String.Empty  // PICTURE
								// 05/12/2016 Paul.  Add Tags module. 
								, "demo"        // TAG_SET_NAME
								// 06/07/2017 Paul.  Add NAICSCodes module. 
								, String.Empty  // NAICS_SET_NAME
								// 10/27/2017 Paul.  Add Accounts as email source. 
								, false         // DO_NOT_CALL
								, false         // EMAIL_OPT_OUT
								, false         // INVALID_EMAIL
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								, trn
								);
							Guid gCASE_ID = Guid.Empty;
							// 04/02/2012 Paul.  Add TYPE and WORK_LOG. 
							// 05/01/2013 Paul.  Add Contacts field to support B2C. 
							SqlProcs.spCASES_Update
								( ref gCASE_ID
								, gASSIGNED_USER_ID
								, NextCaseName()
								, sACCOUNT_NAME
								, gACCOUNT_ID
								, NextCaseStatus()
								, NextCasePriority()
								, String.Empty
								, String.Empty
								, String.Empty
								, Guid.Empty
								, String.Empty
								, gTEAM_ID
								, sTEAM_SET_LIST
								, bEXCHANGE_FOLDER
								, sTYPE
								, sWORK_LOG
								, Guid.Empty    // B2C_CONTACT_ID
								// 05/12/2016 Paul.  Add Tags module. 
								, "demo"        // TAG_SET_NAME
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								, trn
								);
							Guid gBUG_ID = Guid.Empty;
							SqlProcs.spBUGS_Update
								( ref gBUG_ID
								, gASSIGNED_USER_ID
								, NextBugName()
								, NextBugStatus()
								, NextBugPriority()
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, Guid.Empty
								, String.Empty
								, gTEAM_ID
								, sTEAM_SET_LIST
								, bEXCHANGE_FOLDER
								// 05/12/2016 Paul.  Add Tags module. 
								, "demo"        // TAG_SET_NAME
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								, trn
								);
							Guid gNOTE_ID = Guid.Empty;
							string[] arrNOTE = NextNoteName();
							// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
							SqlProcs.spNOTES_Update
								( ref gNOTE_ID
								, arrNOTE[0]
								, "Accounts"
								, gACCOUNT_ID
								, Guid.Empty
								, arrNOTE[1]
								, gTEAM_ID
								, sTEAM_SET_LIST
								, gASSIGNED_USER_ID
								// 05/17/2017 Paul.  Add Tags module. 
								, String.Empty  // TAG_SET_NAME
								// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
								, false         // IS_PRIVATE
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								, trn
								);
							Guid gCALL_ID = Guid.Empty;
							// 12/26/2012 Paul.  Add EMAIL_REMINDER_TIME. 
							// 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
							// 03/20/2013 Paul.  Add REPEAT fields. 
							// 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
							// 09/14/2015 Paul.  Default for reminders should be 0. 
							SqlProcs.spCALLS_Update
								( ref gCALL_ID
								, gASSIGNED_USER_ID
								, NextCallName()
								, 0
								, 30
								, NextDate()
								, "Accounts"
								, gACCOUNT_ID
								, "Planned"
								, "Outbound"
								, 0                 // REMINDER_TIME
								, String.Empty
								, String.Empty
								, gTEAM_ID
								, sTEAM_SET_LIST
								, 0                 // EMAIL_REMINDER_TIME
								, false             // ALL_DAY_EVENT
								, String.Empty      // REPEAT_TYPE
								, 0                 // REPEAT_INTERVAL
								, String.Empty      // REPEAT_DOW
								, DateTime.MinValue // REPEAT_UNTIL
								, 0                 // REPEAT_COUNT
								, 0                 // SMS_REMINDER_TIME
								// 05/17/2017 Paul.  Add Tags module. 
								, String.Empty      // TAG_SET_NAME
								// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
								, false             // IS_PRIVATE
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty      // ASSIGNED_SET_LIST
								, trn
								);
							Guid gOPPORTUNITY_ID = Guid.Empty;
							string sSALES_STAGE = NextSalesStage();
							// 05/01/2013 Paul.  Add Contacts field to support B2C. 
							// 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
							SqlProcs.spOPPORTUNITIES_Update
								( ref gOPPORTUNITY_ID
								, gASSIGNED_USER_ID
								, gACCOUNT_ID
								, sACCOUNT_NAME + " - 1000 units"
								, NextOpportunityType()
								, NextLeadSource()
								, NextAmount()
								, C10n.ID
								, ((sSALES_STAGE == "Closed Won" || sSALES_STAGE == "Closed List") ? NextDate() : PastDate())
								, String.Empty
								, sSALES_STAGE
								, NextProbability()
								, String.Empty
								, String.Empty
								, Guid.Empty
								, String.Empty
								, gTEAM_ID
								, sTEAM_SET_LIST
								, Guid.Empty
								, bEXCHANGE_FOLDER
								, Guid.Empty        // B2C_CONTACT_ID
								, Guid.Empty        // LEAD_ID
								// 05/12/2016 Paul.  Add Tags module. 
								, "demo"  // TAG_SET_NAME
								// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
								, String.Empty      // OPPORTUNITY_NUMBER
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty      // ASSIGNED_SET_LIST
								, trn
								);
							arrAccounts[i] = new Account(gACCOUNT_ID, gASSIGNED_USER_ID, sACCOUNT_NAME, sBILLING_ADDRESS_STATE, gOPPORTUNITY_ID);
						}
						for ( int i = 0; i < nMaxContacts; i++ )
						{
							int      nAccount = ran.Next(arrAccounts.Length);
							Guid     gCONTACT_ID                 = Guid.Empty;
							Guid     gASSIGNED_USER_ID           = arrAccounts[nAccount].ASSIGNED_USER_ID;
							string   sSALUTATION                 = String.Empty;
							string   sFIRST_NAME                 = NextFirstName();
							string   sLAST_NAME                  = NextLastName();
							Guid     gACCOUNT_ID                 = arrAccounts[nAccount].ID;
							string   sLEAD_SOURCE                = NextLeadSource();
							string   sTITLE                      = NextTitle();
							string   sDEPARTMENT                 = String.Empty;
							Guid     gREPORTS_TO_ID              = Guid.Empty;
							DateTime BIRTHDATE                   = DateTime.MinValue;
							bool     bDO_NOT_CALL                = false;
							string   sPHONE_HOME                 = NextPhoneNumber();
							string   sPHONE_MOBILE               = NextPhoneNumber();
							string   sPHONE_WORK                 = NextPhoneNumber();
							string   sPHONE_OTHER                = String.Empty;
							string   sPHONE_FAX                  = String.Empty;
							string   sEMAIL1                     = NextEmailAddress();
							string   sEMAIL2                     = String.Empty;
							string   sASSISTANT                  = String.Empty;
							string   sASSISTANT_PHONE            = String.Empty;
							bool     bEMAIL_OPT_OUT              = false;
							bool     bINVALID_EMAIL              = false;
							string   sPRIMARY_ADDRESS_STREET     = NextStreetName();
							string   sPRIMARY_ADDRESS_CITY       = NextCityName();
							string   sPRIMARY_ADDRESS_STATE      = NextStateName();
							string   sPRIMARY_ADDRESS_POSTALCODE = NextPostalCode();
							string   sPRIMARY_ADDRESS_COUNTRY    = "USA";
							string   sALT_ADDRESS_STREET         = sPRIMARY_ADDRESS_STREET    ;
							string   sALT_ADDRESS_CITY           = sPRIMARY_ADDRESS_CITY      ;
							string   sALT_ADDRESS_STATE          = sPRIMARY_ADDRESS_STATE     ;
							string   sALT_ADDRESS_POSTALCODE     = sPRIMARY_ADDRESS_POSTALCODE;
							string   sALT_ADDRESS_COUNTRY        = sPRIMARY_ADDRESS_COUNTRY   ;
							string   sDESCRIPTION                = String.Empty;
							string   sPARENT_TYPE                = String.Empty;
							Guid     gPARENT_ID                  = Guid.Empty;
							bool     bSYNC_CONTACT               = false;
							// 04/04/2017 Paul.  Assign demo data to a team. 
							Guid     gTEAM_ID                    = gDEMO_TEAM_ID;
							string   sTEAM_SET_LIST              = String.Empty;
							// 09/27/2013 Paul.  SMS messages need to be opt-in. 
							string   sSMS_OPT_IN                 = String.Empty;
							// 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
							string   sTWITTER_SCREEN_NAME        = String.Empty;
							SqlProcs.spCONTACTS_Update
								( ref gCONTACT_ID
								, gASSIGNED_USER_ID          
								, sSALUTATION                
								, sFIRST_NAME                
								, sLAST_NAME                 
								, gACCOUNT_ID                
								, sLEAD_SOURCE               
								, sTITLE                     
								, sDEPARTMENT                
								, gREPORTS_TO_ID             
								, BIRTHDATE                  
								, bDO_NOT_CALL               
								, sPHONE_HOME                
								, sPHONE_MOBILE              
								, sPHONE_WORK                
								, sPHONE_OTHER               
								, sPHONE_FAX                 
								, sEMAIL1                    
								, sEMAIL2                    
								, sASSISTANT                 
								, sASSISTANT_PHONE           
								, bEMAIL_OPT_OUT             
								, bINVALID_EMAIL             
								, sPRIMARY_ADDRESS_STREET    
								, sPRIMARY_ADDRESS_CITY      
								, sPRIMARY_ADDRESS_STATE     
								, sPRIMARY_ADDRESS_POSTALCODE
								, sPRIMARY_ADDRESS_COUNTRY   
								, sALT_ADDRESS_STREET        
								, sALT_ADDRESS_CITY          
								, sALT_ADDRESS_STATE         
								, sALT_ADDRESS_POSTALCODE    
								, sALT_ADDRESS_COUNTRY       
								, sDESCRIPTION               
								, sPARENT_TYPE               
								, gPARENT_ID                 
								, bSYNC_CONTACT              
								, gTEAM_ID                   
								, sTEAM_SET_LIST             
								, sSMS_OPT_IN                
								, sTWITTER_SCREEN_NAME       
								// 08/07/2015 Paul.  Add picture. 
								, String.Empty  // PICTURE
								// 08/07/2015 Paul.  Add Leads/Contacts relationship. 
								, Guid.Empty    // LEAD_ID
								// 09/27/2015 Paul.  Separate SYNC_CONTACT and EXCHANGE_FOLDER. 
								, false         // EXCHANGE_FOLDER
								// 05/12/2016 Paul.  Add Tags module. 
								, "demo"        // TAG_SET_NAME
								// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
								, String.Empty  // CONTACT_NUMBER
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								// 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
								, String.Empty       // DP_BUSINESS_PURPOSE
								, DateTime.MinValue  // DP_CONSENT_LAST_UPDATED
								, trn
								);
							Guid gOPPORTUNITY_ID = arrAccounts[nAccount].OPPORTUNITY_ID;
							SqlProcs.spOPPORTUNITIES_CONTACTS_Update
								( gOPPORTUNITY_ID
								, gCONTACT_ID
								, "Primary Decision Maker"
								, trn
								);
							Guid gTASK_ID = Guid.Empty;
							SqlProcs.spTASKS_Update
								( ref gTASK_ID
								, gASSIGNED_USER_ID
								, NextTaskName()
								, NextTaskStatus()
								, NextDate()
								, DateTime.MinValue
								, (sPRIMARY_ADDRESS_CITY == "Sacramento" ? "Accounts"  : String.Empty)
								, (sPRIMARY_ADDRESS_CITY == "Sacramento" ? gACCOUNT_ID : Guid.Empty  )
								, gCONTACT_ID
								, NextTaskPriority()
								, String.Empty
								, gTEAM_ID
								, sTEAM_SET_LIST
								// 05/17/2017 Paul.  Add Tags module. 
								, String.Empty  // TAG_SET_NAME
								// 06/07/2017 Paul.  Add REMINDER_TIME, EMAIL_REMINDER_TIME, SMS_REMINDER_TIME. 
								, -1           // REMINDER_TIME
								, -1           // EMAIL_REMINDER_TIME
								, -1           // SMS_REMINDER_TIME
								// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
								, false        // IS_PRIVATE
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty // ASSIGNED_SET_LIST
								, trn
								);
							Guid gMEETING_ID = Guid.Empty;
							// 12/26/2012 Paul.  Add EMAIL_REMINDER_TIME. 
							// 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
							// 03/20/2013 Paul.  Add REPEAT fields. 
							// 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
							// 09/14/2015 Paul.  Default for reminders should be 0. 
							SqlProcs.spMEETINGS_Update
								( ref gMEETING_ID
								, gASSIGNED_USER_ID
								, NextMeetingName()
								, String.Empty
								, NextDurationHours()
								, NextDurationMinutes()
								, NextDate()
								, NextMeetingStatus()
								, "Accounts"
								, gACCOUNT_ID
								, 0                 // REMINDER_TIME
								, "Meeting to discuss project plan and hash out the details of implementation"
								, gCONTACT_ID.ToString()
								, gTEAM_ID
								, sTEAM_SET_LIST
								, 0                 // EMAIL_REMINDER_TIME
								, false             // ALL_DAY_EVENT
								, String.Empty      // REPEAT_TYPE
								, 0                 // REPEAT_INTERVAL
								, String.Empty      // REPEAT_DOW
								, DateTime.MinValue // REPEAT_UNTIL
								, 0                 // REPEAT_COUNT
								, 0                 // SMS_REMINDER_TIME
								// 05/17/2017 Paul.  Add Tags module. 
								, String.Empty      // TAG_SET_NAME
								// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
								, false             // IS_PRIVATE
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty      // ASSIGNED_SET_LIST
								, trn
								);
							SqlProcs.spMEETINGS_CONTACTS_Update
								( gMEETING_ID
								, gCONTACT_ID
								, false
								, "accept"
								, trn
								);
							Guid gEMAIL_ID = Guid.Empty;
							SqlProcs.spEMAILS_Update
								( ref gEMAIL_ID
								, gASSIGNED_USER_ID
								, NextEmailSubject()
								, NextDate()
								, "Accounts"
								, gACCOUNT_ID
								, "Meeting to discuss project plan and hash out the details of implementation"
								, String.Empty
								, GetUserEmailAddress(gASSIGNED_USER_ID)
								, GetUserName(gASSIGNED_USER_ID)
								, sFIRST_NAME + " " + sLAST_NAME + " <" + sEMAIL1 + ">"
								, String.Empty
								, String.Empty
								, gCONTACT_ID.ToString()
								, sFIRST_NAME + " " + sLAST_NAME
								, sEMAIL1
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, "out"
								, String.Empty
								, String.Empty
								, String.Empty
								, String.Empty
								, Guid.Empty
								, Guid.Empty
								, String.Empty
								// 05/17/2017 Paul.  Add Tags module. 
								, String.Empty  // TAG_SET_NAME
								// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
								, false         // IS_PRIVATE
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								, trn
								);
							SqlProcs.spEMAILS_UpdateStatus
								( gEMAIL_ID
								, "sent"
								, trn
								);
						}
						for ( int i = 0; i < nMaxLeads; i++ )
						{
							int  nAccount = ran.Next(arrAccounts.Length);
							Guid gASSIGNED_USER_ID = gDEMO_ID;
							if ( i % 3 == 1 )
							{
								switch ( ran.Next(9, 10) )
								{
									case  9:  gASSIGNED_USER_ID = gSEED_WILL_ID ;  break;
									case 10:  gASSIGNED_USER_ID = gSEED_CHRIS_ID;  break;
								}
							}
							else
							{
								switch ( ran.Next(6, 8) )
								{
									case  6:  gASSIGNED_USER_ID = gSEED_SARAH_ID;  break;
									case  7:  gASSIGNED_USER_ID = gSEED_SALLY_ID;  break;
									case  8:  gASSIGNED_USER_ID = gSEED_MAX_ID  ;  break;
								}
							}
							Guid   gLEAD_ID                     = Guid.Empty;
							string sSALUTATION                  = String.Empty;
							string sFIRST_NAME                  = NextFirstName();
							string sLAST_NAME                   = NextLastName();
							string sTITLE                       = NextTitle();
							string sREFERED_BY                  = String.Empty;
							string sLEAD_SOURCE                 = NextLeadSource();
							string sLEAD_SOURCE_DESCRIPTION     = String.Empty;
							string sSTATUS                      = NextLeadStatus();
							string sSTATUS_DESCRIPTION          = String.Empty;
							string sDEPARTMENT                  = String.Empty;
							Guid   gREPORTS_TO_ID               = Guid.Empty;
							bool   bDO_NOT_CALL                 = false;
							string sPHONE_HOME                  = NextPhoneNumber();
							string sPHONE_MOBILE                = NextPhoneNumber();
							string sPHONE_WORK                  = NextPhoneNumber();
							string sPHONE_OTHER                 = String.Empty;
							string sPHONE_FAX                   = String.Empty;
							string sEMAIL1                      = NextEmailAddress();
							string sEMAIL2                      = String.Empty;
							bool   bEMAIL_OPT_OUT               = false;
							bool   bINVALID_EMAIL               = false;
							string sPRIMARY_ADDRESS_STREET      = NextStreetName();
							string sPRIMARY_ADDRESS_CITY        = NextCityName();
							string sPRIMARY_ADDRESS_STATE       = arrAccounts[nAccount].BILLING_ADDRESS_STATE;
							string sPRIMARY_ADDRESS_POSTALCODE  = NextPostalCode();
							string sPRIMARY_ADDRESS_COUNTRY     = "USA";
							string sALT_ADDRESS_STREET          = String.Empty;
							string sALT_ADDRESS_CITY            = String.Empty;
							string sALT_ADDRESS_STATE           = String.Empty;
							string sALT_ADDRESS_POSTALCODE      = String.Empty;
							string sALT_ADDRESS_COUNTRY         = String.Empty;
							string sDESCRIPTION                 = String.Empty;
							string sACCOUNT_NAME                = String.Empty;
							Guid   gCAMPAIGN_ID                 = Guid.Empty;
							// 04/04/2017 Paul.  Assign demo data to a team. 
							Guid   gTEAM_ID                     = gDEMO_TEAM_ID;
							string sTEAM_SET_LIST               = String.Empty;
							Guid   gCONTACT_ID                  = Guid.Empty;
							Guid   gACCOUNT_ID                  = Guid.Empty;
							bool   bEXCHANGE_FOLDER             = false;
							// 04/02/2012 Paul.  Add ASSISTANT, ASSISTANT_PHONE, BIRTHDATE, WEBSITE. 
							DateTime dtBIRTHDATE                = DateTime.MinValue;
							string   sASSISTANT                 = String.Empty;
							string   sASSISTANT_PHONE           = String.Empty;
							string   sWEBSITE                   = String.Empty;
							// 09/27/2013 Paul.  SMS messages need to be opt-in. 
							string   sSMS_OPT_IN                = String.Empty;
							// 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
							string   sTWITTER_SCREEN_NAME       = String.Empty;
							SqlProcs.spLEADS_Update
								( ref gLEAD_ID               
								, gASSIGNED_USER_ID          
								, sSALUTATION                
								, sFIRST_NAME                
								, sLAST_NAME                 
								, sTITLE                     
								, sREFERED_BY                
								, sLEAD_SOURCE               
								, sLEAD_SOURCE_DESCRIPTION   
								, sSTATUS                    
								, sSTATUS_DESCRIPTION        
								, sDEPARTMENT                
								, gREPORTS_TO_ID             
								, bDO_NOT_CALL               
								, sPHONE_HOME                
								, sPHONE_MOBILE              
								, sPHONE_WORK                
								, sPHONE_OTHER               
								, sPHONE_FAX                 
								, sEMAIL1                    
								, sEMAIL2                    
								, bEMAIL_OPT_OUT             
								, bINVALID_EMAIL             
								, sPRIMARY_ADDRESS_STREET    
								, sPRIMARY_ADDRESS_CITY      
								, sPRIMARY_ADDRESS_STATE     
								, sPRIMARY_ADDRESS_POSTALCODE
								, sPRIMARY_ADDRESS_COUNTRY   
								, sALT_ADDRESS_STREET        
								, sALT_ADDRESS_CITY          
								, sALT_ADDRESS_STATE         
								, sALT_ADDRESS_POSTALCODE    
								, sALT_ADDRESS_COUNTRY       
								, sDESCRIPTION               
								, sACCOUNT_NAME              
								, gCAMPAIGN_ID               
								, gTEAM_ID                   
								, sTEAM_SET_LIST             
								, gCONTACT_ID                
								, gACCOUNT_ID                
								, bEXCHANGE_FOLDER           
								, dtBIRTHDATE                
								, sASSISTANT                 
								, sASSISTANT_PHONE           
								, sWEBSITE                   
								, sSMS_OPT_IN                
								, sTWITTER_SCREEN_NAME       
								// 08/07/2015 Paul.  Add picture. 
								, String.Empty  // PICTURE
								// 05/12/2016 Paul.  Add Tags module. 
								, "demo"        // TAG_SET_NAME
								// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
								, String.Empty  // LEAD_NUMBER
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								, String.Empty  // ASSIGNED_SET_LIST
								// 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
								, String.Empty       // DP_BUSINESS_PURPOSE
								, DateTime.MinValue  // DP_CONSENT_LAST_UPDATED
								, trn
								);
						}
						string sSiteURL = Crm.Config.SiteURL(Application);
						Guid gEMAIL_TEMPLATE_ID = Guid.Empty;
						// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
						SqlProcs.spEMAIL_TEMPLATES_Update
							( ref gEMAIL_TEMPLATE_ID
							, true
							, false
							, "Demo data email"
							, "This template is used when the System Administrator sends a new password to a user."
							, "New demo data information"
							, String.Empty
							, "<div><table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"550\" align=\"&quot;&quot;center&quot;&quot;\"><tbody><tr><td colspan=\"2\"><p>Here is your account username and temporary password:</p><p>Username : $contact_user_user_name </p><p>Password : $contact_user_user_hash </p><br><p>" + sSiteURL + "/index.php</p><br><p>After you log in using the above password, you may be required to reset the password to one of your own choice.</p>   </td>         </tr><tr><td colspan=\"2\"></td>         </tr> </tbody></table> </div>"
							, Guid.Empty
							, String.Empty
							, gDEMO_ID
							// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
							, String.Empty   // ASSIGNED_SET_LIST
							, trn
							);
						
						Guid gPROJECT_ID = Guid.Empty;
						SqlProcs.spPROJECTS_Update
							( ref gPROJECT_ID
							, gDEMO_ID
							, "Create new project plan for audit"
							, "Annual audit coming up next month."
							, String.Empty
							, Guid.Empty
							, Guid.Empty
							, String.Empty
							, new DateTime(2007, 11, 01)
							, new DateTime(2007, 12, 31)
							, "Draft"
							, "medium"
							, false
							, false
							// 05/12/2016 Paul.  Add Tags module. 
							, "demo"  // TAG_SET_NAME
							// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
							, String.Empty   // ASSIGNED_SET_LIST
							, trn
							);

						Guid gPROJECT_TASK_ID1 = Guid.Empty;
						Guid gPROJECT_TASK_ID2 = Guid.Empty;
						Guid gPROJECT_TASK_ID3 = Guid.Empty;
						Guid gPROJECT_TASK_ID4 = Guid.Empty;
						Guid gPROJECT_TASK_ID5 = Guid.Empty;
						Guid gPROJECT_TASK_ID6 = Guid.Empty;
						Guid gPROJECT_TASK_ID7 = Guid.Empty;
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						SqlProcs.spPROJECT_TASKS_Update(ref gPROJECT_TASK_ID1, gDEMO_ID, "Communicate to stakeholders"    , String.Empty, new DateTime(2007, 11,  8), new DateTime(2007, 11,  1), gPROJECT_ID, String.Empty, "Schedule individual meetings with Will, Max, and Sarah."              , 0, 0, Guid.Empty, false, 0.0f, 0.0f, 0, 100, Guid.Empty, String.Empty, String.Empty, trn);
						SqlProcs.spPROJECT_TASKS_Update(ref gPROJECT_TASK_ID2, gDEMO_ID, "Create draft of the plan"       , String.Empty, new DateTime(2007, 11, 20), new DateTime(2007, 11,  5), gPROJECT_ID, String.Empty, "Schedule individual meetings with Will, Max, and Sarah."              , 0, 0, Guid.Empty, false, 0.0f, 0.0f, 0,  38, Guid.Empty, String.Empty, String.Empty, trn);
						SqlProcs.spPROJECT_TASKS_Update(ref gPROJECT_TASK_ID3, gDEMO_ID, "Field work for collecting data.", String.Empty, new DateTime(2007, 11, 13), new DateTime(2007, 11,  5), gPROJECT_ID, String.Empty, "We need to get approval from all stakeholders on the plan"            , 0, 0, Guid.Empty, false, 0.0f, 0.0f, 0,  75, Guid.Empty, String.Empty, String.Empty, trn);
						SqlProcs.spPROJECT_TASKS_Update(ref gPROJECT_TASK_ID4, gDEMO_ID, "Create draft of the plan"       , String.Empty, new DateTime(2007, 11, 19), new DateTime(2007, 11, 12), gPROJECT_ID, String.Empty, "Schedule the meeting with the head of business units to solicit help.", 0, 0, Guid.Empty, false, 0.0f, 0.0f, 0,   0, Guid.Empty, String.Empty, String.Empty, trn);
						SqlProcs.spPROJECT_TASKS_Update(ref gPROJECT_TASK_ID5, gDEMO_ID, "Gather data from meetings"      , String.Empty, new DateTime(2007, 11, 20), new DateTime(2007, 11, 20), gPROJECT_ID, String.Empty, "Need to organize the data and put it in the right spreadsheet."       , 0, 0, Guid.Empty, false, 0.0f, 0.0f, 0,   0, Guid.Empty, String.Empty, String.Empty, trn);
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
						return;
					}
					finally
					{
						// 09/21/2010 Paul.  Restore the last user. 
						Security.USER_ID = gLAST_USER_ID;
					}
					// 05/11/2014 Paul.  Move redirect outside the exception so that trn.Rollback() will not get hit due to termination exception thrown. 
					// 09/22/2010 Paul.  Redirect to the AdminWizard.  Don't run the AdminWizard on the Offline Client. 
					if ( Security.IS_ADMIN && Sql.IsEmptyString(Context.Application["CONFIG.Configurator.LastRun"]) && !Utils.IsOfflineClient )
						Context.Response.Redirect("~/Administration/Configurator/");
					// 09/22/2010 Paul.  Redirect to the new User Wizard.  The user cannot be modified on the Offline Client. 
					else if ( Sql.IsEmptyString(Session["USER_SETTINGS/TIMEZONE/ORIGINAL"]) && !Utils.IsOfflineClient )
						Response.Redirect("~/Users/Wizard.aspx"); // Response.Redirect("~/Users/SetTimezone.aspx");
					else
						// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
						Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
				}
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}


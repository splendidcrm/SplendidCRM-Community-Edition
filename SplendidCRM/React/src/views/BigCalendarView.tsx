/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
import * as React from 'react';
import { RouteComponentProps, withRouter }          from '../Router5'            ;
import { Calendar as BigCalendar, momentLocalizer } from 'react-big-calendar'          ;
import moment                                       from 'moment'                      ;
import { observer }                                 from 'mobx-react'                  ;
import 'react-big-calendar/lib/css/react-big-calendar.css';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'              ;
import L10n                                         from '../scripts/L10n'             ;
import Security                                     from '../scripts/Security'         ;
import Credentials                                  from '../scripts/Credentials'      ;
import SplendidCache                                from '../scripts/SplendidCache'    ;
import { CalendarView_GetCalendar }                 from '../scripts/CalendarView'     ;
import { FromJsonDate, ToJsonDate }                 from '../scripts/Formatting'       ;
import { AuthenticatedMethod, LoginRedirect }       from '../scripts/Login'            ;
import { UpdateModule }                             from '../scripts/ModuleUpdate'     ;
import { Trim, isMobileDevice }                     from '../scripts/utility'          ;
// 4. Components and Views. 
import ErrorComponent                               from '../components/ErrorComponent';
import CalendarEditDialog                           from './CalendarEditDialog'        ;


interface IBigCalendarViewProps extends RouteComponentProps<any>
{
	SUB_TITLE            : string;
};

interface IBigCalendarViewState
{
	bSharedCalendar      ;
	YearMonthPattern     ;
	MonthDayPattern      ;
	LongDatePattern      ;
	ShortTimePattern     ;
	ShortDatePattern     ;
	FirstDayOfWeek       ;
	MonthNames           ;
	AbbreviatedMonthNames;
	DayNames             ;
	AbbreviatedDayNames  ;
	date                 ;
	events               : any;
	view                 : any;
	isPopupOpen          : boolean;
	popupArgs            : any;
	error                : any;
	localizer            : any;
}

@observer
class BigCalendarView extends React.Component<IBigCalendarViewProps, IBigCalendarViewState>
{
	constructor(props: IBigCalendarViewProps)
	{
		super(props);
		let sCalendarDefaultView = '';
		sCalendarDefaultView = localStorage.getItem('CalendarDefaultView');
		if (Sql.IsEmptyString(sCalendarDefaultView))
			sCalendarDefaultView = 'day';
		let bSharedCalendar = Sql.ToBoolean(localStorage.getItem('CalendarDefaultShared'));

		let sYearMonthPattern = L10n.Term('Calendar.YearMonthPattern');
		let sMonthDayPattern = L10n.Term('Calendar.MonthDayPattern');
		let sLongDatePattern = L10n.Term('Calendar.LongDatePattern');
		let sShortTimePattern = Security.USER_TIME_FORMAT();
		let sShortDatePattern = Security.USER_DATE_FORMAT();

		let nFirstDayOfWeek = Sql.ToInteger(L10n.Term('Calendar.FirstDayOfWeek'));
		let arrMonthNames = L10n.GetListTerms('month_names_dom');
		let arrAbbreviatedMonthNames = L10n.GetListTerms('short_month_names_dom');
		let arrDayNames = L10n.GetListTerms('day_names_dom');
		let arrAbbreviatedDayNames = L10n.GetListTerms('short_day_names_dom');

		if (Sql.IsEmptyString(sYearMonthPattern) || sYearMonthPattern == 'Calendar.YearMonthPattern') sYearMonthPattern = 'MMMM, yyyy';
		if (Sql.IsEmptyString(sMonthDayPattern) || sMonthDayPattern == 'Calendar.MonthDayPattern') sMonthDayPattern = 'MMMM dd';
		if (Sql.IsEmptyString(sLongDatePattern) || sLongDatePattern == 'Calendar.LongDatePattern') sLongDatePattern = 'dddd, MMMM dd, yyyy';
		if (Sql.IsEmptyString(sShortTimePattern)) sShortTimePattern = 'h:mm tt';
		if (Sql.IsEmptyString(sShortDatePattern)) sShortDatePattern = 'MM/dd/yyyy';
		if (Sql.IsEmptyString(nFirstDayOfWeek) || isNaN(nFirstDayOfWeek)) nFirstDayOfWeek = 0;
		if (arrMonthNames == null || arrMonthNames.length == 0) arrMonthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
		if (arrAbbreviatedMonthNames == null || arrAbbreviatedMonthNames.length == 0) arrAbbreviatedMonthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
		if (arrDayNames == null || arrDayNames.length == 0) arrDayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
		if (arrAbbreviatedDayNames == null || arrAbbreviatedDayNames.length == 0) arrAbbreviatedDayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

		// 05/24/2018 Paul.  Change to moment format. 
		// http://momentjs.com/docs/#/displaying/
		// https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
		// 05/24/2018 Paul.  Days are painful because dddd is full date, but we need to convert dd to DD.
		// 08/03/2021 Paul.  Need to move so that these corrections are after the above empty string initialization. 
		sYearMonthPattern = sYearMonthPattern.replace('yyyy', 'YYYY').replace('yy', 'YY');
		sYearMonthPattern = sYearMonthPattern.replace('dddd', 'DDDD').replace('dd', 'DD').replace('d', 'D').replace('DDDD', 'dddd');
		sMonthDayPattern = sMonthDayPattern.replace('yyyy', 'YYYY').replace('yy', 'YY');
		sMonthDayPattern = sMonthDayPattern.replace('dddd', 'DDDD').replace('dd', 'DD').replace('d', 'D').replace('DDDD', 'dddd');
		sLongDatePattern = sLongDatePattern.replace('yyyy', 'YYYY').replace('yy', 'YY');
		sLongDatePattern = sLongDatePattern.replace('dddd', 'DDDD').replace('dd', 'DD').replace('d', 'D').replace('DDDD', 'dddd');
		sShortDatePattern = sShortDatePattern.replace('yyyy', 'YYYY').replace('yy', 'YY');
		sShortDatePattern = sShortDatePattern.replace('dddd', 'DDDD').replace('dd', 'DD').replace('d', 'D').replace('DDDD', 'dddd');
		sShortTimePattern = sShortTimePattern.replace('tt', 'a');

		let options =
		{
			monthNames     : L10n.GetListTerms('month_names_dom'      ),
			monthNamesShort: L10n.GetListTerms('short_month_names_dom'),
			dayNames       : L10n.GetListTerms('day_names_dom'        ),
			dayNamesShort  : L10n.GetListTerms('short_day_names_dom'  ),
		};
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor() ' + Credentials.sUSER_LANG);
		moment.updateLocale(Credentials.sUSER_LANG.substring(0, 2),
		{
			months      : options.monthNames,
			monthsShort : options.monthNamesShort,
			weekdays    : options.dayNames,
			weekdaysShort: options.dayNamesShort
		});
		this.state =
		{
			view                 : sCalendarDefaultView,
			bSharedCalendar      : bSharedCalendar,
			YearMonthPattern     : sYearMonthPattern,
			MonthDayPattern      : sMonthDayPattern,
			LongDatePattern      : sLongDatePattern,
			ShortTimePattern     : sShortTimePattern,
			ShortDatePattern     : sShortDatePattern,
			FirstDayOfWeek       : nFirstDayOfWeek,
			MonthNames           : arrMonthNames,
			AbbreviatedMonthNames: arrAbbreviatedMonthNames,
			DayNames             : arrDayNames,
			AbbreviatedDayNames  : arrAbbreviatedDayNames,
			date                 : new Date(),
			events               : [],
			isPopupOpen          : false,
			popupArgs            : null,
			error                : null,
			localizer            : momentLocalizer(moment),
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		await this.init();
	}

	async componentDidUpdate(prevProps: IBigCalendarViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate Reset', this.props.location,  prevProps.location);
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	private init = async () =>
	{
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.init');
			if ( status == 1 )
			{
				await this.preload();
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.init', error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { SUB_TITLE } = this.props;
		const
		{ view,
			bSharedCalendar,
			YearMonthPattern,
			MonthDayPattern,
			LongDatePattern,
			ShortTimePattern,
			ShortDatePattern,
			FirstDayOfWeek,
			MonthNames,
			AbbreviatedMonthNames,
			DayNames,
			AbbreviatedDayNames,
			date,
			events,
			error,
			localizer
		} = this.state;

		let bIsMobile = isMobileDevice();
		let header =
		{
			left  : 'agendaDay,agendaWeek,month shared',
			center: (bIsMobile ? '' : 'title'),
			right : 'today prev,next'
		};
		let customButtons =
		{
			shared:
			{
				text: L10n.Term('Calendar.LBL_SHARED'),
				click: this.ToggleSharedCalendar
			}
		};
		let buttonText =
		{
			prev    : L10n.Term('.LBL_PREVIOUS_BUTTON_LABEL'), // left triangle
			next    : L10n.Term('.LBL_NEXT_BUTTON_LABEL'    ),  // right triangle
			prevYear: ' << ', // <<
			nextYear: ' >> ', // >>
			today   : L10n.Term('Calendar.LNK_VIEW_CALENDAR'),
			month   : L10n.Term('Calendar.LBL_MONTH'        ),
			week    : L10n.Term('Calendar.LBL_WEEK'         ),
			day     : L10n.Term('Calendar.LBL_DAY'          ),
		};
		let titleFormat =
		{
			month: YearMonthPattern,
			week : MonthDayPattern + ', YYYY',
			day  : LongDatePattern,
		};
		let timeFormat =
		{
			agenda: ShortTimePattern + '{ - ' + ShortTimePattern + '}'
			, '': ShortTimePattern
		};
		let columnFormat =
		{
			month: 'ddd'
			, week: 'ddd ' + Trim(ShortDatePattern.replace('YYYY', '').replace(new RegExp(/\//g), ' ')).replace(new RegExp(/ /g), '/').replace('MM', 'M').replace('DD', 'D')
			, day: 'dddd ' + Trim(ShortDatePattern.replace('YYYY', '').replace(new RegExp(/\//g), ' ')).replace(new RegExp(/ /g), '/').replace('MM', 'M').replace('DD', 'D')
		};

		let eventSources = new Array();
		let sGoogleHolidayURL = SplendidCache.Config('GoogleCalendar.HolidayCalendars');
		if (!Sql.IsEmptyString(sGoogleHolidayURL))
		{
			let arrGoogleHolidayURL = sGoogleHolidayURL.split(',');
			for (let i = 0; i < arrGoogleHolidayURL.length; i++)
			{
				// 01/30/2014 Paul.  Chrome and Firefox require that the protocol match.  IE seems to be more flexible. 
				if (window.location.protocol == 'https:')
					arrGoogleHolidayURL[i] = arrGoogleHolidayURL[i].replace('http:', window.location.protocol);
				eventSources.push(arrGoogleHolidayURL[i]);
			}
		}
		// 05/08/2017 Paul.  Use Bootstrap for responsive design.
		// let height = $('#divMainPageContent').height() > 0 ? $('#divMainPageContent').height() - 180 : 800
		return SplendidCache.IsInitialized && (
			<div>
				<ErrorComponent error={error} />
				<CalendarEditDialog isOpen={ this.state.isPopupOpen } args={ this.state.popupArgs } callback={ this.handlePopupCallback } />
				<BigCalendar
					key='BigCalendar'
					events={ events }
					messages={
					{
						allDay  : L10n.Term('Calendar.LBL_ALL_DAY'      ),
						previous: L10n.Term('.LBL_PREVIOUS_BUTTON_LABEL'),
						next    : L10n.Term('.LBL_NEXT_BUTTON_LABEL'    ),
						today   : L10n.Term('Calendar.LNK_VIEW_CALENDAR'),
						month   : L10n.Term('Calendar.LBL_MONTH'        ),
						week    : L10n.Term('Calendar.LBL_WEEK'         ),
						day     : L10n.Term('Calendar.LBL_DAY'          ),
					} }
					selectable
					showMultiDayTimes
					date={ date }
					view={ view }
					views={ ['month', 'week', 'day'] }
					onNavigate={ this.handleNavigate }
					onView={ this.handleViewChange }
					onSelectEvent={ this.handleEventClick }
					onSelectSlot={ this.select }
					localizer={ localizer }
				/>
				{/*<FullCalendar
					//key="Calendar"
					//id="divCalendar"
					width="100%"
					header={header}
					buttonText={buttonText}
					//views={views}
					slotLabelFormat={ShortTimePattern}
					//timeFormat = {timeFormat}
					columnHeaderFormat={columnFormat}
					defaultView={defaultView}
					editable={true}
					//selectable={true}
					selectHelper={true}
					allDaySlot={true}
					allDayText={L10n.Term("Calendar.LBL_ALL_DAY")}
					slotMinutes={30}
					defaultEventMinutes={60}
					firstHour={Sql.ToInteger(SplendidCache.Config('calendar.hour_start'))}
					firstDay={FirstDayOfWeek}
					monthNames={MonthNames}
					monthNamesShort={AbbreviatedMonthNames}
					dayNames={DayNames}
					dayNamesShort={AbbreviatedDayNames}
					eventSources={eventSources}
					customButtons={customButtons}
					//defaultDate={defaultDate}
					//navLinks= {true} // can click day/week names to navigate views
					//eventLimit= {true} // allow "more" link when too many events
					//events = {this.state.events}
					select={this.select}
					eventClick={this.eventClick}
					eventDrop={this.eventDrop}
					eventResize={this.eventResize}
					viewRender={this.viewRender}
					dayClick={this.dayClick}
					eventRender={this.eventRender}
				/>*/}
			</div>
		)
	}

	private handlePopupCallback = (data) =>
	{
		//console.log((new Date()).toISOString() + ' ' + data);
		this.setState({ isPopupOpen: false });
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history, } = this.props;
	}

	private preload = async () =>
	{
		const { bSharedCalendar } = this.state;
		// 5/14/2018 Chase. MUST use Lamda functions instead of keyword 'function' to bind to object.
		let status = await AuthenticatedMethod(this.props, this.constructor.name + '.init');
		if ( status == 1 )
		{
			const { date, view } = this.state;
			let start = moment(date).startOf(view);
			let unit: any = view + 's';
			let end = moment(date).startOf(view).add(1, unit);
			if (view == 'month')
			{
				start = start.day(0);
				end = end.day(7);
			}
			this.load(start, end);
		}
	}

	private ToggleSharedCalendar = () =>
	{
		const { bSharedCalendar } = this.state;
		this.setState({ bSharedCalendar: (bSharedCalendar ? false : true) });
	}

	private select = ({ start, end, slots, action }) =>
	{
		let allDay = !start;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.select ' + start + ', ' + end + ', ' + JSON.stringify(allDay));
		// 05/27/2018 Paul.  Defer update module.
		// 02/24/2013 Paul.  Until we can support allDay events, when clicking on a day of the month, change to the day view. 
		let args = { start: start, end: end, allDay: allDay };
		this.setState({ isPopupOpen: true, popupArgs: args });
	}

	private handleEventClick = (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.eventClick ' + event.url);
		if (event.url !== undefined && event.url != null)
		{
			this.props.history.push(event.url);
		}
		return false;
	}

	private eventDrop = async (event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) =>
	{
		let TOTAL_SECONDS = Math.round((event.end - event.start) / 1000);
		let TOTAL_MINUTES = Math.round(TOTAL_SECONDS / 60);
		let DURATION_HOURS = Math.floor(TOTAL_MINUTES / 60);
		let DURATION_MINUTES = TOTAL_MINUTES % 60;
		let row: any = new Object();
		row.ID = event.id;
		row.DATE_TIME = ToJsonDate(event.start);
		row.DURATION_HOURS = DURATION_HOURS;
		row.DURATION_MINUTES = DURATION_MINUTES;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.eventDrop ' + event.start.format() + ', ' + row.DURATION_HOURS + 'h ' + row.DURATION_MINUTES + 'm');

		try
		{
			let status = await UpdateModule(event.MODULE_NAME, row, event.id);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.eventDrop', error);
			revertFunc();
		}
	}

	private eventResize = async (event, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view) =>
	{
		let TOTAL_SECONDS = Math.round((event.end - event.start) / 1000);
		let TOTAL_MINUTES = Math.round(TOTAL_SECONDS / 60);
		let DURATION_HOURS = Math.floor(TOTAL_MINUTES / 60);
		let DURATION_MINUTES = TOTAL_MINUTES % 60;
		let row: any = new Object();
		row.ID = event.id;
		row.DATE_TIME = ToJsonDate(event.start);
		row.DURATION_HOURS = DURATION_HOURS;
		row.DURATION_MINUTES = DURATION_MINUTES;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.eventResize ' + event.start.format() + ', ' + row.DURATION_HOURS + 'h ' + row.DURATION_MINUTES + 'm');

		try
		{
			let status = await UpdateModule(event.MODULE_NAME, row, event.id);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.eventResize', error);
			revertFunc();
		}
	}

	// Triggered when a new date-range is rendered, or when the view type switches.
	// https://fullcalendar.io/docs/viewRender
	private handleViewChange = async (view: 'month' | 'week' | 'day') =>
	{
		/*const { bSharedCalendar } = this.state;
		if (bSharedCalendar)
			$("#divCalendar").find('button.fc-shared-button').addClass('fc-state-active');
		else
			$("#divCalendar").find('button.fc-shared-button').removeClass('fc-state-active');

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.viewRender ' + view.name);
		localStorage.setItem('CalendarDefaultView', view.name);
		localStorage.setItem('CalendarDefaultShared', bSharedCalendar); */
		const { date } = this.state;
		let start = moment(date).startOf(view);
		let unit: any = view + 's';
		let end = moment(date).startOf(view).add(1, unit);
		if (view == 'month')
		{
			start = start.day(0);
			end = end.day(7);
		}
		await this.load(start, end);
		this.setState({ view: view });
	}

	private handleNavigate = async (nextDate: Date, view: 'month' | 'week' | 'day', action: 'PREV' | 'NEXT' | 'DATE') =>
	{
		let start = moment(nextDate).startOf(view);
		let unit: any = view + 's';
		let end = moment(nextDate).startOf(view).add(1, unit);
		if (view == 'month')
		{
			start = start.day(0);
			end = end.day(7);
		}
		await this.load(start, end);
		this.setState({ date: nextDate });
	}

	private eventRender = (event, element) =>
	{
		//element.popover({
		//	title: event.title,
		//	content: event.description,
		//	trigger: 'hover',
		//	placement: 'top',
		//	container: 'body'
		//});
	}

	private load = async (start, end) =>
	{
		const { bSharedCalendar, ShortDatePattern, ShortTimePattern } = this.state;

		let dtDATE_START = ToJsonDate(start);
		let dtDATE_END = ToJsonDate(end);
		let gASSIGNED_USER_ID = (bSharedCalendar ? '' : Security.USER_ID());
		let sDateFormat = ShortDatePattern + ' ' + ShortTimePattern;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load ' + formatDate(FromJsonDate(dtDATE_START), sDateFormat) + ' to ' + formatDate(FromJsonDate(dtDATE_END), sDateFormat));

		try
		{
			let d = await CalendarView_GetCalendar(dtDATE_START, dtDATE_END, gASSIGNED_USER_ID);
			let rows = d.results;
			let events = new Array();
			for (let i = 0; i < rows.length; i++)
			{
				let row = rows[i];
				let event: any = new Object();
				event.id = row.ID;
				event.title = row.STATUS + ': ' + row.NAME;
				event.MODULE_NAME = row.ACTIVITY_TYPE;
				event.start = FromJsonDate(row.DATE_START);
				event.end = FromJsonDate(row.DATE_END);
				event.editable = true;
				// 02/20/2013 Paul.  Must set allDay in order for event to appear on agenda view. 
				// 03/10/2013 Paul.  Add ALL_DAY_EVENT. 
				event.allDay = Sql.ToBoolean(row.ALL_DAY_EVENT);
				// 03/10/2013 Paul.  We set duration to 24 hours for all day events for iCal synching, but it makes FullCalendar span days in the Week view. 
				if (event.allDay)
					event.end = event.start;
				// 05/27/2018 Paul.  Use React routing format. 
				event.url = row.ACTIVITY_TYPE + '/View/' + row.ID;
				events.push(event);
			}
			this.setState({ events: events });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}
}

export default withRouter(BigCalendarView);

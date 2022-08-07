import { Component, OnInit, Input, Output, EventEmitter, ViewChild } from '@angular/core'                ;
import { faArrowUp, faArrowDown                                   } from '@fortawesome/free-solid-svg-icons'  ;

import { SplendidCacheService                                      } from '../scripts/SplendidCache'     ;
import SplendidDynamic                                               from '../scripts/SplendidDynamic'   ;

import { DynamicButtonsComponent                                   } from '../components/DynamicButtons' ;

@Component({
	selector: 'SplendidGridDefaultHeader',
	template: `<ng-container *ngIf="enableSelection && colIndex == 0">
	<ng-container *ngIf="IsPacific() && !IsPopupView()">
		<DynamicButtons
			ButtonStyle='DataGrid'
			[VIEW_NAME]="MODULE_NAME + '.MassUpdate' + (archiveView ? '.ArchiveView' : '')"
			[row]="null"
			(Page_Command)="_onPage_Command($event)"
			#dynamicButtons
		></DynamicButtons>
	</ng-container>
	<ng-container *ngIf="!IsPacific() && IsPopupView()">
		<ng-container *ngIf="HasBr()">
			<div (click)="_onChangeSort()" [ngStyle]="SortStyle()">
				<span [innerHTML]="column.text"></span>
				<ng-container *ngIf="column.sort">
					<fa-icon [icon]="arrowUp"   [ngStyle]="SortUpStyle()"></fa-icon>
					<fa-icon [icon]="arrowDown" [ngStyle]="SortDownStyle()"></fa-icon>
				</ng-container>
			</div>
		</ng-container>
		<ng-container *ngIf="!HasBr()">
			<div (click)="_onChangeSort()" [ngStyle]="SortStyle()">
				{{ column.text }}
				<ng-container *ngIf="column.sort">
					<fa-icon [icon]="arrowUp"   [ngStyle]="SortUpStyle()"></fa-icon>
					<fa-icon [icon]="arrowDown" [ngStyle]="SortDownStyle()"></fa-icon>
				</ng-container>
			</div>
		</ng-container>
	</ng-container>
	<ng-container *ngIf="!IsPacific() && !IsPopupView()">
		<div></div>
	</ng-container>
</ng-container>
<ng-container *ngIf="!(enableSelection && colIndex == 0)">
	<ng-container *ngIf="HasBr()">
		<div (click)="_onChangeSort()" [ngStyle]="SortStyle()">
			<span [innerHTML]="column.text"></span>
			<ng-container *ngIf="column.sort">
					<fa-icon [icon]="arrowUp"   [ngStyle]="SortUpStyle()"></fa-icon>
					<fa-icon [icon]="arrowDown" [ngStyle]="SortDownStyle()"></fa-icon>
			</ng-container>
		</div>
	</ng-container>
	<ng-container *ngIf="!HasBr()">
		<div (click)="_onChangeSort()" [ngStyle]="SortStyle()">
			{{ column.text }}
			<ng-container *ngIf="column.sort">
					<fa-icon [icon]="arrowUp"   [ngStyle]="SortUpStyle()"></fa-icon>
					<fa-icon [icon]="arrowDown" [ngStyle]="SortDownStyle()"></fa-icon>
			</ng-container>
		</div>
	</ng-container>
</ng-container>
`
})
export class SplendidGridDefaultHeaderComponent implements OnInit
{
	public arrowUp                    = faArrowUp      ;
	public arrowDown                  = faArrowDown    ;
	public sTheme                     : string = null  ;

	@Input()  MODULE_NAME             : string  = null ;
	@Input()  archiveView             : boolean = null ;
	@Input()  enableMassUpdate        : boolean = false;
	@Input()  enableSelection         : boolean = false;
	@Input()  isPopupView             : boolean = false;
	@Input()  colIndex                : number  = 0    ;
	@Input()  column                  : any     = null ;
	@Input()  SORT_FIELD              : string  = null ;
	@Input()  SORT_DIRECTION          : string  = null ;
	@Input()  hasPageCommand          : boolean = false;
	@Output() onLayoutLoaded          : EventEmitter<void> = new EventEmitter<void>();
	@Output() onChangeSort            : EventEmitter<{sSORT_FIELD: string, sSORT_DIRECTION: string}> = new EventEmitter<{sSORT_FIELD: string, sSORT_DIRECTION: string}>();
	@Output() Page_Command            : EventEmitter<{sCommandName: string, sCommandArguments: any}> = new EventEmitter<{sCommandName: string, sCommandArguments: any}>();
	public dynamicButtons            : DynamicButtonsComponent = null;
	@ViewChild('dynamicButtons') set dynamicButtonsRef(buttons: DynamicButtonsComponent)
	{
		//console.log(this.constructor.name + '.@ViewChild headerButtons', buttons);
		if ( buttons )
		{
			this.dynamicButtons = buttons;
			this._onButtonsLoaded();
		}
	};

	public IsPacific()
	{
		const { sTheme, enableMassUpdate, hasPageCommand } = this;
		// 10/28/2020 Paul.  Must use ArchiveView buttons when in archive view. 
		return enableMassUpdate && hasPageCommand && SplendidDynamic.StackedLayout(sTheme) && sTheme != 'Pacific';
	}

	// 07/03/2021 Paul.  SurveyQuestions.PopupView is not showing the header of the first column. 
	public IsPopupView()
	{
		const { isPopupView, column } = this;
		return isPopupView && column.text != null;
	}

	public HasBr()
	{
		const { column } = this;
		// 01/18/2020 Paul.  Allow the <br/> tag. 
		return column != null && column.text != null && column.text.indexOf('<br') >= 0;
	}

	public SortStyle()
	{
		const { column } = this;
		let style: any = {};
		if ( column.sort )
		{
			style.cursor = 'pointer';
		}
		return style;
	}

	public SortUpStyle()
	{
		const { column, SORT_FIELD, SORT_DIRECTION } = this;
		let style: any = {marginLeft: '2px'};
		if ( !(SORT_FIELD == column.dataField && SORT_DIRECTION == 'asc') )
		{
			style.opacity = '.4';
		}
		return style;
	}

	public SortDownStyle()
	{
		const { column, SORT_FIELD, SORT_DIRECTION } = this;
		let style: any = {marginLeft: '2px'};
		if ( !(SORT_FIELD == column.dataField && SORT_DIRECTION == 'desc') )
		{
			style.opacity = '.4';
		}
		return style;
	}

	constructor(public SplendidCache: SplendidCacheService)
	{
		this.sTheme = SplendidCache.UserTheme;
	}

	ngOnInit()
	{
	}

	public _onPage_Command = (obj: {sCommandName: string, sCommandArguments: any}) =>
	{
		this.Page_Command.emit(obj);
	}

	public _onButtonsLoaded = () =>
	{
		this.onLayoutLoaded.emit();
	}

	public _onChangeSort = () =>
	{
		const { column } = this;
		if ( column.sort )
		{
			let sSORT_FIELD    : string = column.dataField;
			let sSORT_DIRECTION: string = 'asc';
			if ( this.SORT_FIELD == column.dataField )
			{
				sSORT_DIRECTION = (this.SORT_DIRECTION == 'asc' ? 'desc' : 'asc');
			}
			this.onChangeSort.emit({sSORT_FIELD, sSORT_DIRECTION});
		}
	}

	public ShowButton(COMMAND_NAME: string, bVisible: boolean)
	{
		if ( this.dynamicButtons != null )
		{
			this.dynamicButtons.ShowButton(COMMAND_NAME, bVisible);
		}
	}

}

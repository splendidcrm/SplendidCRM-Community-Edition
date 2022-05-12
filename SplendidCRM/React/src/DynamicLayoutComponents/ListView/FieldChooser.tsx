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
import { Modal }                                    from 'react-bootstrap'                  ;
// 2. Store and Types. 
import GRIDVIEWS_COLUMN                             from '../../types/GRIDVIEWS_COLUMN'     ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                ;
import L10n                                         from '../../scripts/L10n'               ;
import { uuidFast }                                 from '../../scripts/utility'            ;
// 4. Components and Views. 
import DraggableField                               from './DraggableField'                 ;

interface IListLayoutEditorProps
{
	LayoutType?      : string;
	ViewName?        : string;
	onEditComplete?  : Function;
	callback         : Function;
	isOpen           : boolean;
	layoutDisplay    : GRIDVIEWS_COLUMN[];
	layoutHidden     : GRIDVIEWS_COLUMN[];
}

interface IListLayoutEditorState
{
	layoutName        : string;
	rows              : Array<{ key: string, columns: Array<string> }>;
	draggingId        : string;
	error?            : string;
	layoutAll         : any;
}

export default class FieldChooser extends React.Component<IListLayoutEditorProps, IListLayoutEditorState>
{
	private _isMounted = false;

	constructor(props: IListLayoutEditorProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let existingFields: any   = {};
		let layoutDisplay : any[] = props.layoutDisplay;
		let layoutHidden  : any[] = props.layoutHidden ;
		let layoutAll     : any   = {};
		let rows          : Array<{ key: string, columns: Array<string> }> = [];
		let rowDisplay: any = 
		{
			key    : uuidFast(),
			columns: []
		};
		let rowHidden : any = 
		{
			key    : uuidFast(),
			columns: []
		};
		rows.push(rowDisplay);
		rows.push(rowHidden);
		
		let newArray: any[] = [];
		if ( layoutDisplay != null )
		{
			layoutDisplay.forEach((item) =>
			{
				item.ID = uuidFast();
				if ( !Sql.IsEmptyString(item.DATA_FIELD) )
				{
					existingFields[item.DATA_FIELD] = true;
				}
				newArray.push(Object.assign({}, item));
				rowDisplay.columns.push(item.ID);
				layoutAll[item.ID] = item;
			});
		}
		layoutDisplay = newArray;
		newArray = [];
		if ( layoutHidden != null )
		{
			layoutHidden.forEach((item) =>
			{
				item.ID = uuidFast();
				if ( !existingFields[item.DATA_FIELD] )
				{
					newArray.push(Object.assign({}, item));
				}
				rowHidden.columns.push(item.ID);
				layoutAll[item.ID] = item;
			});
		}
		layoutHidden = newArray;
		this.state =
		{
			layoutName        : props.ViewName,
			rows              ,
			draggingId        : '',
			layoutAll         ,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error: error.message });
		}
	}

	async componentDidUpdate(prevProps: IListLayoutEditorProps)
	{
		if ( prevProps.ViewName != this.props.ViewName )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextProps.ViewName);
			
			this.setState(
			{
				layoutName        : this.props.ViewName,
				rows              :
				[
					{
						key    : uuidFast(),
						columns: []
					}
				],
				draggingId        : '',
				error             : null,
			});
		}
	}

	private setDragging = (id: string) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.setDragging', id);
		if ( this._isMounted )
		{
			if ( this.state.draggingId != id )
			{
				this.setState({ draggingId: id, error: null });
			}
		}
	}

	private findField = (id: string) =>
	{
		const { rows } = this.state
		try
		{
			for ( let rowIndex = 0; rowIndex < rows.length; rowIndex++ )
			{
				let row: any = rows[rowIndex];
				for ( let colIndex = 0; colIndex < row.columns.length; colIndex++ )
				{
					let col: string[] = row.columns[colIndex];
					if ( col != null )
					{
						for ( let fieldIndex = 0; fieldIndex < col.length; fieldIndex++ )
						{
							if ( col[fieldIndex] == id )
							{
								return { id, rowIndex, colIndex, fieldIndex };
							}
						}
					}
				}
			}
		}
		catch(e)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.findField', e);
		}
		return null;
	}

	private moveDraggableItem = (dragColIndex: number, dragRowIndex: number, hoverColIndex: number, hoverRowIndex: number) =>
	{
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem', dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex, rows);
		try
		{
			const item = rows[dragRowIndex].columns.splice(dragColIndex, 1)[0];
			rows[hoverRowIndex].columns.splice(hoverColIndex, 0, item);
			if ( this._isMounted )
			{
				this.setState({ rows, error: null });
			}
		}
		catch(e)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem', e);
		}
	}

	private _onSave = async (e) =>
	{
		const { callback } = this.props;
		const { layoutName, rows, layoutAll } = this.state;
		try
		{
			let layoutDisplay: any[] = [];
			let layoutHidden : any[] = [];
			for ( let i: number = 0; i < rows[0].columns.length; i++ )
			{
				let ID: string = rows[0].columns[i];
				if ( layoutAll[ID] )
				{
					layoutDisplay.push(Object.assign({}, layoutAll[ID]));
				}
				else
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave Missing layoutDisplay ' + i.toString(), ID);
				}
			}
			for ( let i: number = 0; i < rows[1].columns.length; i++ )
			{
				let ID: string = rows[1].columns[i];
				if ( layoutAll[ID] )
				{
					layoutHidden.push(Object.assign({}, layoutAll[ID]));
				}
				else
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave Missing layoutHidden  ' + i.toString(), ID);
				}
			}
			callback('Save', layoutDisplay, layoutHidden);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', error);
			this.setState({ error: error.message });
		}
	}

	private _onCancel = (e) =>
	{
		const { callback } = this.props;
		callback('Cancel');
	}

	private _onClose = () =>
	{
		const { callback } = this.props;
		callback('Cancel');
	}

	public render()
	{
		const { isOpen } = this.props;
		const { layoutName, rows, draggingId, error, layoutAll } = this.state;
		return (
		<Modal show={ isOpen } onHide={ this._onClose } style={ {marginLeft: '20%', width: '60%'} }>
			<Modal.Header>
				<div>
					<h3 style={ {fontSize: '1.5em', textAlign: 'center' } }>{ L10n.Term('.LBL_AVAILABLE_CHOOSE_COLUMNS') }</h3>
				</div>
			</Modal.Header>
			<Modal.Body style={{ minHeight: '80vh', width: '60vw' }}>
				<div style={{ padding: '.5em', whiteSpace: 'nowrap' }}>
					<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave           }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'             ) }</button>
					<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel         }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL'           ) }</button>
					<div className='error' style={ {paddingLeft: '10px'} }>{ error }</div>
				</div>
				<div style={ {display: 'flex'} }>
					<div style={ {flex: '5 5 0', flexDirection: 'column', margin: '0 .5em', border: '1px solid grey', position: 'relative'} }>
						<h3 style={{ padding: '.25em', fontSize: '1.5em' }}>{ L10n.Term('.LBL_AVAILABLE_DISPLAYED') }</h3>
						<div style={ {height: '70vh', overflowY: 'scroll'} }>
							<div style={{ padding: '.5em' }}>
								{ rows[0].columns.map((ID, colIndex) => (
									<DraggableField
										item={ layoutAll[ID] }
										id={ 'row_' + ID }
										colIndex={ colIndex }
										rowIndex={ 0 }
										moveDraggableItem={ this.moveDraggableItem }
										setDragging={ this.setDragging }
										draggingId={ draggingId }
										rowTotal={ rows[0].columns.length}
									/>
								))
								}
							</div>
						</div>
					</div>
					<div style={{ flex: '5 5 0', flexDirection: 'column', margin: '0 .5em', border: '1px solid grey' }}>
						<h3 style={{ padding: '.25em', fontSize: '1.5em'  }}>{ L10n.Term('.LBL_AVAILABLE_HIDDEN') }</h3>
						<div style={ {height: '70vh', overflowY: 'scroll'} }>
							<div style={{ padding: '.5em' }}>
								<div style={ {width: '100%', border: '1px solid black'} }>
								{ rows[1].columns.map((ID, colIndex) => (
									<DraggableField
										item={ layoutAll[ID] }
										id={ 'row_' + ID }
										colIndex={ colIndex }
										rowIndex={ 1 }
										moveDraggableItem={ this.moveDraggableItem }
										setDragging={ this.setDragging }
										draggingId={ draggingId }
										rowTotal={ rows[1].columns.length}
									/>
								))}
								</div>
							</div>
						</div>
					</div>
				</div>
			</Modal.Body>
		</Modal>
		);
	}
}



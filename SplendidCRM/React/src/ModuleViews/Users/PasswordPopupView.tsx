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
import { RouteComponentProps, withRouter }            from 'react-router-dom'               ;
import { Modal }                                      from 'react-bootstrap'                ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome' ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'              ;
import L10n                                           from '../../scripts/L10n'             ;
import { Crm_Password }                               from '../../scripts/Crm'              ;
import { Trim }                                       from '../../scripts/utility'          ;
import SplendidCache                                  from '../../scripts/SplendidCache'    ;
import { AuthenticatedMethod, LoginRedirect }         from '../../scripts/Login'            ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../scripts/SplendidRequest'  ;
// 4. Components and Views. 
import ListHeader                                     from '../../components/ListHeader'    ;

interface IPasswordPopupViewProps extends RouteComponentProps<any>
{
	USER_ID             : string;
	callback            : Function;
	isOpen              : boolean;
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IPasswordPopupViewState
{
	defaultSearch      : any;
	error?             : any;
	IS_ADMIN           : boolean;
	OLD_PASSWORD       : string;
	NEW_PASSWORD       : string;
	CONFIRM_PASSWORD   : string;
}

class SplendidPassword
{
	TXT_INDICATORS_MIN_COUNT     : number =   2;  // Minimum number of textual descriptions
	TXT_INDICATORS_MAX_COUNT     : number =  10;  // Maximum number of textual descriptions.
	TXT_INDICATOR_DELIMITER      : string = ';';  // Text indicators are delimited with a semi colon

	public PreferredPasswordLength      : number = 6;
	public MinimumLowerCaseCharacters   : number = 1;
	public MinimumUpperCaseCharacters   : number = 0;
	public MinimumNumericCharacters     : number = 1;
	public MinimumSymbolCharacters      : number = 0;
	public PrefixText                   : string = "Strength: ";
	public TextStrengthDescriptions     : string = ";;;;;;";
	public SymbolCharacters             : string = "!@#$%^&*()<>?~.";
	public ComplexityNumber             : number = 2;

	public MessageRemainingCharacters   : string = null;
	public MessageRemainingNumbers      : string = null;
	public MessageRemainingLowerCase    : string = null;
	public MessageRemainingUpperCase    : string = null;
	public MessageRemainingMixedCase    : string = null;
	public MessageRemainingSymbols      : string = null;
	public MessageSatisfied             : string = null;

	public HelpText                     : string = '';

	constructor()
	{
		this.PreferredPasswordLength             = Crm_Password.PreferredPasswordLength            ;
		this.MinimumLowerCaseCharacters          = Crm_Password.MinimumLowerCaseCharacters         ;
		this.MinimumUpperCaseCharacters          = Crm_Password.MinimumUpperCaseCharacters         ;
		this.MinimumNumericCharacters            = Crm_Password.MinimumNumericCharacters           ;
		this.MinimumSymbolCharacters             = Crm_Password.MinimumSymbolCharacters            ;
		this.PrefixText                          = Crm_Password.PrefixText                         ;
		this.TextStrengthDescriptions            = Crm_Password.TextStrengthDescriptions           ;
		this.SymbolCharacters                    = Crm_Password.SymbolCharacters                   ;
		this.ComplexityNumber                    = Crm_Password.ComplexityNumber                   ;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor PreferredPasswordLength   ', this.PreferredPasswordLength   );
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor MinimumLowerCaseCharacters', this.MinimumLowerCaseCharacters);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor MinimumUpperCaseCharacters', this.MinimumUpperCaseCharacters);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor MinimumNumericCharacters  ', this.MinimumNumericCharacters  );
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor MinimumSymbolCharacters   ', this.MinimumSymbolCharacters   );
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor PrefixText                ', this.PrefixText                );
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor TextStrengthDescriptions  ', this.TextStrengthDescriptions  );
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor SymbolCharacters          ', this.SymbolCharacters          );
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ComplexityNumber          ', this.ComplexityNumber          );

		this.MessageRemainingCharacters          = L10n.Term("Users.LBL_PASSWORD_REMAINING_CHARACTERS");
		this.MessageRemainingNumbers             = L10n.Term("Users.LBL_PASSWORD_REMAINING_NUMBERS"   );
		this.MessageRemainingLowerCase           = L10n.Term("Users.LBL_PASSWORD_REMAINING_LOWERCASE" );
		this.MessageRemainingUpperCase           = L10n.Term("Users.LBL_PASSWORD_REMAINING_UPPERCASE" );
		this.MessageRemainingMixedCase           = L10n.Term("Users.LBL_PASSWORD_REMAINING_MIXEDCASE" );
		this.MessageRemainingSymbols             = L10n.Term("Users.LBL_PASSWORD_REMAINING_SYMBOLS"   );
		this.MessageSatisfied                    = L10n.Term("Users.LBL_PASSWORD_SATISFIED"           );

		if ( Sql.IsEmptyString(this.MessageRemainingCharacters) ) this.MessageRemainingCharacters = "{0} more characters"           ;
		if ( Sql.IsEmptyString(this.MessageRemainingNumbers   ) ) this.MessageRemainingNumbers    = "{0} more numbers"              ;
		if ( Sql.IsEmptyString(this.MessageRemainingLowerCase ) ) this.MessageRemainingLowerCase  = "{0} more lower case characters";
		if ( Sql.IsEmptyString(this.MessageRemainingUpperCase ) ) this.MessageRemainingUpperCase  = "{0} more upper case characters";
		if ( Sql.IsEmptyString(this.MessageRemainingMixedCase ) ) this.MessageRemainingMixedCase  = "{0} more mixed case characters";
		if ( Sql.IsEmptyString(this.MessageRemainingSymbols   ) ) this.MessageRemainingSymbols    = "{0} symbol characters"         ;
		if ( Sql.IsEmptyString(this.MessageSatisfied          ) ) this.MessageSatisfied           = "Nothing more required"         ;
	}

	private _getRegexCount(regex, testString: string): number
	{
		let cnt = 0;
		if ( testString != null && testString != '' )
		{
			var results = testString.match(regex);
			if ( results != null )
				cnt = results.length;
		}
		return cnt;
	}

	public IsValid(pwd: string): boolean
	{
		let sPasswordRequirements: string = '';
		pwd = Trim(pwd);
		let complexity: number = 0;

		//***********************************************
		// Length Criteria
		if ( pwd.length < this.PreferredPasswordLength )
			sPasswordRequirements = this.MessageRemainingCharacters.replace('{0}', (this.PreferredPasswordLength - pwd.length).toString());

		//***********************************************
		// Numeric Criteria
		// Does it contain numbers?
		if ( this.MinimumNumericCharacters > 0 )
		{
			let numbersRegex = new RegExp('[0-9]', 'g');
			let numCount = this._getRegexCount(numbersRegex, pwd);
			if ( numCount >= this.MinimumNumericCharacters )
			{
				complexity++;
			}
			else
			{
				if ( !Sql.IsEmptyString(sPasswordRequirements) )
					sPasswordRequirements += ", ";
				sPasswordRequirements += this.MessageRemainingNumbers.replace('{0}', (this.MinimumNumericCharacters - numCount).toString());
			}
		}

		//***********************************************
		// Casing Criteria
		// Does it contain lowercase AND uppercase Text
		if ( this.MinimumLowerCaseCharacters > 0 && this.MinimumUpperCaseCharacters > 0 )
		{
			let lowercaseRegex = new RegExp('[a-z]', 'g');
			let uppercaseRegex = new RegExp('[A-Z]', 'g');
			let numLower = this._getRegexCount(lowercaseRegex, pwd);
			let numUpper = this._getRegexCount(uppercaseRegex, pwd);
			if ( numLower > 0 || numUpper > 0 )
			{
				if ( this.MinimumLowerCaseCharacters > 0 && numLower >= this.MinimumLowerCaseCharacters )
				{
					complexity++;
				}
				else 
				{
					if ( !Sql.IsEmptyString(sPasswordRequirements) )
						sPasswordRequirements += ", ";
					sPasswordRequirements += this.MessageRemainingLowerCase.replace('{0}', (this.MinimumLowerCaseCharacters - numLower).toString());
				}
				if ( this.MinimumUpperCaseCharacters > 0 && numUpper >= this.MinimumUpperCaseCharacters )
				{
					complexity++;
				}
				else
				{
					if ( !Sql.IsEmptyString(sPasswordRequirements) )
						sPasswordRequirements += ", ";
					sPasswordRequirements += this.MessageRemainingUpperCase.replace('{0}', (this.MinimumUpperCaseCharacters - numUpper).toString());
				}
			}
			else
			{
				if ( !Sql.IsEmptyString(sPasswordRequirements) )
					sPasswordRequirements += ", ";
				sPasswordRequirements += this.MessageRemainingMixedCase.replace('{0}', (this.MinimumLowerCaseCharacters + this.MinimumUpperCaseCharacters).toString());
			}
		}
		else if ( this.MinimumLowerCaseCharacters > 0 || this.MinimumUpperCaseCharacters > 0 )
		{
			let mixedcaseRegex = new RegExp('[a-z,A-Z]', 'g');
			let numMixed = this._getRegexCount(mixedcaseRegex, pwd);
			if ( numMixed >= (this.MinimumLowerCaseCharacters + this.MinimumUpperCaseCharacters) )
			{
				complexity++;
			}
			else
			{
				if ( !Sql.IsEmptyString(sPasswordRequirements) )
					sPasswordRequirements += ", ";
				sPasswordRequirements += this.MessageRemainingMixedCase.replace('{0}', (this.MinimumLowerCaseCharacters + this.MinimumUpperCaseCharacters).toString());
			}
		}

		//***********************************************
		// Symbol Criteria
		// Does it contain any special symbols?
		if ( this.MinimumSymbolCharacters > 0 )
		{
			let symbolRegex = null;
			if ( this.SymbolCharacters != null && !Sql.IsEmptyString(this.SymbolCharacters) )
			{
				let _escapedSymbolCharacters = this.SymbolCharacters.replace(/([\\\^\$*+[\]?{}.=!:(|)])/g, '\\$1');
				symbolRegex = new RegExp('[' + _escapedSymbolCharacters + ']', 'g');
			}
			else
			{
				symbolRegex = new RegExp('[^a-z,A-Z,0-9,\x20]', 'g');  // related to work item 1034
			}
			
			let numCount = this._getRegexCount(symbolRegex, pwd);
			if ( numCount >= this.MinimumSymbolCharacters )
			{
				complexity++;
			}
			else
			{
				if ( !Sql.IsEmptyString(sPasswordRequirements) )
					sPasswordRequirements += ", ";
				sPasswordRequirements += this.MessageRemainingSymbols.replace('{0}', (this.MinimumSymbolCharacters - numCount).toString());
			}
		}
		// 02/20/2011 Paul.  If the password meets the complexity requiements, then ignore the other failures. 
		if ( pwd.length >= this.PreferredPasswordLength && complexity >= this.ComplexityNumber )
			sPasswordRequirements = '';
		this.HelpText = sPasswordRequirements;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.IsValid', sPasswordRequirements);
		return true;
	}
}

class PasswordPopupView extends React.Component<IPasswordPopupViewProps, IPasswordPopupViewState>
{
	private _isMounted   = false;
	private ctlNEW_PASSWORD_STRENGTH: SplendidPassword = null;
	private txtOLD_PASSWORD     = React.createRef<HTMLInputElement>();
	private txtNEW_PASSWORD     = React.createRef<HTMLInputElement>();
	private txtCONFIRM_PASSWORD = React.createRef<HTMLInputElement>();

	constructor(props: IPasswordPopupViewProps)
	{
		super(props);
		let defaultSearch: any = null;
		let IS_ADMIN: boolean = SplendidCache.AdminUserAccess('Users', 'edit') >= 0;
		this.ctlNEW_PASSWORD_STRENGTH = new SplendidPassword();
		this.state =
		{
			defaultSearch     ,
			IS_ADMIN          ,
			OLD_PASSWORD      : null,
			NEW_PASSWORD      : null,
			CONFIRM_PASSWORD  : null,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private _onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data): void => 
	{
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				let vwMain = null;
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data);
			}
		}
	}

	private _onOLD_PASSWORD_Changed = (e): void =>
	{
		this.setState(
		{
			OLD_PASSWORD: e.target.value,
			error: ''
		});
	}

	private _onNEW_PASSWORD_Changed = (e): void =>
	{
		this.ctlNEW_PASSWORD_STRENGTH.IsValid(e.target.value);
		this.setState(
		{
			NEW_PASSWORD: e.target.value,
			error: this.ctlNEW_PASSWORD_STRENGTH.HelpText
		});
	}

	private _onCONFIRM_PASSWORD_Changed = (e): void =>
	{
		this.setState(
		{
			CONFIRM_PASSWORD: e.target.value,
			error: ''
		});
	}

	private _onKeyDown = (event) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' )
		{
			this._onSave();
		}
	}

	private _onClose = () =>
	{
		const { callback } = this.props;
		callback();
	}

	private _onSave = async () =>
	{
		const { USER_ID, callback } = this.props;
		const { OLD_PASSWORD, NEW_PASSWORD, CONFIRM_PASSWORD } = this.state;
		if ( Sql.IsEmptyString(NEW_PASSWORD) )
		{
			this.setState({ error: L10n.Term('Users.ERR_ENTER_NEW_PASSWORD') });
		}
		else if ( Sql.IsEmptyString(CONFIRM_PASSWORD) )
		{
			this.setState({ error: L10n.Term('Users.ERR_ENTER_CONFIRMATION_PASSWORD') });
		}
		else if ( NEW_PASSWORD != CONFIRM_PASSWORD )
		{
			this.setState({ error: L10n.Term('Users.ERR_REENTER_PASSWORDS') });
		}
		else if ( !this.ctlNEW_PASSWORD_STRENGTH.IsValid(NEW_PASSWORD) )
		{
			this.setState({ error: this.ctlNEW_PASSWORD_STRENGTH.HelpText });
		}
		else
		{
			try
			{
				let obj: any = {};
				obj.USER_ID      = USER_ID     ;
				obj.OLD_PASSWORD = OLD_PASSWORD;
				obj.NEW_PASSWORD = NEW_PASSWORD;
				
				let sBody: string = JSON.stringify(obj);
				let res  = await CreateSplendidRequest('Rest.svc/ChangePassword', 'POST', 'application/json; charset=utf-8', sBody);
				let json = await GetSplendidResult(res);
				callback();
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', error);
				this.setState({ error: error.message });
			}
		}
	}

	public renderBody = () =>
	{
		const { error, OLD_PASSWORD, NEW_PASSWORD, CONFIRM_PASSWORD } = this.state;
		return (
		<React.Fragment>
			<ListHeader TITLE='Users.LBL_CHANGE_PASSWORD' />
			<div>
				<table style={ {width: '100%', border: 'none'} }>
					<tr>
						<td></td>
						<td>
							<span id='lblPasswordHelp' className='error'>{ error }</span><br />
						</td>
					</tr>
					{ SplendidCache.AdminUserAccess('Users', 'edit') < 0
					? <tr>
						<td className='dataLabel' style={ {width: '40%'} }>
							{ L10n.Term('Users.LBL_OLD_PASSWORD') }
						</td>
						<td className='dataField' style={ {width: '60%'} }>
							<input
								id='txtOLD_PASSWORD'
								type='password'
								autoComplete='off'
								size={ 25 }
								maxLength={ 50 }
								tabIndex={ 1 }
								value={ OLD_PASSWORD }
								onKeyDown={ this._onKeyDown }
								onChange={ (e) => this._onOLD_PASSWORD_Changed(e) }
								ref={ this.txtOLD_PASSWORD }
							/>
						</td>
					</tr>
					: null
					}
					<tr>
						<td className='dataLabel' style={ {width: '40%', whiteSpace: 'nowrap'} }>
							{ L10n.Term('Users.LBL_NEW_PASSWORD') }
						</td>
						<td className='dataField' style={ {width: '60%'} }>
							<input id='txtNEW_PASSWORD'
								type='password'
								autoComplete='off'
								size={ 25 }
								maxLength={ 50 }
								tabIndex={ 2 }
								value={ NEW_PASSWORD }
								onKeyDown={ this._onKeyDown }
								onChange={ (e) => this._onNEW_PASSWORD_Changed(e) }
								ref={ this.txtNEW_PASSWORD }
							/>
						</td>
					</tr>
					<tr>
						<td className='dataLabel' style={ {width: '40%', whiteSpace: 'nowrap'} }>
							{ L10n.Term('Users.LBL_CONFIRM_PASSWORD') }
						</td>
						<td className='dataField' style={ {width: '60%'} }>
							<input
								id='txtCONFIRM_PASSWORD'
								type='password'
								autoComplete='off'
								size={ 25 }
								maxLength={ 50 }
								tabIndex={ 3 }
								value={ CONFIRM_PASSWORD }
								onKeyDown={ this._onKeyDown }
								onChange={ (e) => this._onCONFIRM_PASSWORD_Changed(e) }
								ref={ this.txtCONFIRM_PASSWORD }
							/>
						</td>
					</tr>
					<tr>
						<td className='dataLabel' style={ {width: '40%'} }></td>
						<td className='dataField' style={ {width: '60%'} }></td>
					</tr>
				</table>
				<br />
				<table style={ {width: '100%', border: 'none'} }>
					<tr>
						<td align='center'>
							<button
								className='button'
								tabIndex={ 4 } 
								onClick={ this._onSave }
								style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
								{ L10n.Term('.LBL_SAVE_BUTTON_LABEL') }
							</button>
							&nbsp;
							<button
								className='button'
								tabIndex={ 5 } 
								onClick={ this._onClose }
								style={ {marginBottom: '.2em', marginLeft: '.5em'} }>
								{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }
							</button>
						</td>
					</tr>
				</table>
			</div>
		</React.Fragment>);
	}

	private _onShow = () =>
	{
		if ( this.txtOLD_PASSWORD.current != null )
		{
			this.txtOLD_PASSWORD.current.focus();
		}
		else if ( this.txtNEW_PASSWORD.current != null )
		{
			this.txtNEW_PASSWORD.current.focus();
		}
	}

	public render()
	{
		const { isOpen, isPrecompile } = this.props;
		if ( SplendidCache.IsInitialized )
		{
			if ( isPrecompile )
			{
				return this.renderBody();
			}
			else
			{
				return (
					<Modal
						show={ isOpen }
						onShow={ this._onShow }
						onHide={ this._onClose }
						autoFocus={ false }
						size='sm'
						style={ {width: '50%', marginLeft: '25%'} }
						centered
					>
						<Modal.Body style={{ margin: '15px' }}>
							{ this.renderBody() }
						</Modal.Body>
					</Modal>
				);
			}
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon='spinner' spin={ true } size='5x' />
			</div>);
		}
	}
}

export default PasswordPopupView;

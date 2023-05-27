/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
// 09/15/2019 Paul.  Adapted from @ckeditor/@ckeditor5-react

import * as React from 'react';

interface ICKEditorProps
{
	editor   : any;
	data?    : string;
	config?  : any;
	onChange?: Function;
	onInit?  : Function;
	onFocus? : Function;
	onBlur?  : Function;
	disabled?: boolean;
}

interface ICKEditorState
{
}

export default class CKEditor extends React.Component<ICKEditorProps, ICKEditorState>
{
	private editor       = null;
	private domContainer = React.createRef<HTMLDivElement>();

	constructor( props: ICKEditorProps )
	{
		super( props );
		// After mounting the editor, the variable will contain a reference to the created editor.
		// @see: https://ckeditor.com/docs/ckeditor5/latest/api/module_core_editor_editor-Editor.html
		//this.editor = null;
		//this.domContainer = React.createRef();
		this.state = 
		{
		};
	}

	// This component should never be updated by React itself.
	shouldComponentUpdate( nextProps: ICKEditorProps )
	{
		if ( !this.editor )
		{
			return false;
		}
		if ( this._shouldUpdateContent( nextProps ) )
		{
			this.editor.setData( nextProps.data );
		}
		if ( 'disabled' in nextProps )
		{
			// 05/09/2022 Paul.  isReadOnly has changed. 
			// this.editor.isReadOnly = nextProps.disabled;
			if ( nextProps.disabled )
			{
				this.editor.enableReadOnlyMode('splendid');
			}
		}
		return false;
	}

	// Initialize the editor when the component is mounted.
	componentDidMount()
	{
		this._initializeEditor();
	}

	// Destroy the editor before unmouting the component.
	componentWillUnmount()
	{
		this._destroyEditor();
	}

	public insertText(txt)
	{
		if ( this.editor )
		{
			// 05/18/2023 Paul.  EmailTemplates needs to insert Survey HTML. 
			if ( txt.indexOf('<') >= 0 )
			{
				// See: https://ckeditor.com/docs/ckeditor5/latest/builds/guides/faq.html#where-are-the-editorinserthtml-and-editorinserttext-methods-how-to-insert-some-content
				const viewFragment = this.editor.data.processor.toView( txt );
				const modelFragment = this.editor.data.toModel( viewFragment );
				this.editor.model.insertContent(modelFragment);
			}
			else
			{
				// https://ckeditor.com/docs/ckeditor5/latest/builds/guides/faq.html#where-are-the-editorinserthtml-and-editorinserttext-methods-how-to-insert-some-content
				this.editor.model.change( writer =>
				{
					writer.insertText(txt, this.editor.model.document.selection.getFirstPosition() );
				});
			}
		}
	}

	// Render a <div> element which will be replaced by CKEditor.
	render()
	{
		// We need to inject initial data to the container where the editable will be enabled. Using `editor.setData()`
		// is a bad practice because it initializes the data after every new connection (in case of collaboration usage).
		// It leads to reset the entire content. See: #68
		return (
			<div ref={ this.domContainer } dangerouslySetInnerHTML={ { __html: this.props.data || '' } }></div>
		);
	}

	_initializeEditor()
	{
		this.props.editor
		.create( this.domContainer.current , this.props.config )
		.then( editor =>
		{
			this.editor = editor;
			if ( 'disabled' in this.props )
			{
				// 05/09/2022 Paul.  isReadOnly has changed. 
				// editor.isReadOnly = this.props.disabled;
				if ( this.props.disabled )
				{
					editor.enableReadOnlyMode('splendid');
				}
			}
			if ( this.props.onInit )
			{
				this.props.onInit( editor );
			}
			const modelDocument = editor.model.document;
			const viewDocument = editor.editing.view.document;
			modelDocument.on( 'change:data', event =>
			{
				/* istanbul ignore else */
				if ( this.props.onChange )
				{
					this.props.onChange( event, editor );
				}
			});
			viewDocument.on( 'focus', event =>
			{
				/* istanbul ignore else */
				if ( this.props.onFocus ) {
					this.props.onFocus( event, editor );
				}
			});
			viewDocument.on( 'blur', event =>
			{
				/* istanbul ignore else */
				if ( this.props.onBlur )
				{
					this.props.onBlur( event, editor );
				}
			});
		} )
		.catch( error =>
		{
			console.error( error );
		});
	}

	_destroyEditor()
	{
		if ( this.editor )
		{
			this.editor.destroy()
				.then( () =>
				{
					this.editor = null;
				});
		}
	}

	_shouldUpdateContent( nextProps ) {
		// Check whether `nextProps.data` is equal to `this.props.data` is required if somebody defined the `#data`
		// property as a static string and updated a state of component when the editor's content has been changed.
		// If we avoid checking those properties, the editor's content will back to the initial value because
		// the state has been changed and React will call this method.
		if ( this.props.data === nextProps.data )
		{
			return false;
		}
		// We should not change data if the editor's content is equal to the `#data` property.
		if ( this.editor.getData() === nextProps.data )
		{
			return false;
		}
		return true;
	}
}


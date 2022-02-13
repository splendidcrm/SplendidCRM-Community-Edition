import ReplaceMenuProvider from './ReplaceMenuProvider';

let def: any =
{
	__depends__:
	[
		require('diagram-js/lib/features/popup-menu'),
		require('../replace')
	],
	__init__: [ 'replaceMenuProvider' ],
	replaceMenuProvider: [ 'type', ReplaceMenuProvider ]
};

export default def;

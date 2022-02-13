import PaletteProvider from './PaletteProvider';

let def: any =
{
	__depends__: 
	[
		require( 'diagram-js/lib/features/palette' ),
		require( 'diagram-js/lib/features/create' ),
		require( 'diagram-js/lib/features/space-tool' ),
		require( 'diagram-js/lib/features/lasso-tool' ),
		require( 'diagram-js/lib/features/hand-tool' ),
		require( 'diagram-js/lib/i18n/translate' ),
		require( 'bpmn-js/lib/features/global-connect' )
	],
	__init__: ['paletteProvider'],
	paletteProvider: ['type', PaletteProvider]
};

export default def;

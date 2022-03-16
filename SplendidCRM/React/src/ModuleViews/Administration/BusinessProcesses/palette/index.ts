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
		// 03/02/2022 Paul.  bpmn-js no longer includes global-connect after version 1.3.3.  Use version in diagram-js. 
		require( 'bpmn-js/lib/features/global-connect' )
	],
	__init__: ['paletteProvider'],
	paletteProvider: ['type', PaletteProvider]
};

export default def;

import BpmnReplace from './BpmnReplace';

let def: any =
{
	__depends__:
	[
		require('diagram-js/lib/features/replace'),
		require('diagram-js/lib/features/selection')
	],
	bpmnReplace: [ 'type', BpmnReplace ]
};

export default def;

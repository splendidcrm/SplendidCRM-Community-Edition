import BpmnRules from './BpmnRules';

let def: any =
{
	__depends__:
	[
		require('diagram-js/lib/features/rules')
	],
	__init__: [ 'bpmnRules' ],
	bpmnRules: [ 'type', BpmnRules ]
};

export default def;

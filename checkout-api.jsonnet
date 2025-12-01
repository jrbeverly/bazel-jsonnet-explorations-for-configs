local render = import 'lib/render.libsonnet';
local intent = import 'inputs/checkout-api.libsonnet';

local result = render.emit(intent);

{
  'checkout-api.json': result.config,
  'checkout-api.provenance.json': result.provenance,
}

local render = import 'lib/render.libsonnet';
local intent = import 'inputs/ingest-pipeline.libsonnet';

local result = render.emit(intent);

{
  'ingest-pipeline.json': result.config,
  'ingest-pipeline.provenance.json': result.provenance,
}

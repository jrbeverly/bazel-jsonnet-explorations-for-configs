local render = import 'lib/render.libsonnet';
local intent = import 'inputs/report-exporter.libsonnet';

local result = render.emit(intent);

{
  'report-exporter.json': result.config,
  'report-exporter.provenance.json': result.provenance,
}

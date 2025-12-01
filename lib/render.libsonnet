local validate = import 'validate.libsonnet';
local conventions = import 'conventions.libsonnet';
local workloadClasses = import '../reference-data/workload-classes.libsonnet';
local environments = import '../reference-data/environments.libsonnet';

{
  emit(intent)::
    assert validate.check(intent);
    local derived = conventions.resolve(intent, workloadClasses, environments);
    {
      config: {
        service: intent.name,
        environment: intent.environment,
        region: derived.region,
        resources: derived.resources,
      },
      provenance: {
        intentSource: 'inputs/' + intent.name + '.libsonnet',
        workloadClass: intent.workloadClass,
        environment: intent.environment,
        derived: derived.provenance,
      },
    },
}

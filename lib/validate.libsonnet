local validClasses = ['high-throughput', 'latency-sensitive', 'batch'];
local validEnvs = ['staging', 'prod'];

{
  check(intent)::
    assert std.objectHas(intent, 'name') : 'intent missing required field: name';
    assert std.objectHas(intent, 'workloadClass') : 'intent missing required field: workloadClass';
    assert std.objectHas(intent, 'environment') : 'intent missing required field: environment';
    assert std.member(validClasses, intent.workloadClass) :
      'unknown workloadClass "' + intent.workloadClass + '"; must be one of: ' + std.join(', ', validClasses);
    assert std.member(validEnvs, intent.environment) :
      'unknown environment "' + intent.environment + '"; must be one of: ' + std.join(', ', validEnvs);
    true,
}

{
  resolve(intent, workloadClasses, environments)::
    local class = workloadClasses[intent.workloadClass];
    local env = environments[intent.environment];
    local replicas = std.min(class.replicas.min * env.replicaMultiplier, class.replicas.max);
    {
      region: env.region,
      resources: {
        cpu: class.cpu.min,
        memory: class.memory.min,
        replicas: replicas,
      },
      provenance: {
        region: { source: 'reference-data/environments', value: env.region },
        cpu: { source: 'reference-data/workload-classes', convention: 'class.cpu.min', value: class.cpu.min },
        memory: { source: 'reference-data/workload-classes', convention: 'class.memory.min', value: class.memory.min },
        replicas: { source: 'lib/conventions', convention: 'min(class.replicas.min * env.replicaMultiplier, class.replicas.max)', value: replicas },
      },
    },
}

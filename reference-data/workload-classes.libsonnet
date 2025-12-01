{
  'high-throughput': {
    cpu: { min: 2, max: 16 },
    memory: { min: '4Gi', max: '32Gi' },
    replicas: { min: 3, max: 24 },
  },
  'latency-sensitive': {
    cpu: { min: 1, max: 4 },
    memory: { min: '2Gi', max: '8Gi' },
    replicas: { min: 2, max: 6 },
  },
  batch: {
    cpu: { min: 1, max: 8 },
    memory: { min: '8Gi', max: '64Gi' },
    replicas: { min: 1, max: 3 },
  },
}

# hands-on-gatekeeper
A repository to learn how to work with gatekeeper through gator.

In this workshop you will learn to write gatekeeper policies using _constraints_ and _constraint templates_.
You successfully implemented all policies once the following command completes without test failures:

```
gator verify ./test/...
```

## Your first constraint: forcing users to define a backup policy for volumes

Your cluster uses velero.io to periodically make snapshots of volumes you use in the k8s cluster.
Instead of asking every owner of each volume what the fitting backup schedule and retention is you want to make sure that each owner of a volume decides which backup schedule should be applied.
Hence, you define backup schedules for volumes based on the used labels on the persistent volume (`default`, `daily`, `hourly`).
Example:

```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: velero-default-daily-backup
  namespace: velero
spec:
  schedule: "0 22 * * 0-5"
  template:
    labelSelector:
      matchLabels:
        qaware.de/backup: default # any volume labeled this way will be backed up daily
    snapshotVolumes: true
    storageLocation: default
    ttl: 336h
```

Additionally you want to allow `none` in case no schedule should be applied, e.g. because the volume is only required for temporary data.

Define a constraint that fulfills the requirements unsing the constraint template of `constrainttemplates/required-labels.yaml`.
Edit `constraints/pvc-backup-policy.yaml` so that the following command returns no test failures:

```
gator verify ./test/pvc-backup-policy/
```

## Task 2

## Task 3

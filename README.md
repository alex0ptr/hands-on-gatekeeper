# hands-on-gatekeeper

A repository to learn how to work with gatekeeper through gator.

In this workshop you will learn to write gatekeeper policies using _constraints_ and _constraint templates_.

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

```shell
gator verify ./test/pvc-backup-policy/
```

<details>
<summary>Cheat</summary>

```shell
git diff main solution constraints/pvc-backup-policy.yaml
```
</details>

## Writing a constraint template: force recommended container resources

As a k8s you are aware that setting container resources makes sense, secifically:

1. Setting requests helps the scheduler decide on which pods to schedule your pod -> users should define requests.
2. Setting different values for memory requests than limit might lead to overprovisioned nodes and may cause out of memory crashes -> users should make sure `requests.memory == limits.memory`.
3. [Setting cpu limits rarely makes sense](https://home.robusta.dev/blog/stop-using-cpu-limits) -> setting none is desired in most cases.

Help the users of your cluster by defining polcies.
Implement a constraint template that can be applied to enforce your recommendations.
Edit `constrainttemplates/enforce-container-resources.yaml` so that the following command returns no test failures:

```shell
gator verify ./test/enforce-container-resources/
```

<details>
<summary>Cheat</summary>

```shell
git diff main solution constrainttemplates/enforce-container-resources.yaml
```
</details>

## Advanced rego: write complex policies using library functions

You are using nginx ingress and want to make sure users can not define ingresses that expose to non-approved networks without your explicit consent.
Normally users can override the default whitelisting by defining [an annotaiton](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#whitelist-source-range).

Define a constraint template that allows restricting this annotation to known cidrs defined in the constraint as a parameter.
Edit `constrainttemplates/require-approved-cidrs-on-ingress-whitelist.yaml` so that the following command returns no test failures:

```shell
gator verify ./test/required-cidr-whitelist-ingress/
```


<details>
<summary>Cheat</summary>

```shell
git diff main solution constrainttemplates/require-approved-cidrs-on-ingress-whitelist.yaml
```
</details>

## Finish

You successfully implemented all policies once the following command completes without test failures:

```shell
gator verify ./test/...
```

# Lagoon Rootless migration test scripts

This repository contains scripts for testing migration of the shared (`RWX`) persistent kubernetes storage from Lagoon workloads running as root to Lagoon workloads running as a non-root user.

## How it works

There are three nginx deployment templates:
* `root` emulates a Lagoon workload running as root with a mounted `RWX` volume. It creates an example directory tree in the mounted volume.
* `broken` emulates a Lagoon workload running as root, and messes with the file ownership and permissions on the storage volume. Inspiration for this is taken from how we have seen workloads break in production.
* `rootless` emulates a Lagoon workload running rootless, and contains an `initContainer` with a script designed to fix up file permissions on the storage volume.

The "fix up" logic in the `rootless` `initContainer` is designed to make the ownership and permissions and ownership of files pre-existing before the migration to `rootless` match the default permissions and ownership of files created post-migration.

## How to use

The `Makefile` orchestrates all the testing and prints results to `stdout`.
Run it like so in a test namespace on your Kubernetes cluster:

```
(make broken; make rootless; make clean) | tee /tmp/test.log
```

This will:

* create a "broken" deployment with messed up file permissions/ownership, printing the file tree to `stdout`.
* convert the deployment to rootless, converting the storage volume permissions/ownership in the process.
* clean up by removing the deployment and PVC.

Things to look for when checking permissions and ownership in the output:

* `newfile` permissions and ownership should match `oldfile`.
* `new/dir` permissions and ownership should match `foo/bar`.
* other file and directory permissions are homogeneous.
* any errors from the `touch`/`mkdir`/`chmod`/`rm` commands in the rootless container.

## Results

Results for three major hosted Kubernetes services are provided.


* [EKS](./test-results/eks.log) (using the deprecated in-tree EFS provisionser) - passes tests.
* [GKE](./test-results/gke.log) - passes tests.
* [AKS](./test-results/aks.log) - does not fully pass tests. Unfortunately because the AKS `RWX` storage implementation enforces `root` ownership of files, which means that `chmod` is not possible, and returns an error. Other operations work though.

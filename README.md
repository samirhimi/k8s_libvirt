# kubernetes cluster

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)

## About <a name = "about"></a>

Deploying a Kubernetes cluster using Vagrant and Libvirt provides an efficient way to simulate a production-like environment on a local machine for development, testing, or learning purposes. Vagrant, a tool for creating and managing virtualized development environments, works seamlessly with Libvirt, a virtualization API, to spin up virtual machines (VMs) that act as the nodes of the Kubernetes cluster. This method is especially useful for developers who want to experiment with Kubernetes setups, deploy multi-node clusters, and test various configurations without relying on cloud providers or large infrastructure. It offers flexibility in replicating different cluster architectures in a lightweight, reproducible manner.

By leveraging Vagrant’s simplicity and Libvirt’s virtualization capabilities, users can create isolated environments that mimic real-world scenarios, enabling the testing of Kubernetes features such as networking, storage, and workload management. Additionally, this setup can be integrated into CI/CD pipelines to verify application behavior in a controlled, Kubernetes-based environment.
## Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites

Ensure that your system supports virtualization
check with 
```
egrep -c '(vmx|svm)' /proc/cpuinfo
```
and that virtualization is enabled in the BIOS.

To deploy a Kubernetes cluster using Vagrant and Libvirt, you'll need to install several components to set up the virtualized environment and Kubernetes cluster. Here’s a list of the necessary software and steps for installation:

```
sudo apt-get update
```

### Installing

Vagrant is a tool for building and managing virtualized environments.

Install vagrant

```
sudo apt-get install vagrant
```
Install libvirt and kvm


```
sudo apt-get install libvirt-bin qemu-kvm
```
Install vagrant-libvirt plugin for vagrant
```
vagrant plugin install vagrant-libvirt
```


## Usage <a name = "usage"></a>

```
vagrant validate
vagrant up
```



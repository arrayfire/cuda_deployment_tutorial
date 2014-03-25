# Deploying CUDA

Scripts to generate Debian-based CUDA-enabled containers linked together with
the SLURM job manager. Tutorial given at GPU Technology Conference 2014. See
[the slides](slides.html) for a detailed
explanation. [Markdown source](slides.md) for the slides is included.

> Note that these scripts do not constitute a production configuration, but
> rather serve as a reference for building small scale CUDA clusters and
> running CUDA applications within LXC containers.

## Requirements

* Firewalled test machine
* CUDA hardware
* CUDA installed at `/usr/local/cuda`
* Access as root

## Quickstart

As root, on a __preferably firewalled__ machine ,

```bash
./host_install.sh
./host_ready.sh
./install_cuda_node 0
./install_cuda_node 1
./install_cuda_node 2
./install_cuda_node 3
(cd /usr/local/cuda/samples/0_Simple/matrixMul && make)
ssh -i id_rsa root@10.0.3.2    # or use password reported by install_cuda_node
srun /usr/local/cuda/samples/0_Simple/matrixMul/matrixMul
```

If during `install_cuda_node`, ssh requests a password, ensure that the cloned
repository directory is owned by root and has permissions 700.

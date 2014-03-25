# Deploying CUDA

Gallagher Pryor


# Outline

* Best Practices, Philosophy
* __Hands On__: Building a Virtual GPU Cluster with LXC Containers and Slurm
* __Hands On__: Deploying a GPU Web App with Containers
* To follow along,
    * Clone: [https://github.com/arrayfire/cuda_deployment_tutorial](https://github.com/arrayfire/cuda_deployment_tutorial)


# Defining Deployment

* Application is written, optimization and testing complete.
* To where is your application destined?
    * End User Installation
    * Private Cluster
    * Cloud / Colocation


# Deployment Issues per Destination

* End User Installation (hardest)
    * Supporting Older Devices
    * Detecting Device Capability
    * Building and Linking, Dynamic vs. Static
    * Distribution
* Private Cluster
    * Job Managers...
* Cloud / Colocation / That Internet Thing
    * Virtualization... pricing... availability...


# End User Installation

* Overview
    * Detecting Device Capability
    * Building and Linking, Dynamic vs. Static
    * Distribution


# Deploying to a Private Cluster

* Deploying to a cluster implies,
    * Running at Scale
        * Best Practices
        * Continuous Integration
    * Job Scheduling
    
* Both require special considerations 


# Running at Scale

* Software design must have long run times in mind
    * Development Platform should == Deployment Platform
    * Keep it simple!
    * Test Driven Development

* Be prepared for spooky behavior due to outside influences, e.g.,
    * Infamous Power Story
    * Framebuffers live on the GPU, too
    
* Use Linux if you value your time, sanity, etc.


# Running at Scale

* Continuous Integration (CI) Is A Must
    * [Jenkins](http://jenkins-ci.org)
    * [Concrete.js](https://github.com/ryankee/concrete)
    
    
# CI Best Practices

* Run as many/different test hardware platforms as possible
* Run tests often to detect non-determinism
* Intentionally schedule jobs to abuse your test cluster
* Don't manage your cluster with your CI tool
    * Good combination: Jenkins + SLURM
* Keep as much configuration out of your CI tool as possible


# Job Scheduling

* GPUs are resources that need management just like CPUs!
* Many schedulers are GPU aware - - we will cover __Slurm__.
* Others,
    * Moab / Torque
    * IBM Platform LSF
    * Altair PBS Professional
    * Grid Engine
    * Open Grid Scheduler
    
    
    

# Deploying to the Cloud

* Why?
    * Web Applications / Services
    * Share Resources
* Two major (non-exclusive) approaches we will talk about,
    * Amazon EC2
    * Containers
        * LXC [https://linuxcontainers.org/](https://linuxcontainers.org/)
        * Docker.io [http://docker.io](http://docker.io)


# Amazon EC2

* Use this to scale; may not be effective for fixed deployments.
* EC2 CPU Pricing:
    * __m3.medium__: (2x3 ECUs, 3.75G ram, $0.113 / hour)
    * __c3.large__: (2x7 ECUs, 3.75G ram, $0.150 / hour)
    * __c3.8xlarge__: (32x108 ECUs, 60G ram, $2.40 / hour)
* EC2 GPU Pricing:
    * __g2.2xlarge__: (8x26 ECUs, 15G ram, 1536 GPU cores, $0.65 / hour)
    * __cg1.4xlarge__: (32x33.5 ECUs, 22G ram, 448 GPU cores, $2.10 / hour)


# Amazon EC2

* Cheapest GPU instance __5x__ pricier than CPU m3.medium.
* __g2.2xlarge__ vs __cg1.4xlarge__:
    * 1/4 CPU for 1/4 the cost
    * < 1/10 storage, 1/4 memory
    * __If you can leverage GPU, it's worth it for compute__
* It's all about experimentation in the end, however

        
# Amazon EC2

* GPU Instances Available
    * g2.2xlarge: Kepler GK104 (4Gb, 1536 cores, GRID, $0.65 / hour)
        * Compute / Streaming Graphics
        * CPU: Intel Xeon E5-2670 (8x26 ECUs, 15Gb RAM, 12867 PM)
        * 5 max on demand, 10 max spot
    * cg1.4xlarge: 2 Fermi GF100 (3Gb, 996 cores, $2.10 / hour)
        * Compute Workhorse
        * CPU: Intel Xeon X5570 (32x33.5 ECUs, 22Gb RAM, 5486 PM)
        * 2 max on demand, 10 max spot


# Amazon EC2

* GPU instances only available in certain geographic regions
    * Place your instances wisely!
    * In our experience, availability varies for these large instances
* NVIDIA supplies a free AMI
    * You can roll your own by installing a driver
* Can only tie a few of these to your account
* Not eligible for free tier


# Hands On: GPU Slurm Cluster

* Follow along via: [https://github.com/arrayfire/cuda_deployment_tutorial](https://github.com/arrayfire/cuda_deployment_tutorial)

<br>

* __Tutorial: Set up a Slurm Cluster!__
    * GPU enabled compute containers with LXC
    * GPU enabled Slurm Config
    * Getting to know Slurm and CUDA
    
<br>

* Why Slurm? Simple, Packaged by Debian, GPU support


# Virtualization: Containers

* Many Different Forms of Virtualization
    * Full Virtualization
    * Paravirtualization
    * Containers

* Containers happen to work well with CUDA if you know how to configure them
  correctly, as we shall see.


# Containers

* Not a New Idea (demo)
    * [LXC's website](https://linuxcontainers.org/) has a great description

* Advantages,
    * Add safety to GPU-Enabled Web Apps
    * Share Resources
    * Scalable Devops!

* Linux Container Support is Very New
    * [LXC](https://linuxcontainers.org/): 1.0 Released March 6th, 2014
    * [Docker](http://docker.io): 0.9 Released March 10th, 2014


# First Up: LXC

* There are two flavors in the wild
    * 0.8 shipped with Debian (most common)
    * 1.0 (frozen api) - bleeding edge
    
* We'll be working with 0.8
    * Debian is rock solid - - highly recommended
    * Feature set in parity with most AMI's on EC2


# 1 - LXC Installation

* You'll Need a Debian Machine or similar
    * [Debian Wheezy](http://www.debian.org/distrib/)
    * [Amazon EC2 AMI](https://aws.amazon.com/marketplace/pp/B00AA27RK4/ref=ads_5e90c49c-40af-1395672136)

* Install Required Packages (__host_install.sh__ in repo)

```bash
sudo apt-get install -y lxc bridge-utils
```

# 2 - Prepare the Host

* __cgroup__ must be mounted (__host_ready.sh__ in repo),

```bash
mkdir -t cgroup cgroup cgroup
```

# 3 - First Container

* Install Debian and boot,

```bash
lxc-create -n debian -t debian
lxc-start -n debian -d   # boot container to (-d) background
```

* While booting, there should be a CPU load spike
* Get status,

```bash
lxc-list
ls /var/lib/lxc
```


# 3 - First Container

* Attempt to log in,

```bash
lxc-console -n debian
# username: root, password: root
```

* All alone with no networking,

```bash
top
ifconfig
```

* Detach via __Ctrl-a__ followed by __q__

* Make a clone,

```bash
lxc-clone debian debian_clone
lxc-list
```

# 3 - First Containers

* Note: snapshots and other features are possible with proper filesystem
  support.

* Clean the slate,

```bash
lxc-destroy -n debian -f   # destroy even if running (-f)
lxc-destroy -n debian_clone
```


# 4 - Networking

* From here on out, we'll be relying with the tutorial materials on the
  [ArrayFire](http://arrayfire.com) GitHub,

```bash
git clone https://github.com/arrayfire/cuda_deployment_tutorial
```

* The provided scripts constitute modified LXC scripts and container templates,
    * __lxc_create__: LXC creation script that reads templates out of the CWD
    * __lxc-debian-static__: Custom Debian template script that configures a
      static ethernet address matching the __ADDR__ environment variable.


# 4 - Networking

* Lets make containers useful with some networking!

* Two Useful Networking Types
    * __veth__: two ended pipe between host and each container
        * host sees exactly one interface per container
        * containers talk to outside and each other via NAT through host bridge
    * __macvlan bridged__: common network for all associated containers
        * host does not communicate with containers
        * containers may not communicate with outside world

* Each networking type is always associated with a host-side bridge.



# 4 - LXC Networking

* For our purposes, we want the following situation,

<center>![](web/network.svg)</center>


# 4 - LXC Networking

* __macvlan__ allows intercontainer communication whereas __veth__ and NAT
  allow host, internet, and container communication.

<center>![](web/network.svg)</center>

# 4 - LXC Networking

* Based off of an excellent container ops article, [http://containerops.org/2013/11/19/lxc-networking/](http://containerops.org/2013/11/19/lxc-networking/)

<center>![](web/network.svg)</center>


# 4 - LXC Networking

* Setup the two bridges, __br0__ and __br1__, on the host (as root),

```bash
# Bridge: br0, IP: 10.0.3.1
brctl addbr br0
ifconfig br0 10.0.3.1/24
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A POSTROUTING -s 10.0.3.0/24 -t nat -j MASQUERADE

# Bridge: br1, IP: none
brctl addbr br1
ifconfig br1 up
```

* See __host_ready.sh__ in repo.


# 4 - LXC Networking

* Containers are generated as subdirectories of __/var/lib/lxc/__
    * Root filesystem at __/var/lib/lxc/\<name\>/rootfs__
    * Runtime configuration at __/var/lib/lxc/\<name\>/config__ (man lxc.conf)

<br>
    
* Both are entirely built from scratch via shell scripts
    * Stock shell scripts at __/usr/share/lxc/templates__
    * We've modified the Debian template script to enable networking - see
      __lxc-debian-static__ from repo.


# 5 - Custom Container Template

* Unlike the stock debian template, __lxc-debian-static__ configures a static
  IP addresses for two interfaces...

```diff
+ [ -z "$ADDR" ] && ADDR=10.0.3.2
+

- iface eth0 inet dhcp
+ iface eth0 inet static
+   address $ADDR
+   netmask 255.255.255.0
+   gateway 10.0.3.1
```

# 5 - Custom Container Template

* ... ensures generation of a random MAC address for __macvlan__...

```diff
+ # random hwaddr for maclvan entry
+ nics=`grep -e '^lxc\.network\.type[ \t]*=[ \t]*macvlan' $path/config | wc -l`
+ if [ $nics -eq 1 ]; then ... ; fi
```

* ... and mounts the current directory at __/root__ for convenience...

```diff
+ lxc.mount.entry = $PWD $rootfs/root none bind,user 0 0
```

# 6 - Custom LXC Configuration

* Containers configured on instantiation via file (see __config__ in repo),

```bash
# appended to /var/lib/lxc/<container>/config on container generation

# net
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0

# macvlan
lxc.network.type = macvlan
lxc.network.macvlan.mode = bridge
lxc.network.flags = up
lxc.network.link = br1
lxc.network.ipv4 = __IP__   # change __IP__ to known unique IP address
```


# 7 - Fire Up the Network

* (From the repo) Invoke the custom template via __lxc-create__ in tandem with
  the modified template,

```bash
ADDR=10.0.3.2 ./lxc-create -n c000 -f config -t debian-static
lxc-start -n c000 -d
```

* Once up, we can __ssh__ into the newly created container,

```bash
ssh root@10.0.3.2   # IP convention given in previous diagram
```

* Clean the slate when done...

```bash
lxc-destroy -n c000 -f
```


# 8 - Custom CUDA Template

* See __config_cuda__ in repo.

* Ensure that container filesystem contains device nodes, can access the
  host's __/usr/local/cuda__, and copy __libcuda.so__ to __/usr/lib__...
  
```diff
+ # gpu devices
+ mknod $rootfs/dev/nvidia0 c 195 0
+ chmod a+rw $rootfs/dev/nvidia0
+ mknod $rootfs/dev/nvidiactl c 195 255
+ chmod a+rw $rootfs/dev/nvidiactl
+
+ # cuda home
+ mkdir -p $rootfs/usr/local/cuda
+
+ # cuda libs
+ cp -d /usr/lib/libcuda* $rootfs/usr/lib
+ chmod u=rwx,og=rx $rootfs/usr/lib/libcuda*
```


# 9 - CUDA Configation

* See the file, __config_cuda__ from repo.

* Configure LXC to allow access to NVIDIA character device nodes with major
  number 195,

```bash
# cuda
lxc.cgroup.devices.allow = c 195:* rwm
```

# 10 - Create a CUDA Container

* From the GitHub repo,

```bash
ADDR=10.0.3.2 ./lxc-create -n c000 -f config_cuda -t debian-cuda
lxc-start -n c000 -d
```

* Once up, we can __ssh__ into the newly created container,

```bash
ssh root@10.0.3.2   # IP convention given in previous diagram
```

* Run some CUDA!

```bash
# after having build the matrixMul example from the host...
cd /usr/local/cuda/samples/0_Simple/matrixMul
./matrixMul
```

# 10 - Configure Slurm

* See __slurm_setup__ in repo for required debian packages, munge key, and NTP
  setup. Nothing needs modification in this file.
* See __install_cuda_node__ for full, automated container node generation
  including Slurm.

# 10 - Slurm Name Resolution

* Name resolution is required for Slurm to function (see
  __install_cuda_node__ in repo),

```bash
cat >> /etc/hosts < EOF
10.0.3.1     bridge
10.0.5.1     c000
10.0.5.2     c001
10.0.5.3     c002
10.0.5.4     c003
EOF
```

# 11 - Slurm Configuration

* Slurm configuration is at __slurm.conf__ in repository (should finally
  reside at __/etc/slurm-llnl/slurm.conf__).
  
* Slurm allows configuring custom resource types such as GPUs via Generic
  Resource Scheduling (GRES),

```bash
GresTypes=gpu
```

* We'll be configuring a maximum four nodes for this tutorial, each with one
  GPU (but actually sharing one GPU for the purposes of this tutorial),

```bash
# node configuration
NodeName=c[000-003] Gres=gpu:1 CPUs=1 State=UNKNOWN
PartitionName=tutorial Nodes=c[000-003] Default=YES MaxTime=INFINITE State=UP Shared=YES
```

# 12 - Slurm Configuration

* GRES types require per-node configuration, e.g.,

```bash
# Specify GPUs as resources, bind files, associated CPUs
Name=gpu File=/dev/nvidia0 CPUs=0,1
Name=gpu File=/dev/nvidia1 CPUs=0,1
Name=gpu File=/dev/nvidia2 CPUs=2,3
Name=gpu File=/dev/nvidia3 CPUs=2,3
```

* For our purposes, we'll keep it simple,

```bash
Name=gpu File=/dev/nvidia0
```


# 13 - Fire Up A Cluster

* From the GitHub repo,

```bash
./install_cuda_node 0
./install_cuda_node 1
./install_cuda_node 2
./install_cuda_node 3
# or, for I in {0..3} ; do ./install_cuda_node $I & done ; wait
```

# 14 - Run with Slurm & CUDA!

* Check cluster status with,

```bash
sinfo
```

* Run a test job across the nodes,

```bash
srun -N* hostname    # -N*, all available nodes
```

* Run a CUDA job on a random node,

```bash
srun /usr/local/cuda/samples/0_Simple/matrixMul/matrixMul
```

* Run two CUDA jobs,

```bash
srun -n2 /usr/local/cuda/samples/0_Simple/matrixMul/matrixMul
```

# 15 - Explicitly Run a GPU Job

* Explicitly state that a job requires one GPU,

```bash
srun --gres=gpu:1 /usr/local/cuda/samples/0_Simple/matrixMul/matrixMul
```

* We have no nodes with two GPUs, so that following will fail,

```bash
srun --gres=gpu:2 -n2 /usr/local/cuda/samples/0_Simple/matrixMul/matrixMul
```

# Cloud / Web Deployment

* Enable outside net connections via iptables,

<center>![](web/network.svg)</center>

```bash
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 7000 -j DNAT --to-destination 10.0.3.2:8080
```

# Why GPU Web Application?

* Interactive GPU enabled web app demo.

# A Simple Web Application

* Node.js is the simplest way to get traction,

```bash
# in container...
apt-get install nodejs npm
mkdir app
cd app ; npm install express   # overkill
```

# A Simple Web Application

```javascript
var express = require('express'), app = express();
var spawn = require('child_process').spawn;

app.configure(function(){
    app.use(express.methodOverride());
    app.use(express.errorHandler({dumpExceptions: true, showStack: true}));
});

app.listen(9090);

/* run cuda to do work after upload */
function on_visit(req, res) {
  var child = spawn('/usr/local/cuda/samples/0_Simple/matrixMul/matrixMul');

  var output = '';
  child.stdout.on('data', function(data) { output += data; });
  child.on('close', function (code) { res.end(output); });
}
app.get('/', on_visit);
```

# Thank You

* I hope that you find the materials and talk useful!
* Questions? Comments?

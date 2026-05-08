# Week 8 Homework - MIG & LOAD BALANCING

#Q & A

-What is the difference between high availability and fault tolerance? Which is best to strive for?

High availability minimizes downtime but allows short interruptions, while fault tolerance eliminates downtime entirely; most companies aim for high availability because it's cheaper and easier, saving fault tolerance for critical systems like banking or emergency services.


-Explain the difference between autoscaling and elasticity. What is vertical and horizontal autoscaling? Is one better? Are they feasible on prem?

Elasticity is the ability to grow or shrink resources based on demand, and autoscaling is the tool that makes that happen automatically; vertical scaling upgrades a single machine with more CPU or RAM but has limits and may require downtime, whereas horizontal scaling adds more machines and is the preferred, more flexible approach for cloud systems, though both methods are possible on-premises even if horizontal scaling requires buying physical hardware.


-Explain what the difference between managed and unmanaged instance groups is.

The difference between managed and unmanaged instance groups is distinct. Managed instance groups use the capacity of the cloud to auto-heal, auto-scale, and update on the fly. All VMs come from the same instance template. Unmanaged instance groups have more flexibility, fewer features, and more control. VMs can be different from each other, making them useful for legacy apps that cannot be distributed.


-Explain the different use cases for health checks used by applications (in instance groups) and health checks used by load balancers. Can they be the same? Are they different API calls? Should they be the same?

A load balancer health check decides whether a VM should receive traffic and reacts quickly to protect users, while a managed instance group health check decides whether to replace a failed VM entirely and waits longer to avoid unnecessary restarts; they can use the same endpoint but are usually configured separately because their purposes are different.


-Explain in a few sentences what the 3-tier architecture is and how it relates to what you are learning.

3-tier architecture separates an application into presentation, application, and database layers, and in cloud computing this separation makes systems easier to scale, secure, and manage, typically using load balancers and managed instance groups to automatically scale the application layer based on demand.



#Runbook
-Purpose:
Goal is to spin up a fully configured Managed Instance Group in GCP console with autoscaling and autohealing enabled, distributed across multiple zones in us-central1.

-Prerequisites:
- GCP project with Compute Engine API enabled
- VPC and subnet in `us-central1` (or use default VPC)
- Compute Admin IAM role

-Step 1 — Create a Health Check

Health check must exist before the MIG so autohealing has something to reference.

Compute Engine > Health Checks > Create
- Name: `weekgr8-health-check`
- Protocol: `HTTP` | Port: `80` | Path: `/`
- Check interval: `10s` | Unhealthy threshold: `3`

-Step 2 — Create an Instance Template

Compute Engine > Instance Templates > Create
- Name: `weekgr8-template`
- Machine type: `n2-standard-2`
- Boot disk: CentOS Stream 10, `100 GB`
- Network: your VPC or default
- Network tag: `http-server`

-Step 3 — Create the Managed Instance Group

Compute Engine > Instance Groups > Create > New managed instance group (stateless)
- Name: `weekgr8-mig`
- Template: `weekgr8-template`
- Location: **Multiple zones** | Region: `us-central1` | leave zones as default
- Autoscaling: **On** | Signal: CPU | Target: `60%` | Min: `2` | Max: `5`
- Autohealing: select `weekgr8-health-check` | Initial delay: `300s`

Click **Create**.

-Step 4 — Verify Multi-Zone Distribution

Compute Engine > Instance Groups > week8-mig > Instances tab

Confirm instances appear in different zones (`us-central1-a`, `us-central1-b`, `us-central1-c`). Multi-zone is set at creation and cannot be changed after the fact.

-Critical Notes

- Health check must be created before the MIG — autohealing can't be configured without one
- Set initial delay high enough to cover startup script runtime — too low and the MIG will replace instances that are still booting
- Multi-zone location is immutable after creation
Runbook: Create Managed Instance Group via ClickOps


- Create a fully configured regional MIG with autoscaling and autohealing using your weekgr8-vpc-network VPC.
- Deploy resilient web servers across multiple zones in us-central1 with CentOS Stream 10, 100GB disk, N-series VMs.



*Terraform

-Required Arguments for a VM

From `06-compute.tf`, the minimum required arguments to provision a VM are:

- `name` — what the VM is called in GCP
- `machine_type` — the compute size, in this case `n2-standard-2`
- `boot_disk` block with `initialize_params`:
  - `image` — the OS image to boot from
  - `size` — disk size in GB
- `network_interface` block — requires at minimum a `subnetwork` reference so the VM knows which network to attach to. Adding an empty `access_config {}` inside it gives the VM an ephemeral external IP. Without it the VM is private.

-Non-Required Arguments

Two non-required arguments used in this build:

**`tags`** — network tags that are matched by firewall rules. Without `tags = ["http-server"]` the firewall rule in `05-firewall.tf` would not apply to this VM and port 80 would not open. Tags are not required but in practice are almost always needed when you have firewall rules scoped to specific instances.

**`zone`** — where the VM is created. Not required if a default zone is set, but setting it explicitly makes the config predictable and self-documenting. If you leave it out and have no default, Terraform will error.

-Outputting Internal and External IP Addresses

Found by going to the `attributes-reference` section of the `google_compute_instance` registry docs. The VM's network interface exposes both addresses as nested attributes:

```hcl
output "internal_ip" {
  value = google_compute_instance.vm.network_interface[0].network_ip
}

output "external_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
```

`[0]` is used because a VM can have multiple network interfaces and multiple access configs — we always want the first one. `nat_ip` is GCP's attribute name for the external address. After `terraform apply` these printed:

```
external_ip = "34.133.148.51"
internal_ip = "10.202.0.2"
```

-Finding the CentOS Stream 10 Image Format

The format Terraform expects is `project/family` or a specific image name. To find it:

```bash
gcloud compute images list | grep centos
```

This returns the image project (`centos-cloud`) and the image family or name (`centos-stream-10`). The argument in Terraform ends up as:

```hcl
image = "centos-cloud/centos-stream-10"
```

Terraform resolves the family to the latest image in that family at apply time.

---

-name vs id vs self_link

These are three different ways GCP identifies a resource and they serve different purposes:

- **`name`** — the human-readable label you give it at creation. In this build: `weekgr8-vm`. This is what shows up in the console and is what you use to refer to it in everyday use.

- **`id`** — a computed attribute assigned by GCP after the resource is created. It is the full resource path and is unique across the project:
  `projects/class75-pops/zones/us-central1-a/instances/weekgr8-vm`
  You don't set this — Terraform reads it back from GCP after creation.

- **`self_link`** — also computed, this is the full REST API URL for the resource:
  `https://www.googleapis.com/compute/v1/projects/class75-pops/zones/us-central1-a/instances/weekgr8-vm`
  It is used when other GCP resources or APIs need to reference this VM directly. It is not an IP address — it is a unique identifier in URL form.
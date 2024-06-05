
# Hybrid Application Deployment with OpenShift Virtualization

## Overview

This project demonstrates hosting a hybrid workload comprised of both containerized and VM-based components on OpenShift. It showcases how OpenShift Virtualization allows organizations to co-locate their container and VM workloads on the same platform. This capability is crucial for cases where workloads cannot be fully modernized, or modernization must occur in phases.

## Application Architecture

This hybrid application includes:
- **WordPress Frontend**: A containerized WordPress application.
- **Windows Server Backend**: A VM running Windows Server with MySQL.
- **Redis Cache**: A containerized Redis instance for caching.

The architecture leverages the strengths of both containerized and VM-based workloads, providing a seamless environment for running modern and legacy applications together.

## Components and Their Interactions

- **WordPress Frontend**: Communicates with the backend MySQL database on the Windows Server VM.
- **Windows Server Backend**: Hosts the MySQL database that stores WordPress data.
- **Redis Cache**: Enhances performance by caching frequently accessed data.

## Prerequisites

- **Must have access to an OpenShift v4.12 (or newer) cluster**: See official Red Hat documentation for deploying and configuring OpenShift.
- **Must have OpenShift Virtualization installed and configured on your OpenShift Cluster**: See official Red Hat documentation for deploying and configuring OpenShift Virtualization.
- **Must be able to authenticate to the OpenShift cluster from your local machine, with a user that has the permissions to create namespaces and namespaced resources**: See official Red Hat documentation for configuring and using OpenShift authentication and authorization. 
- **Must have Git installed locally**: See [https://github.com/git-guides/install-git](https://github.com/git-guides/install-git) for installation instructions.
- **Must have Helm installed locally**: See [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/) for installation instructions.
- **Must have access to the latest versions of the MySQL and Visual Studios Redistributables installation files**: You can either host them on a local web server or, if you have Internet access, you can use the download links for the respective installer.  At the time of this writing, these links were [https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-winx64.msi](https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-winx64.msi) and [https://aka.ms/vs/17/release/vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe) respectively.
- ** Must have access to a downloadable Windows Server 2k22 ISO**: Again, you can host locally on a web server, or obtain a download link from Microsoft.
  **Note**: In theory, this solution may work with other versions of Windows with some minor modifications to the values.yaml contents, though at the time of this writing, I have not tested this solution with any other version.
- ** Must have access to a valid Windows Product Key**: Please refer to official Microsoft documentation for details on how to obtain a Product Key.

## Deployment Instructions

1. **Clone the Repository**
    ```sh
    git clone https://github.com/bstrauss84/hybrid-app-demo.git
    cd hybrid-app-demo
    ```

2. **Option 1: Install the Application with Helm**
    ```sh
    helm install helm-deploy-hybrid-app . --namespace demo-hybrid --create-namespace
    ```

    **OR**

   **Option 2: Install the Application with Helm, Overriding Key Parameters in the values.yaml File**
    ```sh
    helm install helm-deploy-hybrid-app . \
      --namespace demo-hybrid --create-namespace \
      --set configMap.sysprepWindows.autounattend.ProductKey="ABCDE-FGHIJ-KLMNO-PQRST-UVWXY" \
      --set configMap.sysprepWindows.autounattend.Password="mysupersecurepassword1" \
      --set configMap.sysprepWindows.postInstall.mysqlInstallerUri="https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-winx64.msi" \
      --set configMap.sysprepWindows.postInstall.vcRedistributablesUri="https://aka.ms/vs/17/release/vc_redist.x64.exe" \
      --set vm.wordpressBe.installationCdromUrl="http://my-example-web-server.com/win2022.iso" \
      --set route.wordpressFe.host=wordpress-hybrid.apps.some.ocp.cluster.com
    ```

## Next Steps

1. **Access the WordPress Frontend**
    - Navigate to the WordPress route URL specified in your `values.yaml` file.
    - Follow the WordPress setup instructions:
        - Select your language.
        - Create the initial admin user.
        
2. **Enable Redis Plugin in WordPress**
    - Install and activate the Redis plugin from the WordPress plugin repository.

3. **Create a Sample Post in WordPress**

4. **Verify Database Contents on Windows Server**
    - Ensure you have an RDP client like FreeRDP installed.
    - RDP into the Windows Server VM using the RDP service details provided.
    - Execute a MySQL command to verify the WordPress database contains the new post:
        ```sh
        mysql -u root -p<YourPassword> -e "USE wordpress_db; SELECT * FROM wp_posts;"
        ```

## Values File

Here's a sample `values.yaml` for your reference:
```yaml
namespace:
  name: demo-hybrid  # The namespace where the resources will be deployed

serviceAccount:
  name: hybrid-app-sa  # Name of the ServiceAccount to be created

roleBinding:
  name: hybrid-app-rolebinding  # Name of the RoleBinding to be created

secret:
  wordpressDb:
    name: wordpress-db-secret  # Name of the Secret to store the WordPress DB credentials

configMap:
  wordpressFeConfig:
    name: wordpress-config  # Name of the ConfigMap for WordPress front-end configuration
    wp_redis_host: wordpress-cache  # Name of the Redis Service for WordPress caching
  sysprepWindows:
    name: sysprep-wordpress-be  # Name of the ConfigMap for sysprep configuration of the Windows VM
    autounattend:
      FullName: "Administrator"  # Full name for the Windows VM administrator
      Organization: "Organization"  # Organization name for the Windows VM
      ProductKey: "<YourProductKey>"   # Placeholder for product key value
      ComputerName: "wordpress-be"  # Computer name for the Windows VM
      Password: "<YourPassword>"  # Password for the Windows VM administrator and MySQL DB login
      Owner: "Owner"  # Owner name for the Windows VM
      TimeZone: "Eastern Standard Time"  # Time zone for the Windows VM
      LocalAccountDescription: "Administrator"  # Description for the local admin account
      LocalAccountDisplayName: "Administrator"  # Display name for the local admin account
      LocalAccountGroup: "Administrators"  # Group for the local admin account
      LocalAccountName: "Administrator"  # Name for the local admin account
      Username: "Administrator"  # Username for the local admin account
    postInstall:
      mysqlInstallerUri: "[https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-winx64.msi](https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-winx64.msi)"  # URI to download MySQL installer
      vcRedistributablesUri: "[http://example.com/VC_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)"  # URI to download Visual Studio Redistributables
      mysqlInstallerFile: "mysql-8.4.0-winx64.msi"  # File name for MySQL installer
      vcRedistributablesFile: "vc_redist.x64.exe"  # File name for Visual Studio Redistributables
      mysqlBaseDataDir: 'C:\ProgramData\MySQL\MySQL Server 8.0'  # Base data directory for MySQL
      mysqlBaseInstallDir: 'C:\Program Files\MySQL\MySQL Server 8.4'  # Base installation directory for MySQL
      mysqlServiceName: "MySQL80"  # Name of the MySQL service
      firewallRuleDisplayName: "MySQL Server"  # Display name for the firewall rule for MySQL
      additionalScripts: []  # List of additional PowerShell scripts to run post-install
    myIni:
      slowQueryLogFile: "WORDPRESS-BE-slow.log"  # File name for slow query log
      logErrorFile: "WORDPRESS-BE.err"  # File name for error log
      logBinFile: "WORDPRESS-BE-bin"  # File name for binary log

service:
  wordpressFe:
    name: wordpress-fe  # Name of the Service for WordPress front-end
  wordpressCache:
    name: wordpress-cache  # Name of the Service for WordPress cache (Redis)
  wordpressBeRdp:
    name: wordpress-be-rdp  # Name of the Service for RDP access to the Windows VM
    nodePort: 31389  # NodePort for RDP service
  wordpressBe:
    name: wordpress-be  # Name of the Service for WordPress back-end (MySQL)

pvc:
  redisData:
    name: redis-data-pvc  # Name of the PersistentVolumeClaim for Redis data
    accessMode: ReadWriteOnce  # Access mode for the PVC
    storage: 10Gi  # Storage size for the PVC
    storageClassName: odf-nvme-2-replicas  # Storage class name for the PVC
    volumeMode: Filesystem  # Volume mode for the PVC
  wordpressPlugins:
    name: wordpress-plugins-pvc  # Name of the PersistentVolumeClaim for WordPress plugins
    accessMode: ReadWriteOnce  # Access mode for the PVC
    storage: 10Gi  # Storage size for the PVC
    storageClassName: odf-nvme-2-replicas  # Storage class name for the PVC
    volumeMode: Filesystem  # Volume mode for the PVC

deployment:
  redis:
    name: wordpress-cache  # Name of the Redis deployment
    replicas: 1  # Number of replicas for Redis
    image: "redis:latest"  # Docker image for Redis
  wordpressFe:
    name: wordpress-fe  # Name of the WordPress front-end deployment
    replicas: 1  # Number of replicas for WordPress front-end
    dbHost: wordpress-be  # Hostname for the WordPress database
    dbUser: wordpress_user  # Username for the WordPress database
    dbName: wordpress_db  # Database name for WordPress
    image: "wordpress:latest"  # Docker image for WordPress

vm:
  wordpressBe:
    name: wordpress-be  # Name of the VirtualMachine for WordPress back-end
    template: windows2k22-server-medium  # Template for the Windows VM
    flavor: medium  # Flavor for the Windows VM
    os: windows2k22  # Operating system for the Windows VM
    workload: server  # Workload type for the Windows VM
    size: medium  # Size for the Windows VM
    running: true  # Initial running state of the VM
    installationCdromUrl: 'http://example.com/win2022.iso'  # URL for the installation CDROM
    installationCdromStorageClass: odf-nvme-2-replicas  # Storage class for the installation CDROM
    installationCdromStorage: 20Gi  # Storage size for the installation CDROM
    rootDiskStorageClass: vm-odf-hdd-3-replicas  # Storage class for the root disk
    rootDiskStorage: 120Gi  # Storage size for the root disk
    cpuCores: 4  # Number of CPU cores for the VM
    cpuSockets: 1  # Number of CPU sockets for the VM
    cpuThreads: 1  # Number of CPU threads for the VM
    memory: 16Gi  # Amount of memory for the VM
    windowsDriversDiskImage: 'registry.redhat.io/container-native-virtualization/virtio-win-rhel9@sha256:a8d455491d6c1ff45c6d8d340aa804313ce5613a59f53c7f4a5fcb61c14cc9fc'  # Image for the Windows drivers disk
    machineType: pc-q35-rhel9.2.0  # Machine type for the VM

route:
  wordpressFe:
    name: wordpress-fe  # Name of the Route for WordPress front-end
    host: wordpress-demo.apps.example.com  # Hostname for the WordPress front-end route
```

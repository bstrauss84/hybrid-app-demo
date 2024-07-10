
# Hybrid Application Deployment with OpenShift Virtualization

![App Screenshot](https://github.com/bstrauss84/hybrid-app-demo/blob/main/resources/Screenshot%20from%202024-07-10%2012-53-28.png?raw=true)

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
- **Must have access to a downloadable Windows Server 2k22 ISO**: Again, you can host locally on a web server, or obtain a download link from Microsoft.
  **Note**: In theory, this solution may work with other versions of Windows with some minor modifications to the values.yaml contents, though at the time of this writing, I have not tested this solution with any other version.
- **Must have access to a valid Windows Product Key**: Please refer to official Microsoft documentation for details on how to obtain a Product Key.

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
        ```sh
        xfreerdp /v:api.your-openshift-cluster.example.com:31389 /u:Administrator /p:<your password> +dynamic-resolution +clipboard
        ```
    - Execute a MySQL command to verify the WordPress database contains the new post:
        ```sh
        mysql -u root -p<YourPassword> -e "USE wordpress_db; SELECT * FROM wp_posts;"
        ```

## Values File

Most variables acceptable defaults, but a few variables (e.g. password, product key and wordpress url) need to be provided.
You can update the `values.yaml` file directly, or use `--set your.variable="your value"` when running `helm install ...`.
My preference is to save my override values in a file, lik `apply-my-cluster.sh` and then running `source apply-my-cluster.sh`

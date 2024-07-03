# Please run "source apply.sh" to install the hybrid demo.

# The values below will override the default values from values.yaml

helm install hybrid-demo-app . \
  --create-namespace \
  --namespace demo-hybrid \
  --set configMap.sysprepWindows.autounattend.Password="<your password>" \
  --set configMap.sysprepWindows.autounattend.ProductKey="<your product key>" \
  --set configMap.sysprepWindows.postInstall.mysqlInstallerUri="https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-winx64.msi" \
  --set configMap.sysprepWindows.postInstall.vcRedistributablesUri="https://aka.ms/vs/17/release/vc_redist.x64.exe" \
  --set vm.wordpressBe.installationCdromUrl="http://example.com/win2022.iso" \
  --set route.wordpressFe.host=wordpress-demo-test.apps.example.com

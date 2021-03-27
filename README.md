#Follow these steps
1. Clone this repo locally
1. Insert given credentials into provider.tf   
1. ```shell
   cd terraform
   ```
1. Apply TerraForm
   - resolve any errors
   - public IP of instance is in output
   - ssh private key is in output
1. SSH into instance
   - fix connection issues
1. clone
   ```shell
   https://github.com/bluesentry/bsi-hello-world.git
   ```
1. ```sh
   cd source
   ```  
1. compile
1. run compiled program
1. create new volume
   - 10gb
   - add tag "Name:bootcamp"
1. attach to instance
   - format the volume
   - ensure volume will mount to "/bootcamp" on reboot
   - reboot and show volume
1. run 
   ```sh
   terraform destroy
   ```
   - delete extra volume from console
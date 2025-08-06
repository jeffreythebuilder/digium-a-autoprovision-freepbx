# digium-a-autoprovision-freepbx
Digium A-Series Auto-Provisioning for FreePBX/PBXact

This guide provides a comprehensive, step-by-step process for setting up auto-provisioning for Digium A20, A22, and A25 IP phones on PBXAct16 server. Other freepbx versions need testing. By following these instructions, you'll be able to automatically configure your phones as soon as they're plugged into the network, using DHCP option 66 to point them to your server's configuration files.

Prerequisites

    A FreePBX or PBXact server (version 16, other versions require testing).

    Administrative access to the server via SSH.

    Basic knowledge of Linux command-line operations.

Step 1: Download and Prepare Provisioning Files

First, you need to download the necessary scripts and templates from this repository and place them in the correct directory on your server.
Download the files:
Download the repository and unzip it using the following commands:
    
    wget https://github.com/jeffreythebuilder/digium-a-autoprovision-freepbx/archive/refs/heads/main.zip
    unzip main.zip

Move files to the provisioning directory:
Move the unzipped folder to the web server's provisioning root directory.
Bash

sudo mv digium-a-autoprovision-freepbx-main /var/www/html/provisioning

(Optional) Clean up:
If you no longer need the zip file, you can remove it.

    rm main.zip

The provisioning folder now contains the following files:

    f0A20hw1.100.cfg: Template for the Digium A20.

    f0A22hw1.100.cfg: Template for the Digium A22.

    f0A25hw1.100.cfg: Template for the Digium A25.

    generate_provisioning.sh: A script that automatically creates a .cfg file for each phone based on its MAC address.

    template.cfg: The default configuration template that the script uses.

    mac_mapping.csv: A CSV file where you will map MAC addresses to extensions.

Step 2: Customize the Configuration Template

Edit the template.cfg file to match your desired phone settings. This template uses placeholder variables that the script will replace with real values from your PBX.

Step 3: Configure the Provisioning Script

The generate_provisioning.sh script is what pulls information from your PBX database to create the individual phone configuration files. You need to update it with your specific PBX IP address.
Open the script for editing:

    nano /var/www/html/provisioning/generate_provisioning.sh

Edit the variables:
Locate the PBX_IP variable and change its value to your PBX server's IP address. The other variables should be correct by default, but you can double-check them.

    TEMPLATE="template.cfg"
    CSV="mac_mapping.csv"
    OUTPUT_DIR="/var/www/html/provisioning"
    PBX_IP="192.168.0.10"  # <-- **CHANGE THIS TO YOUR PBX IP ADDRESS**
    SIP_PORT="5160"

Step 4: Map MAC Addresses to Extensions

The mac_mapping.csv file tells the script which extension to assign to which phone.

Open the CSV file for editing:
    
    nano /var/www/html/provisioning/mac_mapping.csv

Add your extension and MAC address mappings:
Enter each extension and its corresponding MAC address on a new line, separated by a comma. Ensure all MAC addresses are in lowercase.

Step 5: Run the Provisioning Script

Now you're ready to run the script that will generate the configuration files for your phones.

Make the script executable:

    chmod +x /var/www/html/provisioning/generate_provisioning.sh

Execute the script:

    ./var/www/html/provisioning/generate_provisioning.sh

    The script will output a confirmation for each .cfg file it successfully generates. You should now see a new configuration file for each MAC address you listed in mac_mapping.csv.

Step 6: Enable DHCP Option 66

This final step tells your network to point your Digium phones to the provisioning server.

    Log in to the FreePBX/PBXact web GUI.

    Navigate to Admin > System Admin > DHCP Server.

    Enable the DHCP server by toggling the switch to On.

    Click the Manage button to add DHCP Option 66.

    In the URL field, enter your provisioning server's URL. The format should be http://[PBX_IP]/provisioning. For example: http://192.168.0.10:2001/provisioning.

    Click Save.

Finalizing Setup

With all the steps completed, your Digium A-Series phones are now ready for auto-provisioning. Simply plug a phone into the network, and it will:

    Obtain an IP address from your DHCP server.

    Use DHCP Option 66 to find the provisioning server.

    Request its MAC-address-specific configuration file (e.g., 000fd3cbbccd.cfg).

    Download the configuration and automatically register to the assigned extension.

Important Note: The phone will attempt to grab a new configuration file on every reboot. This means that any manual changes made on the phone's local web GUI will be overwritten after a reboot. To avoid this, you can disable DHCP Option 66 once the phones are provisioned.

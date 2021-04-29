
# Variables
$Env:MYUSER = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

if($Env:HAZ -eq $null) {
  $Env:HAZ = "https://github.com/frozenfoxx/haz.git"
}

if($Env:HAZ_DIR -eq $null) {
  $Env:HAZ_DIR = "/opt/haz"
}

if($Env:HAZ_NAME -eq $null) {
  $Eenv:HAZ_NAME = "haz"
}

# Functions

# Configure the hostname
function Set-Hostname {
  echo "Setting hostname..."
  sudo sed -i "s/raspberrypi/${HAZ_NAME}/g" /media/${MYUSER}/rootfs/etc/hosts
  sudo sed -i "s/raspberrypi/${HAZ_NAME}/g" /media/${MYUSER}/rootfs/etc/hostname
  echo ${HAZ_NAME} > /media/${MYUSER}/boot/hostnames
}

# Ensure SSH is enabled at boot
function Set-Ssh {
  echo "Enabling SSH at boot..."
  touch /media/${MYUSER}/boot/ssh
}

# Configure user
function Add-User {
  AUTHORIZED_KEYS=$(whiptail --title "Authorized Keys for SSH" --inputbox "Input the fully-qualified path to a public SSH key to use for connecting to the system.\n\nFound the following:\n\n$(ls ~/.ssh/*.pub)" 30 55 3>&1 1>&2 2>&3)

  # Check for if the user cancelled
  if [[ ${AUTHORIZED_KEYS} == '' ]]; then
    echo "[!] No public key entered, terminating..."
    exit 1
  fi

  # Check to see if the file exists
  if ! [[ -f ${AUTHORIZED_KEYS} ]]; then
    echo "[!] The provided key location doesn't exist, terminating..."
    exit 1
  fi

  echo "Copying over the provided public key for the pi user..."
  mkdir /media/${MYUSER}/rootfs/home/pi/.ssh
  chmod 700 /media/${MYUSER}/rootfs/home/pi/.ssh
  cp ${AUTHORIZED_KEYS} /media/${MYUSER}/rootfs/home/pi/.ssh/authorized_keys
}

# Set up WiFi for the inital connection
function Add-Wifi {
  DEPLOY_SSID=$(whiptail --title "Local Network SSID" --inputbox "Input the SSID of your local WiFi network" 10 40 3>&1 1>&2 2>&3)
  DEPLOY_PSK=$(whiptail --title "Local Network Passphrase" --inputbox "Input the local WiFi network's passphrase" 10 40 3>&1 1>&2 2>&3)

  # Check for if the user cancelled
  if [[ ${DEPLOY_SSID} == '' ]]; then
    echo "[!] No local network SSID entered, terminating..."
    exit 1
  fi

  envsubst < ${HAZ_DIR}/configs/boot/wpa_supplicant.conf.tmpl > /media/${MYUSER}/boot/wpa_supplicant.conf
}

# Copy over data files
function Copy-Data {
  echo "Copying over data..."

  sudo mkdir /media/${MYUSER}/rootfs/data
  sudo cp ../data/* /media/${MYUSER}/rootfs/data/

  echo "Syncing. This might take a minute..."
  sync
}

# Clone the haz code onto the system
function Install-Haz {
  echo "Cloning latest haz..."

  git clone ${haz} /media/${MYUSER}/rootfs${HAZ_DIR}
}

# Show the user what must be done next
function Show-Instructions {
  echo "The HAZ is now almost complete. To complete installation perform the following:"
  echo "  Insert the microSD card into the Raspberry Pi."
  echo "  Power on the Raspberry Pi."
  echo "  ssh -i [path to private key] pi@[hostname].local"
  echo "  (RPi) sudo su - "
  echo "  (RPi) raspi-config"
  echo "  * (RPi) Update the keymap/locale (likely US)."
  echo "  * (RPi) Update the pi user's password."
  echo "  (RPi) Logout, relogin."
  echo "  (RPi) cd ${HAZ_DIR}/scripts && sudo ./deploy_linux.sh"
  echo "  After installation has completed reboot the Raspberry Pi."
  echo "  With another device, connect to the SSID."
}

# Display usage information
function Show-Usage {
  echo "Usage: [Environment Variables] ./deploy_rpi.ps1 [-h]"
  echo "  Environment Variables:"
  echo "    HAZ                    HTTP clone target for the random-media-portal (default: https://github.com/frozenfoxx/haz)"
  echo "    HAZ_DIR                directory to clone HAZ to (default: /opt/haz)"
  echo "    HAZ_NAME               name to deploy the HAZ as (default: haz)"
  echo "  Options:"
  echo "    -h | --help            display this usage information"
}

# Logic

# Argument parsing
while [[ "$1" != "" ]]; do
  case $1 in
    -h | --help ) Show-Usage
                  exit 0
  esac
  shift
done

Add-User
Set-Ssh
Add-Wifi
Set-Hostname
Install-Haz
Copy-Data
Show-Instructions
Read-Host "Press Enter to exit"
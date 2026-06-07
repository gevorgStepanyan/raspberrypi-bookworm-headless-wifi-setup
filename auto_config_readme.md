# Auto reconnecting system
This is an additional, non-mandatory service. If you include and configure it, it will run every 30 seconds for 5 seconds and check if there is an active connection. When no active connection is found, it would re-run the `wifi-setup.sh` to re-establish the connection.

## Files
Place these files directly in the root folder of your Raspberry Pi SD card. These will then be available under `/boot/firmware/` when you are on the PI via ssh:

- `check-wifi-setup.sh`: The script that checks if the system is connected and re-runs `wifi-setup.sh` if it cannot find an active connection. 
- `check-wifi-setup.service`: Systemd service file

## Installation
1. Copy these files directly to the root folder of your Raspberry Pi micro SD card:
- `check-wifi-setup.sh`
- `check-wifi-setup.service`
- `check-wifi-setup.timer`

2. Insert the SD card into your Raspberry Pi and power it on.

3. Wait for the Raspberry Pi to boot up.

4. Connect to the Raspberry Pi via SSH using the following command:

```bash
ssh pi@raspberrypi.local
```

Or use whatever IP address or network name you have set for the Raspberry Pi.

5. Copy these files to the corresponding to each folder
- `check-wifi-setup.sh`:
  ```shell
    $sudo cp /boot/firmware/check-wifi-setup.sh /usr/local/bin/
    $sudo chmod +x /usr/local/bin/check-wifi-setup.sh
  ```
- `check-wifi-setup.service`:
  ```shell
    $sudo cp /boot/firmware/check-wifi-setup.service /etc/systemd/system/
  ```
- `check-wifi-setup.timer`:
  ```shell
  $sudo cp /boot/firmware/check-wifi-setup.timer /etc/systemd/system/
  ```

6. Enable the timer
   ```shell
    $systemctl daemon-reload
    $systemctl enable --now check-wifi-setup.timer
   ```

## Service Management

Check status

```bash
$systemctl status check-wifi-setup.timer
```

View logs:

```bash
tail -f /var/log/wifi-setup.log
```

Manually test:

```bash
sudo systemctl start check-wifi-setup.service
```
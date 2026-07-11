# CachyOS Gaming Mode on NVIDIA Optimus Laptops (Intel + NVIDIA)

> **⚠️ Important Disclaimer**
> 
> These files are the result of a **strictly personal configuration** tailored to a specific hardware setup (HP Omen). They **may not work on other devices** out of the box. Proceed with caution and adapt the system paths (especially in the fan control service) to your specific hardware if necessary.
> 
> **Dependency:** The `nv-run` script requires the `intel-noturbo` service to manage CPU temperatures. You must install it from here before proceeding: [https://github.com/ShyVortex/intel-noturbo](https://github.com/ShyVortex/intel-noturbo).

This guide explains how to properly configure the **Gaming Mode (Gamescope)** on CachyOS (Deckify) for laptops equipped with NVIDIA Optimus hybrid graphics (Intel iGPU + NVIDIA dGPU), solving two common issues:
1. A black screen when launching Gaming Mode without an external monitor connected (caused by Gamescope trying to hook into the NVIDIA GPU).
2. Games incorrectly launching on the integrated Intel GPU, ignoring the `prime-run` command due to Proton's isolated containers (*pressure-vessel*).

The solution consists of forcing the Steam interface to run lightly on the Intel GPU (which physically controls the laptop's internal screen) and using a custom command (`nv-run`) to "wake up" the NVIDIA GPU, apply thermal protections, and inject the correct drivers only when launching a game.

This repository provides the necessary configuration files. Follow the instructions below to install them.

## Step 1: Force Gamescope on the Intel GPU

To prevent the Gamescope session from crashing or returning a black screen while looking for NVIDIA video outputs, we must tell the compositor to use the integrated graphics bus.

1. Open the terminal in the directory where you cloned or downloaded this repository.
2. Create the user environment variables directory (if it doesn't already exist):
   ```bash
   mkdir -p ~/.config/environment.d
3. Copy the provided configuration file into the new directory:
   ```bash
   cp 10-gamescope-session.conf ~/.config/environment.d/
   ```
4. Reboot your computer to apply the changes. Now, Gaming Mode will stably start on your laptop's internal screen.

## Step 2: Install Thermal Services and Sudoers Rules

The custom `nv-run` script automatically disables CPU Turbo Boost and sets the fans to maximum speed when a game launches.

1. Make sure you have installed the [intel-noturbo](https://github.com/ShyVortex/intel-noturbo) service.
2. Copy the `omen-maxfan.service` (included in this repository) to the systemd folder:
   ```bash
   sudo cp omen-maxfan.service /etc/systemd/system/
   ```
3. Reload the systemd daemon so it recognizes the new service:
   ```bash
   sudo systemctl daemon-reload
   ```
4. **Crucial:** To allow the `nv-run` script to start/stop these services without prompting for a password (which would break the Gaming Mode UI), you must configure `sudoers`. Run:
   ```bash
   sudo visudo -f /etc/sudoers.d/gaming-tweaks
   ```
5. Paste the following line exactly as it is, then save and exit:
   ```text
   %wheel ALL=(ALL) NOPASSWD: /usr/bin/systemctl start intel-noturbo.service, /usr/bin/systemctl stop intel-noturbo.service, /usr/bin/systemctl start omen-maxfan.service, /usr/bin/systemctl stop omen-maxfan.service
   ```

## Step 3: Install the `nv-run` command

Since the default wrapper might fail inside Proton's isolated containers, we use the provided `nv-run` script that explicitly injects the NVIDIA driver paths (Vulkan ICD) and triggers the thermal services before the game is launched.

1. From the terminal, copy the provided `nv-run` file to your system's binaries path:
   ```bash
   sudo cp nv-run /usr/local/bin/
   ```


2. Make the script executable with the following command:
   ```bash
   sudo chmod +x /usr/local/bin/nv-run
   ```

## Step 4: How to use `nv-run` in Steam

Now that the system is set up, you can dynamically decide which GPU to use for each individual game, keeping the SteamOS interface lightweight and cool on the Intel GPU.

When you want a game to use the full power of your dedicated NVIDIA GPU (and trigger the max fan/no-turbo profile):

1. Select the game in your Steam library (either in Desktop or Gaming Mode).
2. Go to **Properties** -> **General**.
3. Scroll down to the **Launch Options** field and enter:
   ```bash
   nv-run %command%
   ```



For lightweight 2D or indie games where you want to save battery and reduce heat, simply leave the launch options empty: the game will automatically start on the integrated Intel GPU without triggering the loud fans.

---

*Note: This guide assumes that your hardware manager (e.g., envycontrol or supergfxctl) is set to **Hybrid** mode.*
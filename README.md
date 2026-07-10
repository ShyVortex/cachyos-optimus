# CachyOS Gaming Mode on NVIDIA Optimus Laptops (Intel + NVIDIA)

This guide explains how to properly configure the **Gaming Mode (Gamescope)** on CachyOS (Deckify) for laptops equipped with NVIDIA Optimus hybrid graphics (Intel iGPU + NVIDIA dGPU), solving two common issues:
1. A black screen when launching Gaming Mode without an external monitor connected (caused by Gamescope trying to hook into the NVIDIA GPU).
2. Games incorrectly launching on the integrated Intel GPU, ignoring the `prime-run` command due to Proton's isolated containers (*pressure-vessel*).

The solution consists of forcing the Steam interface to run lightly on the Intel GPU (which physically controls the laptop's internal screen) and using a custom command (`nv-run`) to "wake up" the NVIDIA GPU and inject the correct drivers only when launching a game.

This repository provides the necessary configuration files. Follow the instructions below to install them.

## Step 1: Force Gamescope on the Intel GPU

To prevent the Gamescope session from crashing or returning a black screen while looking for NVIDIA video outputs, we must tell the compositor to use the integrated graphics bus.

1. Open the terminal in the directory where you cloned or downloaded this repository.
2. Create the user environment variables directory (if it doesn't already exist):
   ```bash
   mkdir -p ~/.config/environment.d
   ```
3. Copy the provided configuration file into the new directory:
   ```bash
   cp 10-gamescope-session.conf ~/.config/environment.d/
   ```
4. Reboot your computer to apply the changes. Now, Gaming Mode will stably start on your laptop's internal screen.

## Step 2: Install the `nv-run` command

Since the default wrapper might fail inside Proton's isolated containers, we use the provided `nv-run` script that explicitly injects the NVIDIA driver paths (Vulkan ICD) before the game is launched.

1. From the terminal, copy the provided `nv-run` file to your system's binaries path:
    ```bash
    sudo cp nv-run /usr/local/bin/
    ```


2. Make the script executable with the following command:
    ```bash
    sudo chmod +x /usr/local/bin/nv-run
    ```

## Step 3: How to use `nv-run` in Steam

Now that the system is set up, you can dynamically decide which GPU to use for each individual game, keeping the SteamOS interface lightweight and cool on the Intel GPU.

When you want a game to use the full power of your dedicated NVIDIA GPU:

1. Select the game in your Steam library (either in Desktop or Gaming Mode).
2. Go to **Properties** -> **General**.
3. Scroll down to the **Launch Options** field and enter:
   ```bash
   nv-run %command%
   ```

For lightweight 2D or indie games where you want to save battery and reduce heat, simply leave the launch options empty: the game will automatically start on the integrated Intel GPU.

---

*Note: This guide assumes that your hardware manager (e.g., envycontrol or supergfxctl) is set to **Hybrid** mode.*
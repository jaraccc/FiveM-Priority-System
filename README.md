# FiveM Priority System

This Priority System is designed to integrate seamlessly with [JaRacc's FiveM Interaction Menu](https://github.com/jaraccc/FiveM-Interaction-Menu/). It allows server administrators and players to manage priorities on the server with commands to start, join, and stop priorities, along with cooldown functionality.

## Features
- Easily start, stop, and manage priorities with simple commands.
- Set priority cooldown timers to prevent back-to-back priorities.
- Displays current priority status on the player's HUD.
- Seamless integration with JaRacc's [Interaction Menu](https://github.com/jaraccc/FiveM-Interaction-Menu/).
- Fully customizable to fit your server's needs.

## Installation
1. **Download** or **Clone** the repository to your `resources` folder:
   ```bash
   git clone https://github.com/jaraccc/FiveM-Priority-System.git
   ```
2. Add the following line to your `server.cfg` to ensure the resource starts:
    ```bash
   start priority-system
   ```
3. Configure the priority system settings by editing the `config.lua` file to match your server’s requirements (e.g., cooldown times, notifications).

## Commands
| Command        | Description                        |
| -------------- | ---------------------------------- |
| `/startprio`   | Starts a priority event.           |
| `/endprio`     | Ends the current priority event.   |
| `/joinprio`    | Allows a player to join the event. |
| `/leaveprio`   | Allows a player to leave the event.|
| `/prio`        | Displays the current priority state, if active, and cooldown status. |

## Usage
Once installed, you can use the above commands to manage the priority system. The current priority status will be visible on the player's HUD, and the system is designed to work directly with [JaRacc's Interaction Menu](https://github.com/jaraccc/FiveM-Interaction-Menu/), providing an immersive in-game experience for managing server priorities.

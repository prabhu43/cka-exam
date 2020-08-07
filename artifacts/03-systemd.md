### Intro
Systemd is an init system and system manager that is widely becoming the new standard for Linux machines. 

### Service Management
In systemd, the target of most actions are “units”, which are resources that systemd knows how to manage. Units are categorized by the type of resource they represent and they are defined with files known as unit files. The type of each unit can be inferred from the suffix on the end of the file

For service management tasks, the target unit will be service units, which have unit files with a suffix of .service

### Location of systemd services
- /lib/systemd/system
- /etc/systemd/system - higher precendence
### 3 utilities
- systemd/systemctl 
- journald/journalctl - log management
- logind/loginctl - user sessions handling

**States of a service**
- enabled => it has a symlink in a .wants directory
- disabled => no symlink
- masked => completely unstartable, automatically or manually; linked to /dev/null
- static => service is missing the [Install] section in its init script, so you cannot enable or disable it. Static services are usually dependencies of other services, and are controlled automatically
> None of these states tell you if a service is running

#### Unit Types
systemd has 12 unit types. `.service` is system services, and when you’re running any of the above commands you can leave off the .service extension, because systemd assumes a service unit if you don’t specify something else. 

**12 unit types of systemd**
- Target: group of units. (runlevel)
- Service: system services
- Automount: filesystem auto-mountpoint
- Device: kernel device names, which you can see in sysfs and udev
- Mount: filesystem mountpoint
- Path: file or directory
- Scope: external processes not started by systemd
- Slice: a management unit of processes
- Snapshot: systemd saved state
- Socket: IPC (inter-process communication) socket
- Swap: swap file
- Timer: systemd timer

**Cheatsheet - systemctl**
```
# Enable service to tell systemd to start it automatically at boot
# This will create a symbolic link from the system’s copy of the service file (usually in /lib/systemd/system or /etc/systemd/system) into the location on disk where systemd looks for autostart files (usually /etc/systemd/system/some_target.target.wants.
# enabling a service does not start it in the current session
systemctl enable [name.service]

# disable the service from starting automatically at system boot
# removes the symbolic link
systemctl disable [name.service]

systemctl start [name.service]
systemctl stop [name.service]
systemctl restart [name.service]

# Reload the service without interrupting normal functionality
systemctl reload [name.service]

# Reload the configuration in-place if reload functionality available. 
# Otherwise, it will restart the service so the new configuration is picked up
systemctl reload-or-restart [name.service]

# Check status of systemd service
# Provides service state, the cgroup hierarchy, and the first few log lines
systemctl status [name.service]

# Check if a unit is currently active (running)
# exit code will be 0 if it is active
systemctl is-active [name.service]

# Check if the unit is enabled
# exit code will be 0 if it is active
systemctl is-enabled [name.service]

# Check if the unit is in failed state
# exit code will be 0 if it is failed
systemctl is-failed [name.service]

# See content of unit file
systemctl cat [name.service]

# See dependency tree of a unit
systemctl list-dependencies [name.service]

# Show the dependent units, with target units recursively expanded
systemctl list-dependencies --all [name.service]

# See low-level details of the unit’s settings on the system
systemctl show [name.service]

# Display single property of a unit
systemctl show [name.service] -p Description

systemctl mask [name.service]
systemctl unmask [name.service]

# Add a unit file snippet, which can be used to append or override settings in the default unit file
systemctl edit [name.service]

# Modify the entire content of the unit file instead of creating a snippet
systemctl edit --full [name.service]

# After modifying a unit file, reload the systemd process itself to pick up your changes
systemctl daemon-reload

#### Units ####
# Display all units that systemd has listed as "active"
systemctl list-units (or) systemctl

# Display all units that systemd has loaded or attempted to load into memory
systemctl list-units --all

# Display all units of type service
systemctl list-units --type service --all

# Display all inactive units
systemctl list-units --all --state=inactive

#### Unit files ####
# To see every available unit file within the systemd paths, including those that systemd has not attempted to load
systemctl list-unit-files

# Displays the status of all installed services that have init scripts
systemctl list-unit-files --type=service

# See all of the targets available on your system
systemctl list-unit-files --type=target

#### Target ####
# view the default target that systemd tries to reach at boot (which in turn starts all of the unit files that make up the dependency tree of that target)
systemctl get-default

# change the default target that will be used at boot
sudo systemctl set-default multi-user.target

# see what units are tied to a target
systemctl list-dependencies multi-user.target

#### systemd ####
# initiate a full shutdown
systemctl poweroff

# reboot the system
systemctl reboot

# boot into rescue mode
systemctl rescue

# halt the system
systemctl halt
```

**Cheatsheet - journalctl**
```
# To see all log entries, starting at the oldest entry
journalctl

# see the journal entries from the current boot
journalctl -b

# see only kernel messages, such as those that are typically represented by dmesg
journalctl -k

# see all of the journal entries for the unit 
journalctl -u [name.service]


```

### References:
https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal
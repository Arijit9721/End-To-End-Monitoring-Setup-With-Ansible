# Role Name

A brief description of the role goes here.

## Requirements

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

## Role Variables

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

## Dependencies

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

## Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

## License

BSD

## Author Information

An optional section for the role authors to include contact information, or a website (HTML is not allowed).

## Interview Questions

Here are some potential interview questions based on the technical implementation of this `alertmanager` role:

### 1. Installation Method

**Q:** How does this role install Alertmanager, and why might you choose this method over a package manager (apt/yum)?
**A:** This role downloads the pre-compiled binary tarball directly from the official GitHub releases (`unarchive` with `remote_src: true`). This is often chosen to get the exact version needed (e.g., latest) which might not be available in standard OS repositories, or to maintain consistency across different Linux distributions.

### 2. User Security

**Q:** Why is the `alertmanager` user created with `shell: /sbin/nologin` and `system: yes`?
**A:**

- `shell: /sbin/nologin`: Prevents anyone from logging in interactively as this user, which reduces the attack surface.
- `system: yes`: Creates a "system" account (typically UID < 1000). These accounts are intended for running services/daemons, not for human users.

### 3. Configuration Management

**Q:** Why is the `template` module used for the systemd service file (`init.service.j2`), but the `copy` module used for the config file (`alertmanager.yaml`)?
**A:**

- **Template (`init.service.j2`)**: The service file likely needs to include dynamic variables defined in Ansible (like `{{ exec_command }}` or paths). J2 templates allow variable substitution.
- **Copy (`alertmanager.yaml`)**: The configuration file in this specific role is static (`files/alertmanager.yaml`), meaning it doesn't change based on variables, so `copy` is more efficient. If the config needed to be dynamic, we would use a template there too.

### 4. Service Handlers

**Q:** What is the purpose of `notify: systemd_reload` in the systemd template task?
**A:** When `notify` is triggered (i.e., if the service file changes), it runs a handler (likely running `systemctl daemon-reload`). This is crucial because systemd won't see changes to `.service` files on disk until its configuration is reloaded.

### 5. Verification

**Q:** How does the playbook verify that the service is actually working after installation?
**A:** It uses the `uri` module to send a standard HTTP GET request to `http://localhost:9093`. If the service is healthy, it returns a `200` status code. This is a simple but effective "smoke test."

### 6. Directory Structure

**Q:** What is the difference between `/etc/alertmanager` and `/data/alertmanager` in this setup?
**A:**

- `/etc/alertmanager`: Standard Linux location for **configuration files** (read-only for the service mostly).
- `/data/alertmanager`: Standard location for **state data** (silences, notification logs). This directory needs to be writable by the `alertmanager` user and persist across restarts.

### 7. Idempotency & Cleanup

**Q:** The role downloads the tarball to `/tmp`. How does it handle cleanup?
**A:** There is an explicit task `Deleting the tmp folder` which uses the `file` module with `state: absent` to remove the extracted directory after the binary has been moved. This keeps the system clean.

### 8. Ansible Module Mechanics (`remote_src`)

**Q:** In the copy task, why do we need `remote_src: yes`?
**A:** By default, the `copy` module looks for the `src` file on the **Ansible controller** (your local machine). Setting `remote_src: yes` tells Ansible that the file (`/tmp/alertmanager...`) already exists on the **remote target machine** (because we just downloaded it there) and should be copied from one location on the remote disk to another.

### 9. Linux Conventions

**Q:** Why do we keep the binaries in the `/usr/local/bin` directory?
**A:**

- **Standardization (FHS):** According to the Filesystem Hierarchy Standard, `/usr/local/bin` is the correct place for software installed by the administrator locally (not by the system package manager like `apt` or `yum`).
- **Path Visibility:** This directory is almost always in the system `$PATH`, allowing the executable to be found mostly anywhere if needed for debugging, though the service runs it via absolute path.

### 10. Process Management

**Q:** What is the advantage of starting Alertmanager as a service rather than normally calling the binary?
**A:**

- **Auto-Restart:** If the process crashes, Systemd will automatically restart it (`Restart=always`).
- **Boot Persistence:** The service will start automatically when the server reboots (`WantedBy=multi-user.target`).
- **Background Execution:** It runs as a daemon in the background, not tied to an active user session.
- **Logging:** Standard output is automatically captured by `journald` for easy log viewing.

### 11. Templating mechanics

**Q:** What is `init.service.j2` and what does it do?
**A:** It is a **Jinja2 template** for a Systemd Unit File. It defines the configuration for the Alertmanager service. By making it a template (`.j2`), we can inject Ansible variables (like `{{serviceName}}`, `{{userId}}`) directly into the service definition, making it dynamic and reusable.

### 12. Systemd Directives

**Q:** In the systemd file, what are `After`, `Wants`, and `WantedBy` used for?
**A:**

- **`After=network-online.target`**: Ordering dependency. Ensures Alertmanager only starts _after_ the network stack is fully up (crucial since it needs to receive alerts over HTTP).
- **`Wants=network-online.target`**: Weak dependency. Tells systemd that when Alertmanager starts, it should also try to start/ensure `network-online.target` is active.
- **`WantedBy=multi-user.target`**: Installation hook. This specifies that when we run `systemctl enable alertmanager`, a symlink should be created in the `multi-user.target.wants` directory. This ensures the service starts automatically when the system boots into the standard multi-user state (runlevel 3).

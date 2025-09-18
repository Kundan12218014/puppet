
# 🚀 Puppet-Based Web Application Deployment with Apache, Nginx, and GitHub Integration

This project demonstrates the use of **Puppet** to configure and deploy multiple web applications across AWS-based Ubuntu instances. It automates the setup of web servers, modules, manifest files, and self-management of the Puppet Master node.

---

## 📦 Features

- Puppet Master & Agent setup (master also acts as an agent)
- Multi-app deployment:
  - ✅ `mysite` — general-purpose HTML/CSS/JS site
  - ✅ `todo` — fully functional To-Do web app
  - ✅ `weather` — weather app served via Nginx
- Dual web server support (Apache2 & Nginx on separate ports)
- Use of modules for each application (`mysite`, `todo`, `weather`)
- Script module to deploy `.sh` files to agent nodes
- `.tar.gz` compression and transfer between AWS instances
- SCP/SSH automation script for transferring Puppet configuration

---

## 📁 Project Structure

```
/etc/puppet/code/environments/production/
│
├── manifests/
│   └── site.pp             # Main manifest file
│
├── modules/
│   ├── mysite/
│   │   ├── files/
│   │   │   └── index.html, style.css, script.js
│   │   └── manifests/init.pp
│   │
│   ├── todo/
│   │   ├── files/
│   │   │   └── index.html, style.css, script.js
│   │   └── manifests/init.pp
│   │
│   ├── weather/
│   │   ├── files/
│   │   │   └── index.html, style.css, script.js
│   │   └── manifests/init.pp
│   │
│   └── scriptmodule/
│       ├── files/
│       │   └── deploy.sh
│       └── manifests/init.pp
```

---

---

## 🛠 Puppet Setup Script

A shell script is included to automate the installation and basic configuration of Puppet Master or Agent.

### 🔧 How to Use

1. Replace `<PRIVATE_IP_OF_MASTER>` with the actual private IP of the master node in the script.
2. Run this on both master and slave nodes.

### 📥 Download & Execute

```bash
wget <URL_TO_puppet_setup.sh>
chmod +x puppet_setup.sh
./puppet_setup.sh
```

> On the master node, don’t forget to run:
> ```bash
> sudo ufw allow 8140/tcp
> sudo systemctl restart puppet-master.service
> ```

> Then sign the certificates:
> ```bash
> sudo puppet cert list
> sudo puppet cert sign --all
> ```

---

## 🔧 Puppet Configuration

### ✅ site.pp (Main Manifest)

```puppet
node default {

  # Apache setup
  package { 'apache2':
    ensure => installed,
  }

  service { 'apache2':
    ensure => running,
    enable => true,
    require => Package['apache2'],
  }

  # Nginx setup
  package { 'nginx':
    ensure => installed,
  }

  service { 'nginx':
    ensure => running,
    enable => true,
    require => Package['nginx'],
  }

  include mysite
  include todo
  include weather
  include scriptmodule
}
```

---

## 📤 File Transfer Between Instances

1. **Create archive on source instance**:
   ```bash
   sudo tar -czvf production.tar.gz production/
   ```

2. **Transfer to local**:
   ```bash
   scp -i devops.pem ubuntu@<SOURCE_IP>:/etc/puppet/code/environments/production.tar.gz ~/Downloads/
   ```

3. **Upload to destination**:
   ```bash
   scp -i devops.pem ~/Downloads/production.tar.gz ubuntu@<DEST_IP>:/home/ubuntu/
   ```

4. **Extract on destination**:
   ```bash
   ssh -i devops.pem ubuntu@<DEST_IP>
   sudo mv ~/production.tar.gz /etc/puppet/code/environments/
   cd /etc/puppet/code/environments/
   sudo tar -xzvf production.tar.gz
   ```

---

## 🔄 Puppet Master as Agent

To let the master also act as an agent:

```bash
sudo apt-get install puppet
sudo puppet agent --test

# On master (if certificate needed)
sudo puppetserver ca sign --all
```

---

## 🔐 Security Best Practices

- `.pem` key remains only on the **local machine**
- Never upload `.pem` to any instance
- Use `chmod 400 devops.pem` before running SSH/SCP commands

---

## 📜 Useful Commands

```bash
# Run puppet agent manually
sudo puppet agent --test

# Restart services
sudo systemctl restart apache2
sudo systemctl restart nginx

# Check puppet cert requests
sudo puppetserver ca list

# Sign certificates
sudo puppetserver ca sign --all
```

---

## 💡 Future Improvements

- Add CI/CD using Jenkins or GitHub Actions
- Serve apps via subdomains using virtual hosts or reverse proxies
- Add HTTPS support (SSL via Let's Encrypt)
- Monitor system using Prometheus or Puppet reports

---

## 👨‍💻 Author

**Kundan Kumar**  
B.Tech | DevOps & Full Stack Enthusiast | Exploring Infrastructure Automation 🚀

---

## 📄 License

This project is for educational and demonstration purposes only.

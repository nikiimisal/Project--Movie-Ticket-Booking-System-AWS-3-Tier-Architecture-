# 🎥  Movie Ticket Booking System (AWS 3-Tier Architecture)

## 📌 Introduction
The **Random Movie Ticket Booking System** is a web-based application designed with **AWS 3-Tier Architecture** to ensure **scalability**, **security**, and **high availability**.  
It allows users to:
- Browse movies  
- Select show timings  
- Choose seats  
- Book tickets online  

All booking and user data are securely stored in **Amazon RDS (MySQL)**.

This project demonstrates how to **deploy a real-world web application on AWS** by separating the **Web Layer**, **Application Layer**, and **Database Layer**.

---

## 1. Architecture Overview
![](https://github.com/nikiimisal/Project--Movie-Ticket-Booking-System-AWS-3-Tier-Architecture-/blob/main/img/1756991929423.jpg?raw=true)

| 🏷️ **Tier** | 🎯 **Purpose**           | 🌐 **Subnet Type**   | 📝 **Language / Stack**       | ⚙️ **EC2 Role**               |
|-------------|--------------------------|----------------------|--------------------------------|--------------------------------|
| **Tier 1**  | 🌍 *Frontend (UI)*        | 🟢 **Public Subnet** | `HTML`, `CSS`, `JS`, `NGINX`  | Handles **browser requests**   |
| **Tier 2**  | 🖥️ *Application (Logic)* | 🔒 **Private Subnet**| `PHP`, `NGINX`                 | Executes **business logic**    |
| **Tier 3**  | 💾 *Database (Storage)*   | 🔒 **Private Subnet**| `MySQL Database`               | Stores **persistent data**     |

---
##  2. VPC & Subnet Setup

### 2.1 Create a VPC

- **Name:** `movie-tickets-VPC`
- **CIDR block:** `10.0.0.0/16`
- **DNS Hostnames:** Enabled 

![](https://github.com/nikiimisal/Project--Movie-Ticket-Booking-System-AWS-3-Tier-Architecture-/blob/main/img/vpc.png?raw=true)

### 2.2 Create Subnets

| 📝 **Subnet Name** | 🌍 **CIDR Block** | 🗺️ **Availability Zone (AZ)** | 🔐 **Type** |
|-------------------|-------------------|--------------------------------|-------------|
| **Public-Subnet** | `10.0.16.0/24`    | `ap-south-1a`                   | 🌐 **Public** |
| **Private-App**   | `10.0.32.0/24`    | `ap-south-1a`                   | 🔒 **Private** |
| **Private-DB**    | `10.0.48.0/24`    | `ap-south-1a`                   | 🔒 **Private** |
| **Private-DB-2**  | `10.0.64.0/24`    | `ap-south-1b`                   | 🔒 **Private** |
> Enable Auto-Assign Public IP for **Public Subnet**.

![](./img3/Subnets.png)

### 2.3 Create Internet Gateway

- **Name:** `movie-internet-Gateway`
- **Attach** to `movie-tickets-vpc`

![](https://github.com/nikiimisal/Project--Movie-Ticket-Booking-System-AWS-3-Tier-Architecture-/blob/main/img/internet.png?raw=true)

### 2.4 Create Route Tables
![](https://github.com/nikiimisal/Project--Movie-Ticket-Booking-System-AWS-3-Tier-Architecture-/blob/main/img/Route.png?raw=true)

#### a. Public Route Table

- **Name:** `movie-Public-Table`
- **Associate with:** `Public-Subnet`
- **Add Route:**  
  `0.0.0.0/0` ➜ Internet Gateway

![](https://github.com/nikiimisal/Project--Movie-Ticket-Booking-System-AWS-3-Tier-Architecture-/blob/main/img/mpubt.png?raw=true)

#### b. Private Route Table

- **Name:** `movie-private-Table`
- **Associate with:** `Private-App`, `Private-DB`
- No external route initially.

![]()

## 🌐 3. NAT Gateway Setup

The **NAT Gateway (Network Address Translation Gateway)** allows **instances in private subnets** to **access the internet** for tasks like software updates, package installations, and external communications — **without exposing them directly** to the public internet.

---

### ❓ Why NAT Gateway?

- Private subnets **cannot directly access the internet** for security reasons.  
- A **NAT Gateway** acts as a **bridge**, allowing outbound internet traffic (e.g., `yum update`, `apt-get install`) while **blocking all inbound traffic**.

---

### 🛠️ Setup Steps

#### **1️⃣ Allocate Elastic IP**
- Go to **VPC Console → Elastic IPs → Allocate Elastic IP**.
- This IP will be **attached** to your NAT Gateway.

---

#### **2️⃣ Create NAT Gateway**
- **Subnet:** `Public-Subnet` *(must be in a public subnet for internet access)*  
- **Elastic IP:** Attach the **allocated Elastic IP** from step 1.  
- **Name:** `movie-NAT-Gateway`

---

#### **3️⃣ Update Private Route Table**
Add a route to direct outbound traffic from private subnets to the NAT Gateway.

| **Destination** | **Target**          |
|-----------------|---------------------|
| `0.0.0.0/0`     | `movie-NAT-Gateway` |

---

### 🗺️ NAT Gateway Architecture
Below is a visual representation of the NAT Gateway setup:

![](./img3/mnat.png)

---

### ⚡ Best Practices
- **High Availability:**  
  Deploy NAT Gateways in **multiple Availability Zones (AZs)** for redundancy.
  
- **Cost Optimization:**  
  - Stop unused NAT Gateways to **reduce billing costs**.
  - Consider **NAT Instances** for low-budget environments.

- **Security Tip:**  
  Monitor outbound traffic using **VPC Flow Logs** to detect anomalies.

---


## 🛡️ 4. Security Groups

Security Groups act as **virtual firewalls** to control inbound and outbound traffic for each tier.  
Below is the configuration for **Web, App, and Database** layers.

---

### 📋 Security Group Configuration

| 🔐 **SG Name** | 🖥️ **Attached To** | 🚪 **Inbound Rules**                                       | 🌍 **Outbound**    |
|----------------|---------------------|------------------------------------------------------------|--------------------|
| **Web**        | Frontend EC2        | `22` (SSH), `80` (HTTP) — *Anywhere (0.0.0.0/0)*           | **All Traffic**    |
| **App**        | Web Server (Tier 2) | `22` (SSH) — *From Web SG only*                            | **All Traffic**    |
| **DB-RDS**     | Database (Tier 3)   | `3306` (MySQL) — *From App SG only*                        | **All Traffic**    |

---

### 📝 Rule Explanation
- **Web SG (Frontend):**  
  - Allows **SSH (22)** and **HTTP (80)** traffic from anywhere to manage and serve the frontend.  
  - Outbound traffic fully open for updates and internet access.

- **App SG (Application Layer):**  
  - Only **SSH (22)** allowed from **Web SG**, increasing security.  
  - No direct internet access for inbound.

- **DB-RDS SG (Database Layer):**  
  - **MySQL (3306)** allowed only from **App SG**, ensuring database isolation.  
  - No external traffic allowed for inbound.

---

### ⚡ Best Practices
- Use **least privilege principle**: allow only the required ports.  
- Keep **RDS** private with no direct internet access.  
- Enable **VPC Flow Logs** to monitor traffic activity.  
- Regularly **audit security groups** to avoid misconfigurations.

## 🌐 Elastic IP (EIP)

An **Elastic IP (EIP)** is a **static public IPv4 address** provided by AWS that you can **associate with EC2 instances, NAT Gateways, or other resources**.  

Unlike a normal public IP assigned to an instance (which can change when the instance stops/starts), an **Elastic IP remains the same**, making it ideal for stable access.

---

### ❓ Why Use Elastic IP?
1. **Static Public IP** – Your frontend server or NAT Gateway can be accessed reliably using the same IP.  
2. **High Availability** – If an EC2 instance fails, you can quickly remap the EIP to another instance.  
3. **Consistent DNS** – Easier to point a domain to your EC2 instance without IP changes.  
4. **Required for NAT Gateway** – NAT Gateways need an Elastic IP to provide internet access to private subnets.

---

### 🛠️ How to Allocate and Associate an Elastic IP

#### **Step 1: Allocate Elastic IP**
1. Go to **AWS Console → VPC → Elastic IPs → Allocate Elastic IP**  
2. Click **Allocate** and note the allocated IP (e.g., `3.101.23.45`).

#### **Step 2: Associate Elastic IP**
- **For Frontend EC2:**  
  1. Select the Elastic IP → **Actions → Associate Elastic IP**  
  2. Choose **EC2 Instance** and select your **frontend instance**  
  3. Click **Associate**

- **For NAT Gateway:**  
  1. Select Elastic IP → **Actions → Associate with NAT Gateway**  
  2. Choose your **NAT Gateway** (e.g., `movie-NAT-Gateway`)  
  3. Click **Associate**

---

### ⚡ Best Practices
- **Release unused EIPs** – AWS charges for unassociated Elastic IPs.  
- **Use EIPs only for resources needing stable public IPs**.  
- **Keep track of IPs** – Name them logically (e.g., `movie-frontend-eip`, `movie-nat-eip`).

![](./img3/eliastic.png)
---

## 🚀 5. Launch EC2 Instances

This step involves **creating EC2 instances** for both **Frontend** and **Backend** tiers.  
Each instance will be placed in the correct **subnet** with proper configurations for a secure and scalable architecture.

---

### 📋 EC2 Configuration Table

| 🖥️ **Role**    | 🗂️ **AMI**         | 🌐 **Subnet**      | ⚙️ **Instance Type** | 🚪 **Ports**         | 🔑 **Key Pair**   |
|----------------|---------------------|--------------------|----------------------|----------------------|-------------------|
| **Frontend**   | `NGINX`            | **Public-Subnet**  | `t2.micro`           | `22` (SSH), `80` (HTTP) | `movie-key`       |
| **Backend**    | `NGINX`            | **Private-App**    | `t2.micro`           | `22` (SSH), `80` (HTTP) | `movie-key`       |

---

### 📝 Instance Role Details
- **Frontend EC2 (Public Subnet):**  
  - Runs the **user interface** using `NGINX`.  
  - Accessible via **HTTP (80)** for website traffic and **SSH (22)** for admin management.  
  - Internet access through **Internet Gateway**.

- **Backend EC2 (Private Subnet):**  
  - Handles **business logic** and connects to the database.  
  - **No direct internet access** — traffic flows only through the frontend or NAT Gateway.

---

### 📷 Architecture Visualization
Below is the snapshot of how instances are deployed:

![](./img3/Instances.png)

---

### ⚡ Best Practices
- Use **t2.micro** only for testing/demo; switch to **t3.small** or higher for production.  
- Assign **Elastic IP** to the frontend instance for stable public access.  
- Enable **CloudWatch Monitoring** for instance performance tracking.  
- Regularly **rotate SSH key pairs** for better security.

## 5. Launch RDS

| Role      | AMI           | Subnet         | Type     | Ports      | Key Pair     |
|-----------|---------------|----------------|----------|------------|--------------|
| database  |               | private subnet | t2.micro | 22, 3306   | end point    |

![](./img3/database.png)


## 🔑 6. Copy Private Key to Frontend Server

To securely connect to your **Frontend EC2 instance**, follow these steps to copy and set up the private key (`movie-key.pem`).

---

### **Step 1️⃣: Copy the Key Using SCP**

Use the `scp` command to transfer the private key from your local machine to the frontend EC2 instance.

```bash
scp -i movie-key.pem movie-key.pem ec2-user@<frontend-public-ip>:/home/ec2-user/
````
### **Step 2️⃣: SSH Into the Frontend Server**
```bash
ssh -i movie-key.pem ec2-user@<frontend-public-ip>
chmod 400 movie-key.pem
````
## 🗄️ 7. RDS MySQL Configuration (Private-DB)

We are using **AWS RDS (MySQL)** for a managed database solution, so there is **no need to install or manually configure MySQL** on EC2.  
Just follow the steps below:

---

### **Step 1️⃣: Create RDS MySQL Instance**
1. Go to **AWS Console → RDS → Create Database**.
2. **Engine Type:** MySQL  
3. **Deployment Option:** Standard Create  
4. **Templates:** Free Tier *(for testing)*  
5. **DB Instance Identifier:** `movie-db`  
6. **Master Username:** `root`  
7. **Master Password:** `mahesh05`
8. **VPC:** Select your **project VPC**  
9. **Subnet Group:** Choose **Private-DB subnets**
10. **Public Access:** **No** (Keep private for security)
11. **Security Group:** Allow port **3306** only from the **App SG**.

---

### **Step 2️⃣: Configure Security Group**
| **Type**  | **Protocol** | **Port Range** | **Source**          |
|-----------|--------------|----------------|---------------------|
| MySQL/Aurora | TCP          | 3306           | App Security Group  |

> This ensures **only the application layer** can connect to the database.

![](./img3/datatab.png)
![](./img3/datacom.png)

---

### **Step 3️⃣: Connect to RDS from Backend EC2**

**Command to connect using MySQL CLI:**
```bash
mysql -h <RDS-ENDPOINT> -u root -p
```
## 8. Backend Setup (Private-App)

### SSH to Backend

```bash
ssh -i movie-key.pem ec2-user@<frontend-public-ip>
ssh -i movie-key.pem ec2-user@<backend-private-ip>
```

### Install Dependencies

```bash
sudo yum update
sudo yum install nginx PHP8.4 -y
```

### Service start

```bash
sudo systemctl start nginx
sudo systemctl Enable nginx
sudo systemctl start PHP-fpm

```
### Verify

```bash
curl http://public-ip/
```

---
## 9. Frontend Setup with Nginx

### Install Nginx 

```bash
sudo yum update
sudo yum install nginx -y
```

### Paste Below Config

```nginx
server {
    listen 80;
    server_name _;

    location ~ \.php$ {
        proxy_pass http://<backend-private-ip>;
           }
}
```
![](./img3/nginx.png)
### Restart Nginx

```bash
sudo systemctl restart nginx
```

---

## Access the App

Visit:

**http\://frontend-public-ip**

![](./img3/1.png)
![](./img3/2.png)
![](./img3/3.png)
![](./img3/4.png)
![](./img3/datacom.png)

# 🎬 Random Movie Ticket Booking System (AWS 3-Tier Architecture)

## 📖 Project Summary

The ** Movie Ticket Booking System** is a **cloud-based web application** designed using **AWS 3-Tier Architecture** for **high availability, security, and scalability**.  

It allows users to **view movies, book tickets, and manage bookings** seamlessly, while leveraging AWS services for a robust infrastructure.

---

### 🌟 Key Features
- **Frontend Layer (UI):** Built with **HTML, CSS, JavaScript**, hosted on EC2 instances in a **public subnet**.  
- **Application Layer (Logic):** Powered by **PHP** running on EC2 in a **private subnet**, handling business logic and booking operations.  
- **Database Layer (Storage):** **AWS RDS MySQL** for persistent storage, deployed in a **private subnet** with secure access from the application layer.  
- **Networking & Security:**  
  - **VPC with public and private subnets**  
  - **NAT Gateway** for private subnet internet access  
  - **Elastic IPs** for static public access  
  - **Security Groups** with least privilege rules
- **High Availability:** Multi-AZ deployment for database and EC2 instances ensures minimal downtime.  
- **Automated & Managed Services:** AWS RDS handles backups, patching, and scaling automatically.  
- **Secure Access:** EC2 instances managed via **SSH keys** with strict permissions.  

---

### 🏗️ AWS Architecture Overview
- **Public Subnet:** Frontend EC2, NAT Gateway  
- **Private Subnet:** Backend EC2, RDS MySQL  
- **Internet Gateway & Elastic IPs** for reliable public access  
- **Security Groups** enforce controlled traffic flow between layers  

This project demonstrates **modern cloud architecture best practices** while providing a **full-stack, functional movie booking application**.

---

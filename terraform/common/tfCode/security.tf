# Create Control-M Security Group
resource "aws_security_group" "security" {
  name        = "${module.vars.project}-security-group"
  description = "${module.vars.project}-security-group"
  vpc_id      = local.vpc_id
  tags        = merge(map("Name", "${module.vars.project}-security-group", "Description", "Control-M CTM Security Group"), local.tags)
  #tags        = local.tags

  # --------------------------------------------------------------------------
  ### Outbound ###
  # --------------------------------------------------------------------------
  egress {
    from_port   = 10005
    to_port     = 10006
    protocol    = "tcp"
    cidr_blocks = var.egress_cidr_manual[local.environment]
    description = "CTM/Server to CTM/Agent ports - CTMS100"
  }

  egress {
    from_port   = 11005
    to_port     = 11006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS200"
  }

  egress {
    from_port   = 12005
    to_port     = 12006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS300"
  }

  egress {
    from_port   = 13005
    to_port     = 13006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS400"
  }

  egress {
    from_port   = 14005
    to_port     = 14006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS500"
  }

  egress {
    from_port   = 15005
    to_port     = 15006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
    description = "CTM/Server to CTM/Agent ports - CTMS600"
  }

  egress {
    from_port   = 16005
    to_port     = 16006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS700"
  }

  # Open all outbound ports
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Traffic back to On-Prem"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All Traffic back to On-Prem"
  }

  # Allow HTTP(S) return traffic
  egress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP(S) return traffic"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTPS Traffic within VPC"
  }

  egress {
    from_port   = 5431
    to_port     = 5436
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM and CTM/Server PostgresSQL database ports"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "All Traffic back to On-Prem"
  }

  # ICMP IPV4 access
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "ICMP IPV4 access"
  }
  # ICMP IPV6 access
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmpv6"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "ICMP IPV6 access"
  }
  # All UDP access
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "All UDP access"
  }

  # LDAP
  egress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "LDAP TCP 636"
  }
  egress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "LDAP TCP 389"
  }
  egress {
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "LDAP UDP 389"
  }

  # DNS
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "DNS"
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "DNS"
  }
  # Nimsoft
  egress {
    from_port   = 48000
    to_port     = 48099
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "NimSoft Agent comms"
  }

  egress {
    from_port   = 13075
    to_port     = 13075
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM CORBA connection"
  }

  egress {
    from_port   = 8044
    to_port     = 8046
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CA-XCOM"
  }

  egress {
    from_port   = 13100
    to_port     = 13160
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Control-M/EM NS communications"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "All Traffic from On-Prem"
  }
  # ICMP IPV4 access
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "ICMP IPV4 access"
  }
  # ICMP IPV6 access
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmpv6"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "ICMP IPV6 access"
  }
  # All UDP access
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "All UDP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "HTTPS Traffic within VPC"
  }

  ingress {
    from_port   = 2368
    to_port     = 2370
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM to CTM/Server HO1 Configuration Server and Gateway communication ports"
  }
  ingress {
    from_port   = 3368
    to_port     = 3370
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM to CTM/Server HO2 Configuration Server and Gateway communication ports"
  }

  ingress {
    from_port   = 4368
    to_port     = 4370
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM to CTM/Server HO3 Configuration Server and Gateway communication ports"
  }
  #
  ingress {
    from_port   = 5368
    to_port     = 5370
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM to CTM/Server HO4 Configuration Server and Gateway communication ports"
  }
  #
  ingress {
    from_port   = 6368
    to_port     = 6370
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM to CTM/Server HO5 Configuration Server and Gateway communication ports"
  }

  ingress {
    from_port   = 7368
    to_port     = 7370
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM to CTM/Server HO6 Configuration Server and Gateway communication ports"
  }

  ingress {
    from_port   = 8368
    to_port     = 8370
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM to CTM/Server AO7 Configuration Server and Gateway communication ports"
  }

  ingress {
    from_port   = 5431
    to_port     = 5436
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/EM and CTM/Server PostgresSQL database ports"
  }

  ingress {
    from_port   = 13075
    to_port     = 13075
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "CTM/EM CORBA Naming Service"
  }

  ingress {
    from_port   = 13100
    to_port     = 13160
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "CTM/EM Components"
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "Control-M Automation API"
  }

  ingress {
    from_port   = 18080
    to_port     = 18080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "CTM/EM Web Server"
  }

  ingress {
    from_port   = 10005
    to_port     = 10006
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_manual[local.environment]
    description = "CTM/Server to CTM/Agent ports - CTMS100"
  }

  ingress {
    from_port   = 11005
    to_port     = 11006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS200"
  }

  ingress {
    from_port   = 12005
    to_port     = 12006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS300"
  }

  ingress {
    from_port   = 13005
    to_port     = 13006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS400"
  }

  ingress {
    from_port   = 14005
    to_port     = 14006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS500"
  }

  ingress {
    from_port   = 15005
    to_port     = 15006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
    description = "CTM/Server to CTM/Agent ports - CTMS600"
  }


  ingress {
    from_port   = 16005
    to_port     = 16006
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CTM/Server to CTM/Agent ports - CTMS700"
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "NFS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "SSH via local and VPN Connection"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "RDP via local and VPN Connections"
  }

  # WinRM access from anywhere
  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description = "WinRM access from anywhere"
  }

  ## LDAP access 636
  ingress {
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "LDAP authentication"
  }

  ## LDAP access 389
  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "LDAP authentication"
  }

  ## LDAP access 389
  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "LDAP authentication"
  }

  ## LDAP access 53
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "DNS"
  }

  ## LDAP access 53
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "DNS"
  }

  # LDAP access 3268
  ingress {
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "LDAP GC"
  }

  # Nimsoft
  ingress {
    from_port   = 48000
    to_port     = 48099
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "NimSoft Agent comms"
  }

  ingress {
    from_port   = 8044
    to_port     = 8046
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
    description = "CA-XCOM"
  }

  lifecycle {
    prevent_destroy = false
  }
}

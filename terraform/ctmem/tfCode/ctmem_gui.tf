data "aws_ssm_parameter" "admin" {
  name = "ctmwinadmin"
}

#data "aws_ami" "amazon_windows_2016_server" {
#  most_recent = true
#  owners      = ["amazon"]
#
#  filter {
#    name   = "name"
#    values = ["Windows_Server-2016-English-Full-Base*"]
#  }
#}

data "aws_ami" "amazon_windows_2012_server" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base*"]
  }
}

resource "aws_instance" "ctmem_gui" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type     = "winrm"
    user     = "Administrator"
    password = data.aws_ssm_parameter.admin.value
  }
  ami                                  = data.aws_ami.amazon_windows_2012_server.image_id
  instance_type                        = module.vars.common_ec2["win_instance_type"]
  key_name                             = module.vars.common_ec2["keypair_pem_name"]
  iam_instance_profile                 = local.iam_instance_profile_name
  subnet_id                            = local.subnet_1a_id
  instance_initiated_shutdown_behavior = "terminate"

  # Root Storage
  root_block_device {
    volume_size           = "100"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  # Additional Drive
  ebs_block_device {
    volume_size           = "80"
    volume_type           = "gp2"
    device_name           = "/dev/xvdb"
    delete_on_termination = "true"
  }

  # Security Group - JS_CONTROLM_SG
  vpc_security_group_ids = [
    local.ctm_sg_id,
  ]

  tags = merge(
    {
      "Name"             = "JS-CONTROLM-EM_GUI_Client_Server"
      "Description"      = "Control-M CTM/EM GUI Server"
      "autostop"         = true
      "autostart"        = true
      "autostartdayhour" = "Mon:07,Tue:07,Wed:07,Thu:07,Fri:07,Sat:07,Sun:07"
      "autostopdayhour"  = "Mon:18,Tue:18,Wed:18,Thu:18,Fri:18,Sat:11,Sun:11"
    },
    local.tags,
  )
  volume_tags = merge(
    {
      "Name"               = "Instance_Volume"
      "Description"        = "Control-M CTM/EM GUI Server Volume"
      "dataRetention"      = "7-years"
      "dataClassification" = "confidential"
    },
    local.tags,
  )
  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
  # See the following for more info about managing storage with windows:
  # https://blogs.msdn.microsoft.com/san/2012/07/03/managing-storage-with-windows-powershell-on-windows-server-2012/
  user_data = <<EOF
<powershell>

### Set TimeZone ###
Set-TimeZone -Name "GMT Standard Time"

### Bring ebs volume online with read-write access ###
Stop-Service -Name ShellHWDetection
$Disk = Get-Disk | where-object PartitionStyle -eq "RAW"
$Disk | Initialize-Disk -PartitionStyle MBR
$Disk | New-Partition -UseMaximumSize -IsActive -DriveLetter D | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Local Disk" -Confirm:$false -Force
Start-Service -Name ShellHWDetection

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
mkdir D:\Software
#
Copy-S3Object -BucketName js-software-files -Key controlm-v9.0.0/DROST.9.0.00_windows.zip -LocalFile D:\Software\DROST.9.0.00_windows.zip
Copy-S3Object -BucketName js-software-files -Key controlm-v9.0.0/CTMEM_Win_Client_Silent_Install.xml -LocalFile D:\Software\CTMEM_Win_Client_Install.xml
Copy-S3Object -BucketName js-software-files -Key controlm-v9.0.0/PANFT.9.0.00.500_windows_x86_64.zip -LocalFile D:\Software\PANFT.9.0.00.500_windows_x86_64.zip
Copy-S3Object -BucketName js-software-files -Key controlm-v9.0.0/PANFT.9.0.00.515_windows_x86_64.zip -LocalFile D:\Software\PANFT.9.0.00.515_windows_x86_64.zip

Unzip "D:\Software\DROST.9.0.00_windows.zip" "D:\Software\DROST.9.0.00_windows"
rm -Force D:\Software\DROST.9.0.00_windows.zip
cd D:\Software\DROST.9.0.00_windows

$silentFile = "D:\Software\CTMEM_Win_Client_Install.xml"
$response = Start-Process -Wait -FilePath "D:\Software\DROST.9.0.00_windows\Setup_files\components\clientem\setup.exe" -ArgumentList "-silent $silentFile"
if ( $LASTEXITCODE -gt '0' ) {
  Write-EventLog -LogName Application -Source "Control-M" -EventID 3001 -Message "Failed to install Control-M/EM Client"
  Write-Output "Failed to install Control-M/EM Client"
} else {
  Write-Output "Control-M/EM Client Installation successfully completed"
  Write-EventLog -LogName Application -Source "Control-M" -EventID 3001 -Message "Control-M/EM Client Installation successfully completed"
  Unzip "D:\Software\PANFT.9.0.00.500_windows_x86_64.zip" "D:\Software\PANFT.9.0.00.500_windows_x86_64"
  rm -Force D:\Software\PANFT.9.0.00.500_windows_x86_64.zip
  $response = Start-Process -NoNewWindow -Wait -FilePath "D:\Software\PANFT.9.0.00.500_windows_x86_64\PANFT.9.0.00.500_windows_x86_64" -ArgumentList "-silent"
  if ( $LASTEXITCODE -gt '0' ) {
    Write-Output "Failed to install Control-M/EM Client FixPack 500"
    Write-EventLog -LogName Application -Source "Control-M" -EventID 3001 -Message "Failed to install Control-M/EM Client FixPack 500"
  } else {
    Write-Output "Control-M/EM Client FixPack 500 Installation successfully completed"
    Write-EventLog -LogName Application -Source "Control-M" -EventID 3001 -Message "Control-M/EM Client FixPack 500 Installation successfully completed"
    Unzip "D:\Software\PANFT.9.0.00.515_windows_x86_64.zip" "D:\Software\PANFT.9.0.00.515_windows_x86_64"
    rm -Force D:\Software\PANFT.9.0.00.515_windows_x86_64.zip
    $response = Start-Process -NoNewWindow -Wait -FilePath "D:\Software\PANFT.9.0.00.515_windows_x86_64\PANFT.9.0.00.515_windows_x86_64" -ArgumentList "-silent"
    if ( $LASTEXITCODE -gt '0' ) {
      Write-Output "Failed to install Control-M/EM Client FixPack 515"
      Write-EventLog -LogName Application -Source "Control-M" -EventID 3001 -Message "Failed to install Control-M/EM Client FixPack 515"
    } else {
      Write-EventLog -LogName Application -Source "Control-M" -EventID 3001 -Message "Successfully installed Control-M/EM Client FixPack 515"
      Write-Output "Control-M/EM Client FixPack 515 Installation successfully completed"
    }
  }
}

### Set SSM Agent to use the Proxy. ###
# $serviceKey = "HKLM:\SYSTEM\CurrentControlSet\Services\AmazonSSMAgent"
# $keyInfo = (Get-Item -Path $serviceKey).GetValue("Environment")
# $proxyVariables = @("http_proxy=http://a-proxy-p.js.aws:8080", "https_proxy=http://a-proxy-p.js.aws:8080", "no_proxy=169.254.169.254")
#
# if ( $keyInfo -eq $null )
# {
# New-ItemProperty -Path $serviceKey -Name Environment -Value $proxyVariables -PropertyType MultiString -Force
# } else {
# Set-ItemProperty -Path $serviceKey -Name Environment -Value $proxyVariables
# }
# Restart-Service AmazonSSMAgent

</powershell>
EOF
}

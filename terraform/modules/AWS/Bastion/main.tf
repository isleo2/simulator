resource "aws_instance" "simulator_bastion" {
  ami                         = var.ami_id
  key_name                    = var.access_key_name
  instance_type               = var.instance_type
  vpc_security_group_ids      = [var.security_group]
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  user_data                   = data.template_file.cloud_config.rendered

  tags = merge(
    var.default_tags,
    {
      "Name" = "Simulator Bastion"
    },
  )

  connection {
    host = aws_instance.simulator_bastion.public_ip
    type = "ssh"
    user = "root"

    // disable ssh-agent support
    agent       = "false"
    private_key = file(pathexpand("~/.kubesim/cp_simulator_rsa"))

    // Increase the timeout so the server has time to reboot
    timeout = "10m"
  }

  provisioner "file" {
    source      = "${path.module}/../../../../simulation-scripts/scenario/authorized_keys.sh"
    destination = "/root/authorized_keys.sh"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "/tmp/authorize-keys.sh ${var.access_github_usernames}",
  #   ]
  # }

}

// resource "null_resource" "bastion_connect" {
//   // triggers = {
//   //   attack_container_tag = var.attack_container_tag
//   // }

//   // Ensure we can SSH as root for the goss tests and also for preturb.sh
//   // Ensure we can SSH as root for the goss tests and also for preturb.sh
//   connection {
//     host = aws_instance.simulator_bastion.public_ip
//     type = "ssh"
//     user = "root"

//     // disable ssh-agent support
//     agent       = "false"
//     private_key = file(pathexpand("~/.kubesim/cp_simulator_rsa"))

//     // Increase the timeout so the server has time to reboot
//     timeout = "10m"
//   }

//   // provisioner "file" {
//   //   source      = "${path.module}/../../scripts/run-goss.sh"
//   //   destination = "/root/run-goss.sh"
//   // }


//   provisioner "file" {
//     source      = "./main.tf"
//     destination = "/root/main.tf"
//   }

//   // provisioner "remote-exec" {
//   //   inline = [
//   //     "chmod +x /root/run-goss.sh",
//   //     "/root/run-goss.sh",
//   //     "rm /root/run-goss.sh /root/goss.yaml",
//   //   ]
//   // }
// }



# outputs for for_each
output "ec2_public_ip" {
    value = [
        for key in aws_instance.my-test : key.public_ip
    ]
}
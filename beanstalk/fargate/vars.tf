variable "cluster_name" {
  default = "tictactoe-cluster"
}
variable "task_family" {
  default = "tictactoe-task"
}
variable "container_name" {
  default = "tictactoe-container"
}
variable "image" {
  default = "my-docker-image"
}
variable "subnets" {
  default = ["subnet-12345678"]
}
variable "security_groups" {
  default = ["sg-12345678"]
}

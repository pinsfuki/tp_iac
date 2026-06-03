output "container_name" {
  value = docker_container.stacknova_recette.name
}

output "container_http_port" {
  value = docker_container.stacknova_recette.ports[0].external
}

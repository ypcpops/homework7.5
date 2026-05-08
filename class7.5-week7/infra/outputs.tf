output "vpc_name" {
  value = google_compute_network.week7_vpc.name
}
output "file_content" {
  value = local_file.favorite_food.content
}
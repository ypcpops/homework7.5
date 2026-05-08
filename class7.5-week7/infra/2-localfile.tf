resource "local_file" "favorite_food" {
  content  = "my favorite food is jerk chicken"
  filename = "${path.module}/favoritefood.txt"
}
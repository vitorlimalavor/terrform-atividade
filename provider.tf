provider "google-beta" {
  credentials = "${file("credentials.json")}"
  project     = "genuine-energy-265800"
  region      = "us-central1"
}

provider "google" {
  credentials = "${file("credentials.json")}"
  project     = "genuine-energy-265800"
  region      = "us-central1"
}
